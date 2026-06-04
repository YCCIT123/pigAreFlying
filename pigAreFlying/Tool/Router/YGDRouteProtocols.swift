//
//  YGDRouteProtocols.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/27.
//

import UIKit

/// 应用级导航能力协议，RootViewController 实现此协议以接入路由系统。
protocol YGDAppNavigator: AnyObject {
    /// 激活指定的 Tab。
    func activateTab(_ tab: AppTab)
    /// 返回指定 Tab 对应的导航控制器。
    func navigationController(for tab: AppTab) -> UINavigationController
    /// 返回当前正在使用的导航控制器。
    func currentNavigationController() -> UINavigationController
}

/// 可被 Router 在导航栈中识别的页面协议，用于 popToExisting 回退。
protocol YGDRouteStackIdentifiable where Self: UIViewController {
    /// 当前页面对应的业务路由主键。
    var routeKey: String { get }
    /// 当前页面的业务身份标识，用于区分同路由下的不同页面实例。
    var routeIdentity: String? { get }
}

/// Coordinator 基础协议，负责根据路由目标构建最终页面。
protocol Coordinator: AnyObject {
    /// 当前协调器绑定的路由目标。
    var target: YGDRouteTarget { get }
    /// 根据路由目标构建最终要展示的页面。
    func buildViewController() -> UIViewController
}
