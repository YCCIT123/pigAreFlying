//
//  YCGTodayHomeCoordinator.swift
//  YGDTodayModule
//
//  Created by yangchengcheng on 2026/6/4.
//

import UIKit
import YGDRouterKit

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

