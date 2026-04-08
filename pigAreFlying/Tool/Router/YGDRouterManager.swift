//
//  YGDRouterManager.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/27.
//

import UIKit
import SnapKit
import SafariServices

/// 协调器工厂闭包，用于根据路由目标构建具体业务协调器。
typealias YGDCoordinatorFactory = (YGDRouteTarget) -> Coordinator

/// 路由拦截器闭包，返回 `true` 表示放行，返回 `false` 表示拦截。
typealias YGDRouteInterceptor = (String) -> Bool

/// 应用级导航能力协议，负责切换 Tab 和提供导航栈。
protocol YGDAppNavigator: AnyObject {
    /// 激活指定的 Tab。
    func activateTab(_ tab: AppTab)

    /// 返回指定 Tab 对应的导航控制器。
    func navigationController(for tab: AppTab) -> UINavigationController

    /// 返回当前正在使用的导航控制器。
    func currentNavigationController() -> UINavigationController
}

/// 可被 Router 在导航栈中识别的页面协议。
protocol YGDRouteStackIdentifiable where Self: UIViewController {
    /// 当前页面对应的业务路由主键。
    var routeKey: String { get }

    /// 当前页面的业务身份标识，用于区分同路由下的不同页面实例。
    var routeIdentity: String? { get }
}

/// Coordinator 基础协议，负责根据路由目标构建最终页面。
protocol Coordinator: AnyObject {
    /// 当前协调器绑定的路由目标。
    var target: YGDRouteTarget { get }

    /// 根据路由目标构建最终要展示的页面。
    func buildViewController() -> UIViewController
}

/// 路由打开方式。
enum YGDRouteOpenStyle {
    /// 在当前导航栈中继续 push。
    case push

    /// 在当前导航栈中优先回到已存在页面，找不到再 push。
    case popToExisting

    /// 先切换到目标 Tab，再 push。
    case switchTabAndPush

    /// 先切换到目标 Tab，再优先回到已存在页面，找不到再 push。
    case switchTabAndPopToExisting
}

/// 一次完整的路由意图。
struct YGDRouteIntent {
    /// 原始路由地址。
    let urlString: String

    /// 业务补充参数。
    let extraParams: [String: String]

    /// 打开方式。
    let style: YGDRouteOpenStyle
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

/// Router 解析完成后的标准业务目标。
struct YGDRouteTarget {
    /// 目标所属的 Tab。
    let tab: AppTab

    /// 目标业务路由主键。
    let routeKey: String

    /// 目标业务版本。
    let version: String

    /// 最终要传给业务的参数字典。
    let params: [String: String]

    /// 当前路由的打开方式。
    let style: YGDRouteOpenStyle

    /// 当前路由对应的页面身份标识。
    let identity: String?
}

/// 已注册的原生路由项，代表一个可执行的本地业务节点。
struct YGDNativeRouteItem {
    /// 该路由对应的默认 Tab。
    let tab: AppTab

    /// 用于提取页面身份标识的参数键。
    let identityParamKeys: [String]

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
    /// 命中原生路由，交给对应 Coordinator 构建页面。
    case native(item: YGDNativeRouteItem, target: YGDRouteTarget)

    /// 命中远端 H5 降级。
    case web(url: URL)

    /// 当前路由被拦截。
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

    /// 当前应用级导航器。
    private weak var appNavigator: YGDAppNavigator?

    /// 单例初始化方法。
    private override init() {
        super.init()
    }

    /// 挂载应用级导航器。
    func attachAppNavigator(_ appNavigator: YGDAppNavigator) {
        self.appNavigator = appNavigator
    }

