//
//  AppTab.swift
//  YGDCoreKit
//
//  Created by yangchengcheng on 2026/6/4.
//

import Foundation

/// 应用主标签页类型。
public enum AppTab: Int, CaseIterable {
    /// 今日标签页。
    case today
    /// 任务标签页。
    case tasks
    /// 专注标签页。
    case focus
    /// 统计标签页。
    case insights
    /// 设置标签页。
    case settings

    /// 当前标签页的标题文案。
    public var title: String {
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
    public var symbolName: String {
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
    public var selectedSymbolName: String {
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

