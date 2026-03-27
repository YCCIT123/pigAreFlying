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
