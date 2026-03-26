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
            return "Today"
        case .tasks:
            return "Tasks"
        case .focus:
            return "Focus"
        case .insights:
            return "Insights"
        case .settings:
            return "Settings"
        }
    }

    /// 当前标签页的未选中图标名称。
    var symbolName: String {
        switch self {
        case .today:
            return "sun.max"
        case .tasks:
            return "checkmark.square"
        case .focus:
            return "scope"
        case .insights:
            return "chart.bar"
        case .settings:
            return "gearshape"
        }
    }

    /// 当前标签页的选中图标名称。
    var selectedSymbolName: String {
        switch self {
        case .today:
            return "sun.max.fill"
        case .tasks:
            return "checkmark.square.fill"
        case .focus:
            return "scope"
        case .insights:
            return "chart.bar.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
}
