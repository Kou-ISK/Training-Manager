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
    public var id: UUID?
    var menuId: String?
    var sessionId: String?
    var sessionDate: Date?
    var duration: Int64?
    var createdAt: Date?
    var updatedAt: Date?
    
    public init() {

    }
    
}
