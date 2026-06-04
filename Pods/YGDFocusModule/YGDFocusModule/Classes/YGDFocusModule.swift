//
//  YGDFocusModule.swift
//  YGDFocusModule
//
//  Created by yangchengcheng on 2026/6/4.
//

import UIKit
import YGDCoreKit
import YGDModuleBridgeKit
import YGDRouterKit

/// Focus 业务模块入口。
public final class YGDFocusModule: YGDFeatureModule {
    /// 当前模块所属的主标签页。
    public let tab: AppTab = .focus

    /// 创建 Focus 业务模块入口。
    public init() {}

    /// 创建 Focus 首页控制器。
    public func makeRootViewController() -> UIViewController {
        FocusViewController()
    }

    /// 注册 Focus 模块的全部路由。
    public func registerRoutes(to router: YGDRouterManager) {
        router.registerRoute(routeKey: "focus/home", tab: .focus, version: "v1") { target in
            YGDStaticViewControllerCoordinator(target: target) {
                FocusViewController()
            }
        }

        router.registerRoute(routeKey: "focus/session", tab: .focus, version: "v1", identityParamKeys: ["id"]) { target in
            YGDStaticViewControllerCoordinator(target: target) {
                FocusSessionViewController(target: target)
            }
        }
    }
}

