//
//  AppTab.swift
//  pigAreFlying
//
//  Created by Codex on 2026/3/25.
//

import Foundation

enum AppTab: Int {
    case today
    case tasks
    case focus
    case insights
    case settings

    /// 当前标签页的标题文案。
    var title: String {
        switch self {
        case .today:
            "Today"
        case .tasks:
            "Tasks"
        case .focus:
            "Focus"
        case .insights:
            "Insights"
        case .settings:
            "Settings"
        }
    }

    /// 当前标签页的未选中图标名称。
    var symbolName: String {
        switch self {
        case .today:
            "sun.max"
        case .tasks:
            "checkmark.square"
        case .focus:
            "scope"
        case .insights:
            "chart.bar"
        case .settings:
            "gearshape"
        }
    }

    /// 当前标签页的选中图标名称。
    var selectedSymbolName: String {
        switch self {
        case .today:
            "sun.max.fill"
        case .tasks:
            "checkmark.square.fill"
        case .focus:
            "scope"
        case .insights:
            "chart.bar.fill"
        case .settings:
            "gearshape.fill"
        }
    }
}
