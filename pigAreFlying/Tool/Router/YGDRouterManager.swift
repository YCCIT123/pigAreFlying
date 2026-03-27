//
//  YGDRouterManager.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/27.
//

import UIKit
import SnapKit
import SafariServices

/// 协调器工厂闭包，用于按路由结果创建具体业务协调器。
typealias YGDCoordinatorFactory = (UINavigationController, [String: String]) -> Coordinator

/// 路由拦截器闭包，返回 `true` 表示放行，返回 `false` 表示拦截。
typealias YGDRouteInterceptor = (String) -> Bool

/// Coordinator 基础协议，负责承接 Router 已经确认好的原生业务流程。
protocol Coordinator: AnyObject {
    /// 当前协调器绑定的导航控制器。
    var navigationController: UINavigationController { get set }

    /// 启动当前协调器对应的业务流程。
    func start()
}

/// 远端规则命中后的动作类型。
enum YGDRemoteRouteAction {
    /// 将旧 URL 前缀改写成新 URL 前缀。
    case rewrite(targetPrefix: String)

    /// 强制命中指定原生版本。
    case forceNativeVersion(String)

    /// 降级到指定 H5 地址。
    case degradeToWeb(String)

    /// 直接拦截当前请求。
    case block(String)
}

/// 一条由后端控制塔下发的路由规则。
struct YGDRemoteRouteRule {
    /// 规则命中的 URL 前缀。
    let matchPrefix: String

    /// 规则命中后执行的动作。
    let action: YGDRemoteRouteAction

    /// 判断当前规则是否命中指定 URL。
    func matches(_ urlString: String) -> Bool {
        return urlString.hasPrefix(matchPrefix)
    }
}

/// 已注册的原生路由项，代表一个可执行的本地业务节点。
struct YGDNativeRouteItem {
    /// 当前路由命中后创建协调器的工厂闭包。
    let coordinatorFactory: YGDCoordinatorFactory
}

/// Router 在执行远端规则后的中间态结果。
private struct YGDRouteResolutionContext {
    /// 规则处理后的最终 URL。
    let finalURLString: String

    /// 规则强制指定的原生版本。
    let forcedVersion: String?

    /// 是否已经被远端规则直接拦截。
    let blockedMessage: String?

    /// 是否已经被远端规则直接降级到 H5。
    let webURL: URL?
}

/// Router 最终的执行决策。
private enum YGDRouteDecision {
    /// 命中原生路由，交给 Coordinator 执行。
    case native(item: YGDNativeRouteItem, params: [String: String])

    /// 降级打开 H5。
    case web(url: URL)

    /// 拦截当前路由。
    case blocked(message: String)
}

/// 统一路由中心，负责接收 URL、执行远端规则并分发给本地 Coordinator。
final class YGDRouterManager: NSObject {

    /// 全局单例路由管理器。
    static let shared = YGDRouterManager()

    /// 已注册的原生路由表，key 形如 `tasks/detail@v1`。
    private var routes: [String: YGDNativeRouteItem] = [:]

    /// 当前生效的远端规则表。
    private var remoteRules: [YGDRemoteRouteRule] = []

    /// 全局拦截器集合。
    private var interceptors: [YGDRouteInterceptor] = []

    /// 每个路由主键的默认版本表。
    private var defaultVersions: [String: String] = [:]

    /// 是否已经安装学习用的本地演示路由。
    private var hasInstalledLearningRoutes: Bool = false

    /// 单例初始化方法。
    private override init() {
        super.init()
    }

    /// 注册一条原生路由。
    func registerRoute(
        routeKey: String,
        version: String = "v1",
        coordinatorFactory: @escaping YGDCoordinatorFactory
    ) {
        let normalizedRouteKey = normalizeRouteKey(routeKey)
        let storageKey = makeStorageKey(routeKey: normalizedRouteKey, version: version)
        let routeItem = YGDNativeRouteItem(
            coordinatorFactory: coordinatorFactory
        )

        routes[storageKey] = routeItem

        if defaultVersions[normalizedRouteKey] == nil {
            defaultVersions[normalizedRouteKey] = version
        }
    }

    /// 批量应用后端下发的远端配置。
    func applyRemoteRules(_ rules: [YGDRemoteRouteRule]) {
        remoteRules = rules
    }

    /// 追加一个全局拦截器。
    func appendInterceptor(_ interceptor: @escaping YGDRouteInterceptor) {
        interceptors.append(interceptor)
    }

