//
//  YGDRouterManager.swift
//  YGDRouterKit
//
//  Created by yangchengcheng on 2026/6/4.
//

import UIKit
import YGDCoreKit

/// 统一路由中心，负责接收 URL 并协调解析与导航执行。
public final class YGDRouterManager: NSObject {
    /// 全局单例路由管理器。
    public static let shared = YGDRouterManager()

    /// 原生路由注册表。
    let routeRegistry = YGDRouteRegistry()
    /// 远端规则处理器。
    let routeRuleEngine = YGDRemoteRouteRuleEngine()
    /// 当前应用级导航器。
    weak var appNavigator: YGDAppNavigator?

    /// 单例初始化方法。
    override private init() {
        super.init()
    }

    /// 挂载应用级导航器。
    public func attachAppNavigator(_ appNavigator: YGDAppNavigator) {
        self.appNavigator = appNavigator
    }

    /// 注册一条原生路由。
    public func registerRoute(routeKey: String, tab: AppTab, version: String = "v1", identityParamKeys: [String] = [], coordinatorFactory: @escaping YGDCoordinatorFactory) {
        routeRegistry.registerRoute(routeKey: routeKey, tab: tab, version: version, identityParamKeys: identityParamKeys, coordinatorFactory: coordinatorFactory)
    }

    /// 批量应用后端下发的远端配置。
    public func applyRemoteRules(_ rules: [YGDRemoteRouteRule]) {
        routeRuleEngine.applyRules(rules)
    }

    /// 使用应用级导航器发起一次路由。
    @discardableResult
    public func open(_ urlString: String, extraParams: [String: String] = [:], style: YGDRouteOpenStyle = .push) -> Bool {
        let intent = YGDRouteIntent(urlString: urlString, extraParams: extraParams, style: style)
        return open(intent)
    }

    /// 使用应用级导航器发起一次路由意图。
    @discardableResult
    public func open(_ intent: YGDRouteIntent) -> Bool {
        let decision = resolve(urlString: intent.urlString, extraParams: intent.extraParams, style: intent.style)
        return execute(decision: decision, fallbackNavigationController: nil)
    }

    /// 使用指定导航栈发起一次路由。
    @discardableResult
    public func open(_ urlString: String, on navigationController: UINavigationController, extraParams: [String: String] = [:], style: YGDRouteOpenStyle = .push) -> Bool {
        let decision = resolve(urlString: urlString, extraParams: extraParams, style: style)
        return execute(decision: decision, fallbackNavigationController: navigationController)
    }
}

