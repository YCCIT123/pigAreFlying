//
//  YGDFeatureModule.swift
//  YGDModuleBridgeKit
//
//  Created by yangchengcheng on 2026/6/4.
//

import UIKit
import YGDCoreKit
import YGDRouterKit

/// 业务模块统一入口协议。
public protocol YGDFeatureModule {
    /// 当前模块所属的主标签页。
    var tab: AppTab { get }

    /// 创建当前模块的首页控制器。
    func makeRootViewController() -> UIViewController

    /// 注册当前模块持有的全部路由。
    func registerRoutes(to router: YGDRouterManager)
}