    /// 清空所有已注册的本地路由。
    func removeAllRoutes() {
        routes.removeAll()
        defaultVersions.removeAll()
    }

    /// 清空所有远端规则。
    func removeAllRemoteRules() {
        remoteRules.removeAll()
    }

    /// 清空所有拦截器。
    func removeAllInterceptors() {
        interceptors.removeAll()
    }

    /// 一次性重置当前 Router 的学习环境。
    func resetLearningEnvironment() {
        removeAllRoutes()
        removeAllRemoteRules()
        removeAllInterceptors()
        hasInstalledLearningRoutes = false
    }

    /// 安装一套可直接学习的本地示例。
    func installLearningDemoIfNeeded() {
        guard hasInstalledLearningRoutes == false else {
            return
        }

        registerRoute(
            routeKey: "tasks/detail",
            version: "v1"
        ) { navigationController, params in
            YGDTaskDetailV1Coordinator(navigationController: navigationController, params: params)
        }

        registerRoute(
            routeKey: "tasks/detail",
            version: "v2"
        ) { navigationController, params in
            YGDTaskDetailV2Coordinator(navigationController: navigationController, params: params)
        }

        registerRoute(routeKey: "focus/session", version: "v1") { navigationController, params in
            YGDFocusSessionCoordinator(navigationController: navigationController, params: params)
        }

        applyRemoteRules(makeDefaultLearningRules())

        appendInterceptor { urlString in
            return urlString.contains("forbidden") == false
        }

        hasInstalledLearningRoutes = true
    }

    /// 使用一条 URL 发起路由。
    @discardableResult
    func open(
        _ urlString: String,
        on navigationController: UINavigationController,
        extraParams: [String: String] = [:]
    ) -> Bool {
        if routes.isEmpty {
            installLearningDemoIfNeeded()
        }

        let decision = resolve(urlString: urlString, extraParams: extraParams)
        return execute(decision: decision, on: navigationController)
    }
}

private extension YGDRouterManager {
    /// 生成学习环境的默认远端规则。
    func makeDefaultLearningRules() -> [YGDRemoteRouteRule] {
        return [
            YGDRemoteRouteRule(
                matchPrefix: "pig://legacy/tasks/detail",
                action: .rewrite(targetPrefix: "pig://tasks/detail")
            ),
            YGDRemoteRouteRule(
                matchPrefix: "pig://tasks/detail",
                action: .forceNativeVersion("v2")
            ),
            YGDRemoteRouteRule(
                matchPrefix: "pig://settings/debug",
                action: .block("当前调试入口已被远端熔断")
            )
        ]
    }

    /// 根据输入 URL 和补充参数计算最终路由决策。
    func resolve(urlString: String, extraParams: [String: String]) -> YGDRouteDecision {
        let trimmedURLString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedURLString.isEmpty == false else {
            return .blocked(message: "URL 不能为空")
        }

        let resolutionContext = applyRemoteRules(to: trimmedURLString)

        if let blockedMessage = resolutionContext.blockedMessage {
            return .blocked(message: blockedMessage)
        }

        if let webURL = resolutionContext.webURL {
            return .web(url: webURL)
        }

        let intercepted = interceptors.allSatisfy { interceptor in
            return interceptor(resolutionContext.finalURLString)
        }

        guard intercepted else {
            return .blocked(message: "当前 URL 命中了本地拦截器")
        }

        guard let url = URL(string: resolutionContext.finalURLString) else {
            return .blocked(message: "当前 URL 无法解析")
        }

        let routeKey = makeRouteKey(from: url)

        guard routeKey.isEmpty == false else {
            return .blocked(message: "未识别到有效的路由主键")
        }

        let urlParams = parseParameters(from: url)
        let finalParams = urlParams.merging(extraParams) { _, newValue in
            return newValue
        }
        let version = resolutionContext.forcedVersion ?? defaultVersions[routeKey] ?? "v1"
        let storageKey = makeStorageKey(routeKey: routeKey, version: version)

        if let nativeRouteItem = routes[storageKey] {
            return .native(item: nativeRouteItem, params: finalParams)
        }

        return .blocked(message: "未找到 \(routeKey) 对应的原生 Coordinator")
    }

