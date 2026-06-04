//
//  YGDFeatureModuleRegistry.swift
//  YGDModuleBridgeKit
//
//  Created by yangchengcheng on 2026/6/4.
//

import UIKit
import YGDCoreKit
import YGDRouterKit

/// 业务模块注册表，负责保存模块入口并统一暴露给 App 壳层。
public final class YGDFeatureModuleRegistry {
    /// 全局业务模块注册表。
    public static let shared = YGDFeatureModuleRegistry()

    /// 已注册的业务模块表。
    private var modules: [AppTab: YGDFeatureModule] = [:]

    /// 注册表初始化方法。
    private init() {}

    /// 注册一个业务模块。
    public func register(_ module: YGDFeatureModule) {
        modules[module.tab] = module
    }

    /// 创建指定标签页对应的首页控制器。
    public func makeRootViewController(for tab: AppTab) -> UIViewController? {
        modules[tab]?.makeRootViewController()
    }

    /// 注册所有已接入业务模块的路由。
    public func registerAllRoutes(to router: YGDRouterManager) {
        AppTab.allCases.forEach { tab in
            modules[tab]?.registerRoutes(to: router)
        }
    }
}

