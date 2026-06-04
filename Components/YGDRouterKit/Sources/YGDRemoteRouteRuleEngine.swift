//
//  YGDRemoteRouteRuleEngine.swift
//  YGDRouterKit
//
//  Created by yangchengcheng on 2026/6/4.
//

import Foundation

/// 远端路由规则处理器，负责 rewrite、强制版本、H5 降级和拦截。
final class YGDRemoteRouteRuleEngine {
    /// 当前生效的远端规则表。
    private var rules: [YGDRemoteRouteRule] = []

    /// 批量替换当前远端规则。
    func applyRules(_ rules: [YGDRemoteRouteRule]) {
        self.rules = rules
    }

    /// 执行远端规则，产出最终可分发的路由上下文。
    func resolve(urlString: String) -> YGDRouteResolutionContext {
        var workingURLString = urlString
        var forcedVersion: String?

        for rule in rules where rule.matches(workingURLString) {
            switch rule.action {
            case let .rewrite(targetPrefix):
                workingURLString = rewritePrefix(in: workingURLString, sourcePrefix: rule.matchPrefix, targetPrefix: targetPrefix)
            case let .forceNativeVersion(version):
                forcedVersion = version
            case let .degradeToWeb(urlString):
                let webURL = URL(string: urlString)
                return YGDRouteResolutionContext(finalURLString: workingURLString, forcedVersion: forcedVersion, blockedMessage: webURL == nil ? "降级地址无效: \(urlString)" : nil, webURL: webURL)
            case let .block(message):
                return YGDRouteResolutionContext(finalURLString: workingURLString, forcedVersion: forcedVersion, blockedMessage: message, webURL: nil)
            }
        }

        return YGDRouteResolutionContext(finalURLString: workingURLString, forcedVersion: forcedVersion, blockedMessage: nil, webURL: nil)
    }

    /// 仅重写 URL 开头命中的前缀，避免误改 query 或其他片段。
    private func rewritePrefix(in urlString: String, sourcePrefix: String, targetPrefix: String) -> String {
        guard urlString.hasPrefix(sourcePrefix) else {
            return urlString
        }

        let suffix = urlString.dropFirst(sourcePrefix.count)
        return targetPrefix + suffix
    }
}

