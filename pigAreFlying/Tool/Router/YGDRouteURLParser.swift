//
//  YGDRouteURLParser.swift
//  pigAreFlying
//
//  Created by Codex on 2026/5/15.
//

import Foundation

/// 路由 URL 解析工具，负责主键、参数和页面身份提取。
enum YGDRouteURLParser {
    /// 将 URL 转换成项目内部使用的路由主键。
    static func makeRouteKey(from url: URL) -> String {
        let routeSegments = [url.host, url.path]
            .compactMap { segment -> String? in
                guard let segment else {
                    return nil
                }

                let normalizedSegment = segment.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                return normalizedSegment.ygd_isNilOrEmpty() ? nil : normalizedSegment
            }

        return normalizeRouteKey(routeSegments.joined(separator: "/"))
    }

    /// 规范化输入的路由主键。
    static func normalizeRouteKey(_ routeKey: String) -> String {
        routeKey.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    /// 解析 URL 中携带的 query 参数。
    static func parseParameters(from url: URL) -> [String: String] {
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []

        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value ?? ""
        }
    }

    /// 从参数字典中提取页面身份标识。
    static func makeRouteIdentity(params: [String: String], identityParamKeys: [String]) -> String? {
        for key in identityParamKeys {
            guard let value = params[key], value.ygd_isNilOrEmpty() == false else {
                continue
            }

            return value
        }

        return nil
    }
}
