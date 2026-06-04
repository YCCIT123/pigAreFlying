//
//  YGDRouterManager+Resolving.swift
//  pigAreFlying
//
//  Created by Codex on 2026/5/15.
//

import Foundation

extension YGDRouterManager {
    /// 根据输入 URL、补充参数和打开方式计算最终路由决策。
    func resolve(urlString: String, extraParams: [String: String], style: YGDRouteOpenStyle) -> YGDRouteDecision {
        let trimmedURLString = urlString.ygd_trimmed()

        guard trimmedURLString.ygd_isNilOrEmpty() == false else {
            return .blocked(message: "URL 不能为空")
        }

        let resolutionContext = routeRuleEngine.resolve(urlString: trimmedURLString)

        if let blockedMessage = resolutionContext.blockedMessage {
            return .blocked(message: blockedMessage)
        }

        if let webURL = resolutionContext.webURL {
            return .web(url: webURL)
        }

        guard let url = URL(string: resolutionContext.finalURLString) else {
            return .blocked(message: "当前 URL 无法解析")
        }

        let routeKey = YGDRouteURLParser.makeRouteKey(from: url)

        guard routeKey.ygd_isNilOrEmpty() == false else {
            return .blocked(message: "未识别到有效的路由主键")
        }

        let urlParams = YGDRouteURLParser.parseParameters(from: url)
        let finalParams = urlParams.merging(extraParams) { _, newValue in
            newValue
        }
        let version = resolutionContext.forcedVersion ?? routeRegistry.defaultVersion(for: routeKey) ?? "v1"

        guard let nativeRouteItem = routeRegistry.routeItem(routeKey: routeKey, version: version) else {
            return .blocked(message: "未找到 \(routeKey) 对应的原生 Coordinator")
        }

        let routeTarget = YGDRouteTarget(
            tab: nativeRouteItem.tab,
            routeKey: routeKey,
            version: version,
            params: finalParams,
            style: style,
            identity: YGDRouteURLParser.makeRouteIdentity(params: finalParams, identityParamKeys: nativeRouteItem.identityParamKeys)
        )

        return .native(item: nativeRouteItem, target: routeTarget)
    }
}