    /// 注册一条原生路由。
    func registerRoute(routeKey: String, tab: AppTab, version: String = "v1", identityParamKeys: [String] = [], coordinatorFactory: @escaping YGDCoordinatorFactory) {
        let normalizedRouteKey = normalizeRouteKey(routeKey)
        let storageKey = makeStorageKey(routeKey: normalizedRouteKey, version: version)
        let routeItem = YGDNativeRouteItem(tab: tab, identityParamKeys: identityParamKeys, coordinatorFactory: coordinatorFactory)

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

    /// 使用应用级导航器发起一次路由。
    @discardableResult
    func open(_ urlString: String, extraParams: [String: String] = [:], style: YGDRouteOpenStyle = .push) -> Bool {
        let intent = YGDRouteIntent(urlString: urlString, extraParams: extraParams, style: style)
        return open(intent)
    }

    /// 使用应用级导航器发起一次路由意图。
    @discardableResult
    func open(_ intent: YGDRouteIntent) -> Bool {
        let decision = resolve(urlString: intent.urlString, extraParams: intent.extraParams, style: intent.style)
        return execute(decision: decision, fallbackNavigationController: nil)
    }

    /// 使用指定导航栈发起一次路由。
    @discardableResult
    func open(_ urlString: String, on navigationController: UINavigationController, extraParams: [String: String] = [:], style: YGDRouteOpenStyle = .push) -> Bool {
        let decision = resolve(urlString: urlString, extraParams: extraParams, style: style)
        return execute(decision: decision, fallbackNavigationController: navigationController)
    }
}

private extension YGDRouterManager {
    /// 根据输入 URL、补充参数和打开方式计算最终路由决策。
    func resolve(urlString: String, extraParams: [String: String], style: YGDRouteOpenStyle) -> YGDRouteDecision {
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

        guard let nativeRouteItem = routes[storageKey] else {
            return .blocked(message: "未找到 \(routeKey) 对应的原生 Coordinator")
        }

        let routeTarget = YGDRouteTarget(tab: nativeRouteItem.tab, routeKey: routeKey, version: version, params: finalParams, style: style, identity: makeRouteIdentity(params: finalParams, identityParamKeys: nativeRouteItem.identityParamKeys))

        return .native(item: nativeRouteItem, target: routeTarget)
    }

    /// 执行远端规则，产出最终可分发的路由上下文。
    func applyRemoteRules(to urlString: String) -> YGDRouteResolutionContext {
        var workingURLString = urlString
        var forcedVersion: String?

        for rule in remoteRules where rule.matches(workingURLString) {
            switch rule.action {
            case .rewrite(let targetPrefix):
                workingURLString = rewritePrefix(in: workingURLString, sourcePrefix: rule.matchPrefix, targetPrefix: targetPrefix)
            case .forceNativeVersion(let version):
                forcedVersion = version
            case .degradeToWeb(let urlString):
                let webURL = URL(string: urlString)
                return YGDRouteResolutionContext(finalURLString: workingURLString, forcedVersion: forcedVersion, blockedMessage: webURL == nil ? "降级地址无效: \(urlString)" : nil, webURL: webURL)
            case .block(let message):
                return YGDRouteResolutionContext(finalURLString: workingURLString, forcedVersion: forcedVersion, blockedMessage: message, webURL: nil)
            }
        }

        return YGDRouteResolutionContext(finalURLString: workingURLString, forcedVersion: forcedVersion, blockedMessage: nil, webURL: nil)
    }

    /// 执行 Router 最终产生的路由动作。
    func execute(decision: YGDRouteDecision, fallbackNavigationController: UINavigationController?) -> Bool {
        switch decision {
        case .native(let item, let target):
            guard let navigationController = makeNavigationController(for: target, fallbackNavigationController: fallbackNavigationController) else {
                return false
            }

            if shouldPopToExisting(for: target.style) {
                let popped = popToExistingViewControllerIfNeeded(target: target, in: navigationController)

                if popped {
                    return true
                }
            }

            let coordinator = item.coordinatorFactory(target)
            let viewController = coordinator.buildViewController()
            navigationController.pushViewController(viewController, animated: true)
            return true

        case .web(let url):
            guard let navigationController = makePresentationNavigationController(fallbackNavigationController: fallbackNavigationController) else {
                return false
            }

            let safariViewController = SFSafariViewController(url: url)
            navigationController.present(safariViewController, animated: true)
            return true

        case .blocked(let message):
            guard let navigationController = makePresentationNavigationController(fallbackNavigationController: fallbackNavigationController) else {
                return false
            }

            presentBlockedAlert(message: message, on: navigationController)
            return false
        }
    }

    /// 根据打开方式选择最终要操作的导航栈。
    func makeNavigationController(for target: YGDRouteTarget, fallbackNavigationController: UINavigationController?) -> UINavigationController? {
        switch target.style {
        case .switchTabAndPush, .switchTabAndPopToExisting:
            guard let appNavigator else {
                return fallbackNavigationController
            }

            appNavigator.activateTab(target.tab)
            return appNavigator.navigationController(for: target.tab)

        case .push, .popToExisting:
            if let fallbackNavigationController {
                return fallbackNavigationController
            }

            return appNavigator?.currentNavigationController()
        }
    }

    /// 返回当前用于展示弹窗或 H5 的导航栈。
    func makePresentationNavigationController(fallbackNavigationController: UINavigationController?) -> UINavigationController? {
        if let fallbackNavigationController {
            return fallbackNavigationController
        }

        return appNavigator?.currentNavigationController()
    }

