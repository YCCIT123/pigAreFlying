//
//  YGDRouterManager+Navigation.swift
//  YGDRouterKit
//
//  Created by yangchengcheng on 2026/6/4.
//

import SafariServices
import UIKit

extension YGDRouterManager {
    /// 执行 Router 最终产生的路由动作。
    func execute(decision: YGDRouteDecision, fallbackNavigationController: UINavigationController?) -> Bool {
        switch decision {
        case let .native(item, target):
            guard let navigationController = makeNavigationController(for: target, fallbackNavigationController: fallbackNavigationController) else {
                return false
            }

            if target.style.shouldPopToExisting, popToExistingViewControllerIfNeeded(target: target, in: navigationController) {
                return true
            }

            let coordinator = item.coordinatorFactory(target)
            let viewController = coordinator.buildViewController()
            navigationController.pushViewController(viewController, animated: true)
            return true

        case let .web(url):
            guard let navigationController = makePresentationNavigationController(fallbackNavigationController: fallbackNavigationController) else {
                return false
            }

            let safariViewController = SFSafariViewController(url: url)
            navigationController.present(safariViewController, animated: true)
            return true

        case let .blocked(message):
            guard let navigationController = makePresentationNavigationController(fallbackNavigationController: fallbackNavigationController) else {
                return false
            }

            presentBlockedAlert(message: message, on: navigationController)
            return false
        }
    }
}

private extension YGDRouterManager {
    /// 根据打开方式选择最终要操作的导航栈。
    func makeNavigationController(for target: YGDRouteTarget, fallbackNavigationController: UINavigationController?) -> UINavigationController? {
        switch target.style {
        case .switchTabAndPush, .switchTabAndPopToExisting:
            guard let appNavigator else {
                return fallbackNavigationController
            }

            appNavigator.activateTab(target.tab)
            return appNavigator.navigationController(for: target.tab)

        case .push, .popToExisting:
            if let fallbackNavigationController {
                return fallbackNavigationController
            }

            return appNavigator?.currentNavigationController()
        }
    }

    /// 返回当前用于展示弹窗或 H5 的导航栈。
    func makePresentationNavigationController(fallbackNavigationController: UINavigationController?) -> UINavigationController? {
        if let fallbackNavigationController {
            return fallbackNavigationController
        }

        return appNavigator?.currentNavigationController()
    }

    /// 在指定导航栈中查找并回到已存在页面。
    func popToExistingViewControllerIfNeeded(target: YGDRouteTarget, in navigationController: UINavigationController) -> Bool {
        for viewController in navigationController.viewControllers.reversed() {
            guard let identifiableController = viewController as? YGDRouteStackIdentifiable else {
                continue
            }

            let sameRouteKey = identifiableController.routeKey == target.routeKey
            let sameIdentity = identifiableController.routeIdentity == target.identity
            let shouldMatchNilIdentity = target.identity == nil

            guard sameRouteKey else {
                continue
            }

            guard shouldMatchNilIdentity || sameIdentity else {
                continue
            }

            navigationController.popToViewController(viewController, animated: true)
            return true
        }

        return false
    }

    /// 展示路由被拦截时的提示弹窗。
    func presentBlockedAlert(message: String, on navigationController: UINavigationController) {
        let alertController = UIAlertController(title: "当前路由不可用", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "知道了", style: .default)
        alertController.addAction(confirmAction)

        if let topViewController = navigationController.topViewController {
            topViewController.present(alertController, animated: true)
            return
        }

        navigationController.present(alertController, animated: true)
    }
}

