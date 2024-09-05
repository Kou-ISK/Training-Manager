//
//  customDateFormatter.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/05.
//

import Foundation

// カスタムDateFormatterを定義
public var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .short // 日付スタイルを指定
    formatter.timeStyle = .none // 時間は表示しない
    return formatter
}
