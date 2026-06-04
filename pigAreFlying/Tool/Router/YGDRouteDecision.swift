//
//  YGDRouteDecision.swift
//  pigAreFlying
//
//  Created by Codex on 2026/5/15.
//

import Foundation

/// Router 在执行远端规则后的中间态结果。
struct YGDRouteResolutionContext {
    /// 规则处理后的最终 URL。
    let finalURLString: String

    /// 规则强制指定的原生版本。
    let forcedVersion: String?

    /// 是否已经被远端规则直接拦截。
    let blockedMessage: String?

    /// 是否已经被远端规则直接降级到 H5。
    let webURL: URL?
}

/// Router 最终的执行决策。
enum YGDRouteDecision {
    /// 命中原生路由，交给对应 Coordinator 构建页面。
    case native(item: YGDNativeRouteItem, target: YGDRouteTarget)

    /// 命中远端 H5 降级。
    case web(url: URL)

    /// 当前路由被拦截。
    case blocked(message: String)
}