    /// 执行远端规则，产出最终可分发的路由上下文。
    func applyRemoteRules(to urlString: String) -> YGDRouteResolutionContext {
        var workingURLString = urlString
        var forcedVersion: String?

        for rule in remoteRules where rule.matches(workingURLString) {
            switch rule.action {
            case .rewrite(let targetPrefix):
                workingURLString = rewritePrefix(
                    in: workingURLString,
                    sourcePrefix: rule.matchPrefix,
                    targetPrefix: targetPrefix
                )
            case .forceNativeVersion(let version):
                forcedVersion = version
            case .degradeToWeb(let urlString):
                let webURL = URL(string: urlString)
                return YGDRouteResolutionContext(
                    finalURLString: workingURLString,
                    forcedVersion: forcedVersion,
                    blockedMessage: webURL == nil ? "降级地址无效: \(urlString)" : nil,
                    webURL: webURL
                )
            case .block(let message):
                return YGDRouteResolutionContext(
                    finalURLString: workingURLString,
                    forcedVersion: forcedVersion,
                    blockedMessage: message,
                    webURL: nil
                )
            }
        }

        return YGDRouteResolutionContext(
            finalURLString: workingURLString,
            forcedVersion: forcedVersion,
            blockedMessage: nil,
            webURL: nil
        )
    }

    /// 执行 Router 最终产生的路由动作。
    func execute(decision: YGDRouteDecision, on navigationController: UINavigationController) -> Bool {
        switch decision {
        case .native(let item, let params):
            let coordinator = item.coordinatorFactory(navigationController, params)
            coordinator.start()
            return true
        case .web(let url):
            let safariViewController = SFSafariViewController(url: url)
            navigationController.present(safariViewController, animated: true)
            return true
        case .blocked(let message):
            presentBlockedAlert(message: message, on: navigationController)
            return false
        }
    }

    /// 将 URL 转换成项目内部使用的路由主键。
    func makeRouteKey(from url: URL) -> String {
        let routeSegments = [url.host, url.path]
            .compactMap { segment -> String? in
                guard let segment else {
                    return nil
                }

                let normalizedSegment = segment.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

                return normalizedSegment.isEmpty ? nil : normalizedSegment
            }

        return normalizeRouteKey(routeSegments.joined(separator: "/"))
    }

    /// 规范化输入的路由主键。
    func normalizeRouteKey(_ routeKey: String) -> String {
        return routeKey.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    /// 生成内部路由存储键。
    func makeStorageKey(routeKey: String, version: String) -> String {
        return "\(normalizeRouteKey(routeKey))@\(version)"
    }

    /// 解析 URL 中携带的 query 参数。
    func parseParameters(from url: URL) -> [String: String] {
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []

        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value ?? ""
        }
    }

    /// 仅重写 URL 开头命中的前缀，避免误改 query 或其他片段。
    func rewritePrefix(in urlString: String, sourcePrefix: String, targetPrefix: String) -> String {
        guard urlString.hasPrefix(sourcePrefix) else {
            return urlString
        }

        let suffix = urlString.dropFirst(sourcePrefix.count)
        return targetPrefix + suffix
    }

    /// 展示路由被拦截时的提示弹窗。
    func presentBlockedAlert(message: String, on navigationController: UINavigationController) {
        let alertController = UIAlertController(
            title: "当前路由不可用",
            message: message,
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(title: "知道了", style: .default)
        alertController.addAction(confirmAction)

        if let topViewController = navigationController.topViewController {
            topViewController.present(alertController, animated: true)
            return
        }

        navigationController.present(alertController, animated: true)
    }
}

/// 任务详情页 v1 协调器，代表旧版原生链路。
final class YGDTaskDetailV1Coordinator: Coordinator {
    /// 当前协调器持有的导航控制器。
    var navigationController: UINavigationController

    /// 当前路由携带的业务参数。
    private let params: [String: String]

    /// 创建任务详情 v1 协调器。
    init(navigationController: UINavigationController, params: [String: String]) {
        self.navigationController = navigationController
        self.params = params
    }

