//
//  RootViewController.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/25.
//

import SnapKit
import UIKit

final class RootViewController: UIViewController {
    /// 底部标签栏内容区域的可见高度。
    private let bottomTabBarContentHeight: CGFloat = 56

    /// 页面内容承载容器。
    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    /// 自定义底部标签栏。
    private lazy var bottomTabBarView: BottomTabBarView = .init()

    /// Today 页面导航控制器。
    private lazy var todayNavigationController: UINavigationController = AppScreenFactory.makeNavigationController(for: .today)

    /// Tasks 页面导航控制器。
    private lazy var tasksNavigationController: UINavigationController = AppScreenFactory.makeNavigationController(for: .tasks)

    /// Focus 页面导航控制器。
    private lazy var focusNavigationController: UINavigationController = AppScreenFactory.makeNavigationController(for: .focus)

    /// Insights 页面导航控制器。
    private lazy var insightsNavigationController: UINavigationController = AppScreenFactory.makeNavigationController(for: .insights)

    /// Settings 页面导航控制器。
    private lazy var settingsNavigationController: UINavigationController = AppScreenFactory.makeNavigationController(for: .settings)

    /// 当前选中的标签页。
    private var selectedTab: AppTab = .today
    /// 当前正在显示的子控制器。
    private weak var currentController: UIViewController?

    /// 页面加载完成后的统一入口。
    override func viewDidLoad() {
        super.viewDidLoad()

        YGDRouterManager.shared.attachAppNavigator(self)
        setupViewHierarchy()
        setupConstraints()
        bottomTabBarView.delegate = self
        bottomTabBarView.setSelectedTab(selectedTab)
        selectTab(selectedTab)
    }
}

extension RootViewController {
    /// 配置根控制器的视图层级。
    func setupViewHierarchy() {
        view.backgroundColor = .systemBackground

        view.addSubview(contentContainerView)
        view.addSubview(bottomTabBarView)
    }

    /// 配置根控制器的约束关系。
    func setupConstraints() {
        contentContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomTabBarView.snp.top)
        }

        bottomTabBarView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-bottomTabBarContentHeight)
        }
    }

    /// 返回指定标签页对应的导航控制器。
    func navigationController(for tab: AppTab) -> UINavigationController {
        switch tab {
        case .today:
            todayNavigationController
        case .tasks:
            tasksNavigationController
        case .focus:
            focusNavigationController
        case .insights:
            insightsNavigationController
        case .settings:
            settingsNavigationController
        }
    }

    /// 切换当前选中的标签页。
    func selectTab(_ tab: AppTab) {
        let newController = navigationController(for: tab)

        if currentController === newController {
            bottomTabBarView.setSelectedTab(tab)
            selectedTab = tab
            return
        }

        let previousController = currentController

        addChild(newController)
        contentContainerView.addSubview(newController.view)
        newController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        previousController?.willMove(toParent: nil)
        previousController?.view.removeFromSuperview()
        previousController?.removeFromParent()
        newController.didMove(toParent: self)
        currentController = newController
        selectedTab = tab
        bottomTabBarView.setSelectedTab(tab)
    }
}

extension RootViewController: BottomTabBarViewDelegate {
    /// 处理底部标签栏的选择事件。
    func bottomTabBarView(_: BottomTabBarView, didSelect tab: AppTab, repeatedTap: Bool) {
        if repeatedTap {
            navigationController(for: tab).popToRootViewController(animated: false)
            return
        }

        selectTab(tab)
    }
}

extension RootViewController: YGDAppNavigator {
    /// 激活指定的 Tab。
    func activateTab(_ tab: AppTab) {
        selectTab(tab)
    }

    /// 返回当前正在使用的导航控制器。
    func currentNavigationController() -> UINavigationController {
        navigationController(for: selectedTab)
    }
}
