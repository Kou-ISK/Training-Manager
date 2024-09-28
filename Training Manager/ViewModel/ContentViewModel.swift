//
//  ContentViewModel.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/27.
//

import Foundation
import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    @Published var trainingSessionList: [TrainingSession]
    @Published var trainingMenuList: [TrainingMenu]
    
    init(trainingSessionList: [TrainingSession], trainingMenuList: [TrainingMenu]) {
        self.trainingSessionList = trainingSessionList
        self.trainingMenuList = trainingMenuList
    }

    func addMenuToSession(newMenu: TrainingMenu, session: TrainingSession){
        session.menus.append(newMenu)
        trainingMenuList.append(newMenu)
    }
    
    func addSession(newSession: TrainingSession) {
        trainingSessionList.append(newSession)
    }
}
