//
//  TrainingSession.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/08/31.
//
//

import Foundation
import SwiftData


@Model public class TrainingSession {
    var theme: String?
    var sessionDescription: String?
    var sessionDate: Date?
    var createdAt: Date?
    var updatedAt: Date?
    
    // 多対多のリレーションシップ
    @Relationship var menus: [TrainingMenu] = []
    
    public init() {

    }
    
}
