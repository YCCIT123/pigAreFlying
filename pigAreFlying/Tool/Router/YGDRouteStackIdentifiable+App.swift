//
//  YGDRouteStackIdentifiable+App.swift
//  pigAreFlying
//
//  Created by Codex on 2026/5/15.
//

import Foundation

/// Today 根页面对应的路由身份扩展。
extension TodayViewController: YGDRouteStackIdentifiable {
    /// 当前页面对应的业务路由主键。
    var routeKey: String {
        "today/home"
    }

    /// 当前页面的业务身份标识。
    var routeIdentity: String? {
        nil
    }
}

/// Tasks 根页面对应的路由身份扩展。
extension TasksViewController: YGDRouteStackIdentifiable {
    /// 当前页面对应的业务路由主键。
    var routeKey: String {
        "tasks/home"
    }

    /// 当前页面的业务身份标识。
    var routeIdentity: String? {
        nil
    }
}

/// Focus 根页面对应的路由身份扩展。
extension FocusViewController: YGDRouteStackIdentifiable {
    /// 当前页面对应的业务路由主键。
    var routeKey: String {
        "focus/home"
    }

    /// 当前页面的业务身份标识。
    var routeIdentity: String? {
        nil
    }
}

/// Insights 根页面对应的路由身份扩展。
extension InsightsViewController: YGDRouteStackIdentifiable {
    /// 当前页面对应的业务路由主键。
    var routeKey: String {
        "insights/home"
    }

    /// 当前页面的业务身份标识。
    var routeIdentity: String? {
        nil
    }
}

/// Settings 根页面对应的路由身份扩展。
extension SettingsViewController: YGDRouteStackIdentifiable {
    /// 当前页面对应的业务路由主键。
    var routeKey: String {
        "settings/home"
    }

    /// 当前页面的业务身份标识。
    var routeIdentity: String? {
        nil
    }
}
