//
//  AppScreenFactory.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/25.
//

import UIKit
import YGDCoreKit
import YGDModuleBridgeKit

enum AppScreenFactory {
    /// 创建指定标签页对应的导航控制器。
    static func makeNavigationController(for tab: AppTab) -> UINavigationController {
        let rootViewController = makeRootViewController(for: tab)
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.view.backgroundColor = .systemBackground

        return navigationController
    }

    /// 创建指定标签页对应的根控制器。
    private static func makeRootViewController(for tab: AppTab) -> UIViewController {
        if let rootViewController = YGDFeatureModuleRegistry.shared.makeRootViewController(for: tab) {
            return rootViewController
        }

        return makeFallbackViewController(for: tab)
    }

    /// 创建模块缺失时的兜底页面。
    private static func makeFallbackViewController(for tab: AppTab) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemBackground
        viewController.title = tab.title
        return viewController
    }
}
