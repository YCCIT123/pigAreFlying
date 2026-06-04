//
//  YGDModuleIndexBootstrap.swift
//  YGDModuleIndexKit
//
//  Created by yangchengcheng on 2026/6/4.
//

import YGDFocusModule
import YGDInsightsModule
import YGDModuleBridgeKit
import YGDSettingsModule
import YGDTasksModule
import YGDTodayModule

/// 业务模块索引启动器，集中引入并注册所有业务模块。
public enum YGDModuleIndexBootstrap {
    /// 向模块注册表注册全部业务模块。
    public static func registerAllModules() {
        let registry = YGDFeatureModuleRegistry.shared

        registry.register(YGDTodayModule())
        registry.register(YGDTasksModule())
        registry.register(YGDFocusModule())
        registry.register(YGDInsightsModule())
        registry.register(YGDSettingsModule())
    }
}

