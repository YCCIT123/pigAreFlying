//
//  YGDRouteRegistry.swift
//  YGDRouterKit
//
//  Created by yangchengcheng on 2026/6/4.
//

import Foundation
import YGDCoreKit

/// 原生路由注册表，集中维护路由项和默认版本。
final class YGDRouteRegistry {
    /// 已注册的原生路由表，key 形如 `tasks/detail@v1`。
    private var routes: [String: YGDNativeRouteItem] = [:]
    /// 每个路由主键的默认版本表。
    private var defaultVersions: [String: String] = [:]

    /// 注册一条原生路由。
    func registerRoute(routeKey: String, tab: AppTab, version: String, identityParamKeys: [String], coordinatorFactory: @escaping YGDCoordinatorFactory) {
        let normalizedRouteKey = YGDRouteURLParser.normalizeRouteKey(routeKey)
        let storageKey = makeStorageKey(routeKey: normalizedRouteKey, version: version)
        let routeItem = YGDNativeRouteItem(tab: tab, identityParamKeys: identityParamKeys, coordinatorFactory: coordinatorFactory)

        routes[storageKey] = routeItem

        if defaultVersions[normalizedRouteKey] == nil {
            defaultVersions[normalizedRouteKey] = version
        }
    }

    /// 读取指定路由和版本对应的原生路由项。
    func routeItem(routeKey: String, version: String) -> YGDNativeRouteItem? {
        let storageKey = makeStorageKey(routeKey: routeKey, version: version)
        return routes[storageKey]
    }

    /// 读取指定路由主键的默认版本。
    func defaultVersion(for routeKey: String) -> String? {
        defaultVersions[YGDRouteURLParser.normalizeRouteKey(routeKey)]
    }

    /// 生成内部路由存储键。
    private func makeStorageKey(routeKey: String, version: String) -> String {
        "\(YGDRouteURLParser.normalizeRouteKey(routeKey))@\(version)"
    }
}

