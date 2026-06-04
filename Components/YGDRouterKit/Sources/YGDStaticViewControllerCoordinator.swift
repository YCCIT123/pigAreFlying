//
//  YGDStaticViewControllerCoordinator.swift
//  YGDRouterKit
//
//  Created by yangchengcheng on 2026/6/4.
//

import UIKit

/// 通用页面协调器，用于快速包装单页面业务。
public final class YGDStaticViewControllerCoordinator: Coordinator {
    /// 当前协调器对应的路由目标。
    public let target: YGDRouteTarget

    /// 当前协调器持有的页面构建闭包。
    private let viewControllerBuilder: () -> UIViewController

    /// 创建通用页面协调器。
    public init(target: YGDRouteTarget, viewControllerBuilder: @escaping () -> UIViewController) {
        self.target = target
        self.viewControllerBuilder = viewControllerBuilder
    }

    /// 构建最终页面。
    public func buildViewController() -> UIViewController {
        viewControllerBuilder()
    }
}

