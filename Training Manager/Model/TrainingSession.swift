//
//  TrainingSession.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/08/31.
//
//

import Foundation
import SwiftData


@Model public class TrainingSession: Codable{
    var theme: String?
    var sessionDescription: String?
    var sessionDate: Date?
    var createdAt: Date?
    var updatedAt: Date?
    
    @Relationship
    var menus: [TrainingMenu]
    
    public init() {
        self.sessionDate = Date()
        self.menus = []
    }
    
    public init(sessionDate: Date) {
        self.sessionDate = sessionDate
        self.menus = []
    }
    
    public init(theme: String, sessionDescription: String, sessionDate: Date) {
        self.theme = theme
        self.sessionDescription = sessionDescription
        self.sessionDate = sessionDate
        self.menus = []
    }
    
    public init(theme: String, sessionDescription: String, sessionDate: Date, menus: [TrainingMenu]) {
        self.theme = theme
        self.sessionDescription = sessionDescription
        self.sessionDate = sessionDate
        self.menus = menus
    }
    
    
    // Decodableプロトコル準拠のためのイニシャライザ
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 各プロパティのデコード
        self.theme = try container.decodeIfPresent(String.self, forKey: .theme)
        self.sessionDescription = try container.decodeIfPresent(String.self, forKey: .sessionDescription)
        self.sessionDate = try container.decodeIfPresent(Date.self, forKey: .sessionDate)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.menus = try container.decodeIfPresent([TrainingMenu].self, forKey: .menus) ?? []
    }
    
    // Encodableプロトコル準拠のためのエンコードメソッド
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // 各プロパティをエンコード
        try container.encodeIfPresent(theme, forKey: .theme)
        try container.encodeIfPresent(sessionDescription, forKey: .sessionDescription)
        try container.encodeIfPresent(sessionDate, forKey: .sessionDate)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encode(menus, forKey: .menus) // メニューの配列をエンコード
    }
    
    // SwiftData のモデルを Codable に適応させるため、CodingKeys も定義
    enum CodingKeys: String, CodingKey {
        case theme
        case sessionDescription
        case sessionDate
        case createdAt
        case updatedAt
        case menus
    }
    
}
