//
//  YGDUnifiedRegistrationRouter.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/27.
//

import UIKit

enum AppRouteBootstrap {
    /// 应用启动时统一注册所有业务路由。
      static func registerAllRoutes() {
          // 获取全部路由
          let router = YGDRouterManager.shared
          TodayRouterRegistrar.register(to: router)
          TasksRouterRegistrar.register(to: router)
          FocusRouterRegistrar.register(to: router)
          InsightsRouterRegistrar.register(to: router)
          SettingRouterRegistrar.register(to: router)
          
      }
}

enum TodayRouterRegistrar {
    /// 注册 Today 模块的所有原生路由。
    static func register(to router: YGDRouterManager) {
        router.registerRoute(routeKey: "tasks/detail", version: "v1") { navigationController, params in
            YGDTaskDetailV1Coordinator(navigationController: navigationController, params: params)
        }
    }
}
enum TasksRouterRegistrar {
    /// 注册 Tasks 模块的所有原生路由。
    static func register(to router: YGDRouterManager) {
    }
}
enum FocusRouterRegistrar {
    /// 注册 Focus 模块的所有原生路由。
    static func register(to router: YGDRouterManager) {
    }
}
enum InsightsRouterRegistrar {
    /// 注册 Insights 模块的所有原生路由。
    static func register(to router: YGDRouterManager) {
    }
}
enum SettingRouterRegistrar {
    /// 注册 Setting 模块的所有原生路由。
    static func register(to router: YGDRouterManager) {
    }
}