    /// 判断当前打开方式是否应该优先回到栈内已存在页面。
    func shouldPopToExisting(for style: YGDRouteOpenStyle) -> Bool {
        switch style {
        case .push, .switchTabAndPush:
            return false
        case .popToExisting, .switchTabAndPopToExisting:
            return true
        }
    }

    /// 在指定导航栈中查找并回到已存在页面。
    func popToExistingViewControllerIfNeeded(target: YGDRouteTarget, in navigationController: UINavigationController) -> Bool {
        for viewController in navigationController.viewControllers.reversed() {
            guard let identifiableController = viewController as? YGDRouteStackIdentifiable else {
                continue
            }

            let sameRouteKey = identifiableController.routeKey == target.routeKey
            let sameIdentity = identifiableController.routeIdentity == target.identity
            let shouldMatchNilIdentity = target.identity == nil

            guard sameRouteKey else {
                continue
            }

            guard shouldMatchNilIdentity || sameIdentity else {
                continue
            }

            navigationController.popToViewController(viewController, animated: true)
            return true
        }

        return false
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

    /// 从参数字典中提取页面身份标识。
    func makeRouteIdentity(params: [String: String], identityParamKeys: [String]) -> String? {
        for key in identityParamKeys {
            guard let value = params[key], value.isEmpty == false else {
                continue
            }

            return value
        }

        return nil
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
        let alertController = UIAlertController(title: "当前路由不可用", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "知道了", style: .default)
        alertController.addAction(confirmAction)

        if let topViewController = navigationController.topViewController {
            topViewController.present(alertController, animated: true)
            return
        }

        navigationController.present(alertController, animated: true)
    }
}

/// 通用页面协调器，用于快速包装单页面业务。
final class YGDStaticViewControllerCoordinator: Coordinator {
    /// 当前协调器对应的路由目标。
    let target: YGDRouteTarget

    /// 当前协调器持有的页面构建闭包。
    private let viewControllerBuilder: () -> UIViewController

    /// 创建通用页面协调器。
    init(target: YGDRouteTarget, viewControllerBuilder: @escaping () -> UIViewController) {
        self.target = target
        self.viewControllerBuilder = viewControllerBuilder
    }

    /// 构建最终页面。
    func buildViewController() -> UIViewController {
        return viewControllerBuilder()
    }
}

/// 任务详情页 v1 协调器，代表旧版原生链路。
final class YGDTaskDetailV1Coordinator: Coordinator {
    /// 当前协调器对应的路由目标。
    let target: YGDRouteTarget

    /// 创建任务详情 v1 协调器。
    init(target: YGDRouteTarget) {
        self.target = target
    }

    /// 构建任务详情 v1 页面。
    func buildViewController() -> UIViewController {
        return YGDTaskDetailViewController(target: target, versionTitleText: "Task Detail V1", accentColor: .systemBlue)
    }
}

/// 任务详情页 v2 协调器，代表新版原生链路。
final class YGDTaskDetailV2Coordinator: Coordinator {
    /// 当前协调器对应的路由目标。
    let target: YGDRouteTarget

    /// 创建任务详情 v2 协调器。
    init(target: YGDRouteTarget) {
        self.target = target
    }

    /// 构建任务详情 v2 页面。
    func buildViewController() -> UIViewController {
        return YGDTaskDetailViewController(target: target, versionTitleText: "Task Detail V2", accentColor: .systemGreen)
    }
}

/// 专注会话协调器。
final class YGDFocusSessionCoordinator: Coordinator {
    /// 当前协调器对应的路由目标。
    let target: YGDRouteTarget

    /// 创建专注会话协调器。
    init(target: YGDRouteTarget) {
        self.target = target
    }

    /// 构建专注会话页面。
    func buildViewController() -> UIViewController {
        return YGDFocusSessionViewController(target: target)
    }
}

/// 任务详情演示页面。
final class YGDTaskDetailViewController: BaseFeatureViewController, YGDRouteStackIdentifiable {
    /// 当前页面对应的路由目标。
    private let target: YGDRouteTarget

    /// 页面顶部版本标题。
    private let versionTitleText: String

    /// 页面强调色。
    private let accentColor: UIColor

    /// 当前页面对应的业务路由主键。
    var routeKey: String {
        return target.routeKey
    }

    /// 当前页面的业务身份标识。
    var routeIdentity: String? {
        return target.identity
    }

