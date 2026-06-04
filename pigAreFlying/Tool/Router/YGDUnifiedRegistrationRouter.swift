//
//  YGDUnifiedRegistrationRouter.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/27.
//

import UIKit

/// 应用级路由启动装配器。
enum AppRouteBootstrap {
    /// 应用启动时统一注册所有业务路由。
    static func registerAllRoutes() {
        let router = YGDRouterManager.shared

        TodayRouterRegistrar.register(to: router)
        TasksRouterRegistrar.register(to: router)
        FocusRouterRegistrar.register(to: router)
        InsightsRouterRegistrar.register(to: router)
        SettingsRouterRegistrar.register(to: router)

        router.applyRemoteRules([
            YGDRemoteRouteRule(matchPrefix: "pig://legacy/tasks/detail", action: .rewrite(targetPrefix: "pig://tasks/detail")),
            YGDRemoteRouteRule(matchPrefix: "pig://tasks/detail", action: .forceNativeVersion("v2")),
        ])
    }
}

/// Today 模块路由注册器。
enum TodayRouterRegistrar {
    /// 注册 Today 模块的所有原生路由。
    static func register(to router: YGDRouterManager) {
        router.registerRoute(routeKey: "today/home", tab: .today, version: "v1") { target in
            YCGTodayHomeCoordinator(target: target)
        }
    }
}

/// Tasks 模块路由注册器。
enum TasksRouterRegistrar {
    /// 注册 Tasks 模块的所有原生路由。
    static func register(to router: YGDRouterManager) {
        router.registerRoute(routeKey: "tasks/home", tab: .tasks, version: "v1") { target in
            YGDStaticViewControllerCoordinator(target: target) {
                TasksViewController()
            }
        }

        router.registerRoute(routeKey: "tasks/detail", tab: .tasks, version: "v1", identityParamKeys: ["id"]) { target in
            YGDStaticViewControllerCoordinator(target: target) {
                YGDDetailPageViewController(
                    target: target,
                    config: YGDDetailPageConfig(
                        title: "Task Detail V1",
                        description: "旧版任务详情路由页面，用于验证 routeKey 与 identity 的栈内复用。",
                        routeKey: "tasks/detail",
                        nextRoute: nil,
                        nextButtonTitle: "下一级"
                    )
                )
            }
        }

        router.registerRoute(routeKey: "tasks/detail", tab: .tasks, version: "v2", identityParamKeys: ["id"]) { target in
            YGDStaticViewControllerCoordinator(target: target) {
                YGDDetailPageViewController(
                    target: target,
                    config: YGDDetailPageConfig(
                        title: "Task Detail V2",
                        description: "新版任务详情路由页面，可被远端规则强制命中。",
                        routeKey: "tasks/detail",
                        nextRoute: nil,
                        nextButtonTitle: "下一级"
                    )
                )
            }
        }
    }
}

/// Focus 模块路由注册器。
enum FocusRouterRegistrar {
    /// 注册 Focus 模块的所有原生路由。
    static func register(to router: YGDRouterManager) {
        router.registerRoute(routeKey: "focus/home", tab: .focus, version: "v1") { target in
            YGDStaticViewControllerCoordinator(target: target) {
                FocusViewController()
            }
        }

        router.registerRoute(routeKey: "focus/session", tab: .focus, version: "v1", identityParamKeys: ["id"]) { target in
            YGDStaticViewControllerCoordinator(target: target) {
                YGDDetailPageViewController(
                    target: target,
                    config: YGDDetailPageConfig(
                        title: "Focus Session",
                        description: "专注会话路由页面，用于验证跨模块跳转和已有页面回退。",
                        routeKey: "focus/session",
                        nextRoute: nil,
                        nextButtonTitle: "下一级"
                    )
                )
            }
        }
    }
}

/// Insights 模块路由注册器。
enum InsightsRouterRegistrar {
    /// 注册 Insights 模块的所有原生路由。
    static func register(to router: YGDRouterManager) {
        router.registerRoute(routeKey: "insights/home", tab: .insights, version: "v1") { target in
            YGDStaticViewControllerCoordinator(target: target) {
                InsightsViewController()
            }
        }
    }
}

/// Settings 模块路由注册器。
enum SettingsRouterRegistrar {
    /// 注册 Settings 模块的所有原生路由。
    static func register(to router: YGDRouterManager) {
        router.registerRoute(routeKey: "settings/home", tab: .settings, version: "v1") { target in
            YGDStaticViewControllerCoordinator(target: target) {
                SettingsViewController()
            }
        }
    }
}
