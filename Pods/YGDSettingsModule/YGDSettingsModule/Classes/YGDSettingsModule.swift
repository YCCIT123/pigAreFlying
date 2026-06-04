//
//  YGDSettingsModule.swift
//  YGDSettingsModule
//
//  Created by yangchengcheng on 2026/6/4.
//

import UIKit
import YGDCoreKit
import YGDModuleBridgeKit
import YGDRouterKit

/// Settings 业务模块入口。
public final class YGDSettingsModule: YGDFeatureModule {
    /// 当前模块所属的主标签页。
    public let tab: AppTab = .settings

    /// 创建 Settings 业务模块入口。
    public init() {}

    /// 创建 Settings 首页控制器。
    public func makeRootViewController() -> UIViewController {
        SettingsViewController()
    }

    /// 注册 Settings 模块的全部路由。
    public func registerRoutes(to router: YGDRouterManager) {
        router.registerRoute(routeKey: "settings/home", tab: .settings, version: "v1") { target in
            YGDStaticViewControllerCoordinator(target: target) {
                SettingsViewController()
            }
        }
    }
}