    /// 页面主标题标签。
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.text = versionTitleText
        return label
    }()

    /// 页面说明标签。
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "这个页面是路由详情页示例，支持通过 routeKey + identity 在导航栈内精确回退。"
        return label
    }()

    /// 参数信息卡片。
    private lazy var paramsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 22
        return view
    }()

    /// 参数卡片标题。
    private lazy var paramsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = accentColor
        label.text = "Route Params"
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

    /// 创建任务详情演示页面。
    init(target: YGDRouteTarget, versionTitleText: String, accentColor: UIColor) {
        self.target = target
        self.versionTitleText = versionTitleText
        self.accentColor = accentColor
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

private extension YGDTaskDetailViewController {
    /// 配置页面视图层级。
    func setupViewHierarchy() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
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

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        paramsCardView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
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

    /// 将参数字典格式化为可阅读文本。
    func formattedParamsText() -> String {
        guard target.params.isEmpty == false else {
            return "没有携带额外参数"
        }

        let lines = target.params.sorted { lhs, rhs in
            return lhs.key < rhs.key
        }.map { key, value in
            return "\(key): \(value)"
        }

        return lines.joined(separator: "\n")
    }
}

/// 专注会话演示页面。
final class YGDFocusSessionViewController: BaseFeatureViewController, YGDRouteStackIdentifiable {
    /// 当前页面对应的路由目标。
    private let target: YGDRouteTarget

    /// 当前页面对应的业务路由主键。
    var routeKey: String {
        return target.routeKey
    }

    /// 当前页面的业务身份标识。
    var routeIdentity: String? {
        return target.identity
    }

    /// 页面主标题标签。
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.text = "Focus Session"
        return label
    }()

    /// 页面说明标签。
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "这个页面用于演示跨模块路由和通过 identity 回到已存在会话页。"
        return label
    }()

    /// 会话信息卡片。
    private lazy var sessionCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 22
        return view
    }()

    /// 会话标题标签。
    private lazy var sessionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .systemOrange
        label.text = "Session Identity"
        return label
    }()

    /// 会话内容标签。
    private lazy var sessionValueLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = formattedSessionText()
        return label
    }()

    /// 创建专注会话演示页面。
    init(target: YGDRouteTarget) {
        self.target = target
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

private extension YGDFocusSessionViewController {
    /// 配置页面视图层级。
    func setupViewHierarchy() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(sessionCardView)
        sessionCardView.addSubview(sessionTitleLabel)
        sessionCardView.addSubview(sessionValueLabel)
    }

    /// 配置页面约束。
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        sessionCardView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        sessionTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }

        sessionValueLabel.snp.makeConstraints { make in
            make.top.equalTo(sessionTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }

    /// 生成会话展示文本。
    func formattedSessionText() -> String {
        let identifierText = target.identity ?? "无 identity"
        return "routeKey: \(target.routeKey)\nidentity: \(identifierText)"
    }
}

/// Today 根页面对应的路由身份扩展。
extension TodayViewController: YGDRouteStackIdentifiable {
    /// 当前页面对应的业务路由主键。
    var routeKey: String {
        return "today/home"
    }

    /// 当前页面的业务身份标识。
    var routeIdentity: String? {
        return nil
    }
}

/// Tasks 根页面对应的路由身份扩展。
extension TasksViewController: YGDRouteStackIdentifiable {
    /// 当前页面对应的业务路由主键。
    var routeKey: String {
        return "tasks/home"
    }

    /// 当前页面的业务身份标识。
    var routeIdentity: String? {
        return nil
    }
}

/// Focus 根页面对应的路由身份扩展。
extension FocusViewController: YGDRouteStackIdentifiable {
    /// 当前页面对应的业务路由主键。
    var routeKey: String {
        return "focus/home"
    }

    /// 当前页面的业务身份标识。
    var routeIdentity: String? {
        return nil
    }
}

/// Insights 根页面对应的路由身份扩展。
extension InsightsViewController: YGDRouteStackIdentifiable {
    /// 当前页面对应的业务路由主键。
    var routeKey: String {
        return "insights/home"
    }

    /// 当前页面的业务身份标识。
    var routeIdentity: String? {
        return nil
    }
}

/// Settings 根页面对应的路由身份扩展。
extension SettingsViewController: YGDRouteStackIdentifiable {
    /// 当前页面对应的业务路由主键。
    var routeKey: String {
        return "settings/home"
    }

    /// 当前页面的业务身份标识。
    var routeIdentity: String? {
        return nil
    }
}