    /// 启动任务详情 v1 页面。
    func start() {
        let viewController = YGDLearningDetailViewController(
            pageTitleText: "Tasks Detail",
            versionText: "Native V1",
            summaryText: "这是旧版原生页面，用来模拟线上仍然保留的稳定链路。",
            accentColor: .systemBlue,
            params: params
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}

/// 任务详情页 v2 协调器，代表新版原生链路。
final class YGDTaskDetailV2Coordinator: Coordinator {
    /// 当前协调器持有的导航控制器。
    var navigationController: UINavigationController

    /// 当前路由携带的业务参数。
    private let params: [String: String]

    /// 创建任务详情 v2 协调器。
    init(navigationController: UINavigationController, params: [String: String]) {
        self.navigationController = navigationController
        self.params = params
    }

    /// 启动任务详情 v2 页面。
    func start() {
        let viewController = YGDLearningDetailViewController(
            pageTitleText: "Tasks Detail",
            versionText: "Native V2",
            summaryText: "这是新版原生页面，用来模拟远端规则把流量切到新业务版本。",
            accentColor: .systemGreen,
            params: params
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}

/// 专注会话页协调器，代表另一个独立组件。
final class YGDFocusSessionCoordinator: Coordinator {
    /// 当前协调器持有的导航控制器。
    var navigationController: UINavigationController

    /// 当前路由携带的业务参数。
    private let params: [String: String]

    /// 创建专注会话协调器。
    init(navigationController: UINavigationController, params: [String: String]) {
        self.navigationController = navigationController
        self.params = params
    }

    /// 启动专注会话页面。
    func start() {
        let viewController = YGDLearningDetailViewController(
            pageTitleText: "Focus Session",
            versionText: "Native V1",
            summaryText: "这个页面代表另一个独立模块，证明 Router 只做分发，复杂 UI 流程仍然由 Coordinator 承接。",
            accentColor: .systemOrange,
            params: params
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}

/// 学习用的详情页面，统一展示当前命中的版本和路由参数。
final class YGDLearningDetailViewController: BaseFeatureViewController {
    /// 页面主标题文本。
    private let pageTitleText: String

    /// 页面版本标签文本。
    private let versionText: String

    /// 页面摘要说明文本。
    private let summaryText: String

    /// 页面强调色。
    private let accentColor: UIColor

    /// 页面展示的参数字典。
    private let params: [String: String]

    /// 页面主标题标签。
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .label
        label.text = pageTitleText
        return label
    }()

    /// 页面版本徽标视图。
    private lazy var versionBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = accentColor.withAlphaComponent(0.15)
        view.layer.cornerRadius = 14
        return view
    }()

    /// 页面版本徽标文本。
    private lazy var versionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = accentColor
        label.text = versionText
        return label
    }()

    /// 页面摘要卡片。
    private lazy var summaryCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 24
        return view
    }()

    /// 页面摘要标题。
    private lazy var summaryTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.text = "路由结果"
        return label
    }()

    /// 页面摘要内容。
    private lazy var summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = summaryText
        return label
    }()

    /// 参数卡片。
    private lazy var paramsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 24
        return view
    }()

    /// 参数卡片标题。
    private lazy var paramsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.text = "参数透传"
        return label
    }()

    /// 参数卡片内容。
    private lazy var paramsLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = formattedParamsText()
        return label
    }()

    /// 创建学习用详情页面。
    init(
        pageTitleText: String,
        versionText: String,
        summaryText: String,
        accentColor: UIColor,
        params: [String: String]
    ) {
        self.pageTitleText = pageTitleText
        self.versionText = versionText
        self.summaryText = summaryText
        self.accentColor = accentColor
        self.params = params
        super.init(nibName: nil, bundle: nil)
    }

    /// `UIViewController` 的解码初始化方法。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 页面加载完成后的统一入口。
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        setupConstraints()
    }
}

private extension YGDLearningDetailViewController {
    /// 配置页面视图层级。
    func setupViewHierarchy() {
        view.backgroundColor = .systemBackground

        view.addSubview(titleLabel)
        view.addSubview(versionBadgeView)
        versionBadgeView.addSubview(versionLabel)
        view.addSubview(summaryCardView)
        summaryCardView.addSubview(summaryTitleLabel)
        summaryCardView.addSubview(summaryLabel)
        view.addSubview(paramsCardView)
        paramsCardView.addSubview(paramsTitleLabel)
        paramsCardView.addSubview(paramsLabel)
    }

    /// 配置页面约束。
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        versionBadgeView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.leading.equalToSuperview().inset(20)
        }

        versionLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14))
        }

        summaryCardView.snp.makeConstraints { make in
            make.top.equalTo(versionBadgeView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        summaryTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }

        summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(summaryTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }

        paramsCardView.snp.makeConstraints { make in
            make.top.equalTo(summaryCardView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        paramsTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }

        paramsLabel.snp.makeConstraints { make in
            make.top.equalTo(paramsTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }

    /// 将路由参数字典格式化为可阅读文本。
    func formattedParamsText() -> String {
        guard params.isEmpty == false else {
            return "没有携带额外参数"
        }

        let lines = params
            .sorted { lhs, rhs in
                return lhs.key < rhs.key
            }
            .map { key, value in
                return "\(key): \(value)"
            }

        return lines.joined(separator: "\n")
    }
}
