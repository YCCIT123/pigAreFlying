//
//  AppDelegate.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/25.
//

import UIKit
import YGDModuleBridgeKit
import YGDModuleIndexKit
import YGDRouterKit

/// 应用启动代理，负责装配根窗口和初始化路由系统。
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    /// 应用主窗口。
    var window: UIWindow?

    /// 应用启动完成后的统一入口。
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        YGDModuleIndexBootstrap.registerAllModules()
        YGDFeatureModuleRegistry.shared.registerAllRoutes(to: YGDRouterManager.shared)
        YGDRouterManager.shared.applyRemoteRules([
            YGDRemoteRouteRule(matchPrefix: "pig://legacy/tasks/detail", action: .rewrite(targetPrefix: "pig://tasks/detail")),
            YGDRemoteRouteRule(matchPrefix: "pig://tasks/detail", action: .forceNativeVersion("v2")),
        ])

        let rootViewController = RootViewController()
        YGDRouterManager.shared.attachAppNavigator(rootViewController)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        return true
    }
}
