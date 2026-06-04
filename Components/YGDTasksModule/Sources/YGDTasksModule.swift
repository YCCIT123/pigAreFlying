//
//  YGDTasksModule.swift
//  YGDTasksModule
//
//  Created by yangchengcheng on 2026/6/4.
//

import UIKit
import YGDCoreKit
import YGDModuleBridgeKit
import YGDRouterKit

/// Tasks 业务模块入口。
public final class YGDTasksModule: YGDFeatureModule {
    /// 当前模块所属的主标签页。
    public let tab: AppTab = .tasks

    /// 创建 Tasks 业务模块入口。
    public init() {}

    /// 创建 Tasks 首页控制器。
    public func makeRootViewController() -> UIViewController {
        TasksViewController()
    }

    /// 注册 Tasks 模块的全部路由。
    public func registerRoutes(to router: YGDRouterManager) {
        router.registerRoute(routeKey: "tasks/home", tab: .tasks, version: "v1") { target in
            YGDStaticViewControllerCoordinator(target: target) {
                TasksViewController()
            }
        }

        router.registerRoute(routeKey: "tasks/detail", tab: .tasks, version: "v1", identityParamKeys: ["id"]) { target in
            YGDStaticViewControllerCoordinator(target: target) {
                TasksDetailViewController(target: target, titleText: "Task Detail V1", descriptionText: "旧版任务详情路由页面，用于验证 routeKey 与 identity 的栈内复用。")
            }
        }

        router.registerRoute(routeKey: "tasks/detail", tab: .tasks, version: "v2", identityParamKeys: ["id"]) { target in
            YGDStaticViewControllerCoordinator(target: target) {
                TasksDetailViewController(target: target, titleText: "Task Detail V2", descriptionText: "新版任务详情路由页面，可被远端规则强制命中。")
            }
        }
    }
}

