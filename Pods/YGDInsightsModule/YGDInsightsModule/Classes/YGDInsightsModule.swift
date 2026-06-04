//
//  YGDInsightsModule.swift
//  YGDInsightsModule
//
//  Created by yangchengcheng on 2026/6/4.
//

import UIKit
import YGDCoreKit
import YGDModuleBridgeKit
import YGDRouterKit

/// Insights 业务模块入口。
public final class YGDInsightsModule: YGDFeatureModule {
    /// 当前模块所属的主标签页。
    public let tab: AppTab = .insights

    /// 创建 Insights 业务模块入口。
    public init() {}

    /// 创建 Insights 首页控制器。
    public func makeRootViewController() -> UIViewController {
        InsightsViewController()
    }

    /// 注册 Insights 模块的全部路由。
    public func registerRoutes(to router: YGDRouterManager) {
        router.registerRoute(routeKey: "insights/home", tab: .insights, version: "v1") { target in
            YGDStaticViewControllerCoordinator(target: target) {
                InsightsViewController()
            }
        }
    }
}

