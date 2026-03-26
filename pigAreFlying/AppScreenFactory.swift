//
//  AppScreenFactory.swift
//  pigAreFlying
//
//  Created by Codex on 2026/3/25.
//

import UIKit

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
        switch tab {
        case .today:
            return TodayViewController()
        case .tasks:
            return TasksViewController()
        case .focus:
            return FocusViewController()
        case .insights:
            return InsightsViewController()
        case .settings:
            return SettingsViewController()
        }
    }
}
