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
    var goal: String?
    var keyFocus1: String?
    var keyFocus2: String?
    var keyFocus3: String?
    var menuDescription: String?
    var name: String?
    var createdAt: Date?
    var updatedAt: Date?
    var duration: TimeInterval? // durationを追加
    
    // TrainingMenu は複数の TrainingSession に属することができる
    @Relationship var sessions: [TrainingSession] = []
    
    public init() {

    }
    
}
