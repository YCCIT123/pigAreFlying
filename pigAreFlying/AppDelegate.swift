//
//  AppDelegate.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/25.
//

import UIKit

@main
/// 应用启动代理，负责装配根窗口和初始化路由系统。
class AppDelegate: UIResponder, UIApplicationDelegate {
    /// 应用主窗口。
    var window: UIWindow?

    /// 应用启动完成后的统一入口。
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppRouteBootstrap.registerAllRoutes()

        let rootViewController = RootViewController()
        YGDRouterManager.shared.attachAppNavigator(rootViewController)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        return true
    }
}
