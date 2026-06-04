//
//  String+YGD.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/5/14.
//

import Foundation

extension String {
    /// 去除首尾空格和换行后的字符串。
    func ygd_trimmed() -> String {
        if self.ygd_isNilOrEmpty() == true{
            return ""
        } else {
            return self.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    /// 判断字符串去除首尾空格和换行后是否为空。
    func ygd_isNilOrEmpty() -> Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}



