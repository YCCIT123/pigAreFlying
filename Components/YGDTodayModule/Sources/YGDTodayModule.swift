//
//  YGDTodayModule.swift
//  YGDTodayModule
//
//  Created by yangchengcheng on 2026/6/4.
//

import UIKit
import YGDCoreKit
import YGDModuleBridgeKit
import YGDRouterKit

/// Today 业务模块入口。
public final class YGDTodayModule: YGDFeatureModule {
    /// 当前模块所属的主标签页。
    public let tab: AppTab = .today

    /// 创建 Today 业务模块入口。
    public init() {}

    /// 创建 Today 首页控制器。
    public func makeRootViewController() -> UIViewController {
        TodayViewController()
    }

    /// 注册 Today 模块的全部路由。
    public func registerRoutes(to router: YGDRouterManager) {
        router.registerRoute(routeKey: "today/home", tab: .today, version: "v1") { target in
            YCGTodayHomeCoordinator(target: target)
        }
    }
}

