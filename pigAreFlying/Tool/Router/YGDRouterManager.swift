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
//        let viewController = YGDLearningDetailViewController(
//            pageTitleText: "Tasks Detail",
//            versionText: "Native V1",
//            summaryText: "这是旧版原生页面，用来模拟线上仍然保留的稳定链路。",
//            accentColor: .systemBlue,
//            params: params
//        )
//        navigationController.pushViewController(viewController, animated: true)
    }
}
