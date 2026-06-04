//
//  YGDRouteModels.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/27.
//

import UIKit

/// 协调器工厂闭包，用于根据路由目标构建具体业务协调器。
typealias YGDCoordinatorFactory = (YGDRouteTarget) -> Coordinator

/// 路由打开方式。
enum YGDRouteOpenStyle {
    /// 在当前导航栈中继续 push。
    case push
    /// 在当前导航栈中优先回到已存在页面，找不到再 push。
    case popToExisting
    /// 先切换到目标 Tab，再 push。
    case switchTabAndPush
    /// 先切换到目标 Tab，再优先回到已存在页面，找不到再 push。
    case switchTabAndPopToExisting
    /// 是否应该优先回到栈内已存在页面。
    var shouldPopToExisting: Bool {
        switch self {
        case .push, .switchTabAndPush:
            false
        case .popToExisting, .switchTabAndPopToExisting:
            true
        }
    }
}

/// 一次完整的路由意图。
struct YGDRouteIntent {
    /// 原始路由地址。
    let urlString: String
    /// 业务补充参数。
    let extraParams: [String: String]
    /// 打开方式。
    let style: YGDRouteOpenStyle
}

/// 远端规则命中后的动作类型。
enum YGDRemoteRouteAction {
    /// 将旧 URL 前缀改写成新 URL 前缀。
    case rewrite(targetPrefix: String)
    /// 强制命中指定原生版本，用于灰度或 A/B 场景。
    case forceNativeVersion(String)
    /// 降级到指定 H5 地址，原生页未就绪时的兜底方案。
    case degradeToWeb(String)
    /// 直接拦截当前请求。
    case block(String)
}

/// 一条由后端控制塔下发的路由规则。
struct YGDRemoteRouteRule {
    /// 规则命中的 URL 前缀。
    let matchPrefix: String
    /// 规则命中后执行的动作。
    let action: YGDRemoteRouteAction

    /// 判断当前规则是否命中指定 URL。
    func matches(_ urlString: String) -> Bool {
        urlString.hasPrefix(self.matchPrefix)
    }
}

/// Router 解析完成后的标准业务目标。
struct YGDRouteTarget {
    /// 目标所属的 Tab。
    let tab: AppTab
    /// 目标业务路由主键。
    let routeKey: String
    /// 目标业务版本。
    let version: String
    /// 最终要传给业务的参数字典。
    let params: [String: String]
    /// 当前路由的打开方式。
    let style: YGDRouteOpenStyle
    /// 当前路由对应的页面身份标识。
    let identity: String?
}

/// 已注册的原生路由项，代表一个可执行的本地业务节点。
struct YGDNativeRouteItem {
    /// 该路由对应的默认 Tab。
    let tab: AppTab
    /// 用于提取页面身份标识的参数键，取第一个有效值。
    let identityParamKeys: [String]
    /// 当前路由命中后创建协调器的工厂闭包。
    let coordinatorFactory: YGDCoordinatorFactory
}
