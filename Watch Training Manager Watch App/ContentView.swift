//
//  ContentView.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import SwiftUI
import _SwiftData_SwiftUI

struct ContentView: View {
    
    @Query private var trainingSessionList: [TrainingSession]
    
    var todayTrainingSession: TrainingSession? { trainingSessionList.first{$0.sessionDate == Date()} ?? nil
    }
    
    var body: some View {
        TodaySessionView(todayTrainingSession: todayTrainingSession)
    }
}

#Preview {
    ContentView()
}
