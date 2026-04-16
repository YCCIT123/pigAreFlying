//
//  YCGTodayHomeCoordinator.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/30.
//

import UIKit

/// Today 首页协调器。
final class YCGTodayHomeCoordinator: Coordinator {
    /// 当前协调器对应的路由目标。
    let target: YGDRouteTarget

    /// 创建 Today 首页协调器。
    init(target: YGDRouteTarget) {
        self.target = target
    }

    /// 构建 Today 首页页面。
    func buildViewController() -> UIViewController {
        TodayViewController()
    }
}
