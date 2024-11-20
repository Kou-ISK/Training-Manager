//
//  TrainingMenu.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/08/31.
//
//

import Foundation
import SwiftData

@Model public class TrainingMenu: Codable, Identifiable {
    public var id = UUID()
    var goal: String
    var menuDescription: String?
    var name: String
    var createdAt: Date
    var updatedAt: Date
    var duration: TimeInterval?
    var orderIndex: Int // 並び順を保持するためのプロパティ
    
    // focusPoints を [FocusPoint] 型で保持
    @Relationship var focusPoints: [FocusPoint] = []
    
    // 必須のイニシャライザ
    public init() {
        self.name = ""
        self.goal = ""
        self.createdAt = Date()
        self.updatedAt = Date()
        self.duration = nil
        self.orderIndex = 0
    }
    
    // focusPointsを[String]型で受け取るイニシャライザ
    public init(name: String, goal: String, duration: TimeInterval, focusPoints: [String], menuDescription: String?, orderIndex: Int) {
        self.name = name
        self.goal = goal
        self.duration = duration
        self.menuDescription = menuDescription
        self.orderIndex = orderIndex
        self.createdAt = Date()
        self.updatedAt = Date()
        
        // String 型の配列を FocusPoint 型の配列に変換
        self.focusPoints = focusPoints.map { FocusPoint(label: $0) }
    }
    
    // カスタムエンコードメソッド
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // 指定されたプロパティのみをエンコード
        try container.encode(goal, forKey: .goal)
        try container.encode(menuDescription, forKey: .menuDescription)
        try container.encode(name, forKey: .name)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(duration, forKey: .duration)
        try container.encode(orderIndex, forKey: .orderIndex)
        
        // focusPoints をエンコード
        let focusPointLabels = focusPoints.map { $0.label }
        try container.encode(focusPointLabels, forKey: .focusPoints)
    }
    
    // カスタムデコードメソッド
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 指定されたプロパティのみをデコード
        goal = try container.decode(String.self, forKey: .goal)
        menuDescription = try container.decodeIfPresent(String.self, forKey: .menuDescription)
        name = try container.decode(String.self, forKey: .name)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration)
        orderIndex = try container.decode(Int.self, forKey: .orderIndex)
        
        // focusPoints をデコードし、FocusPoint インスタンスに変換
        let focusPointLabels = try container.decode([String].self, forKey: .focusPoints)
        self.focusPoints = focusPointLabels.map { FocusPoint(label: $0) }
    }
    
    // Codableのためのキー
    enum CodingKeys: String, CodingKey {
        case goal
        case menuDescription
        case name
        case createdAt
        case updatedAt
        case duration
        case orderIndex
        case focusPoints
    }
}

@Model public class FocusPoint: Codable, Identifiable {
    public var id = UUID()
    var label: String
    
    public init(label: String) {
        self.label = label
    }
    
    // カスタムエンコードメソッド
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(label, forKey: .label)
    }
    
    // カスタムデコードメソッド
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        label = try container.decode(String.self, forKey: .label)
    }
    
    // Codableのためのキー
    enum CodingKeys: String, CodingKey {
        case label
    }
}
