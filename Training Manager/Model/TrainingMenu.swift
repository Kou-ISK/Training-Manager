//
//  TrainingMenu.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/08/31.
//
//

import Foundation
import SwiftData


@Model public class TrainingMenu {
    var goal: String
    var menuDescription: String?
    var name: String
    var createdAt: Date
    var updatedAt: Date
    var duration: TimeInterval?
    var orderIndex: Int // 並び順を保持するためのプロパティ
    
    // 内部的に保存されるString型のプロパティ
    private var focusPointsString: String?

    // カスタムプロパティで、配列をStringに変換して保存し、取り出すときに再度配列に変換
    var focusPoints: [String] {
        get {
            focusPointsString?.components(separatedBy: ",") ?? []
        }
        set {
            focusPointsString = newValue.joined(separator: ",")
        }
    }
    
    // TrainingMenu は複数の TrainingSession に属することができる
    @Relationship var sessions: [TrainingSession] = []
    
    // 必須のイニシャライザ
     public init() {
         self.name = ""
         self.goal = ""
         self.createdAt = Date()
         self.updatedAt = Date()
         self.duration = nil
         self.orderIndex = 0 // 初期値として 0 を設定
     }
     
     public init(name: String, goal: String, duration: TimeInterval, focusPoints: [String], menuDescription: String, orderIndex: Int) {
         self.name = name
         self.goal = goal
         self.duration = duration
         self.menuDescription = menuDescription
         self.orderIndex = orderIndex
         self.createdAt = Date() // 初期値として現在日時を設定
         self.updatedAt = Date() // 初期値として現在日時を設定
         self.focusPointsString = focusPoints.joined(separator: ",") // focusPointsを文字列に変換して保存
     }
    
}
