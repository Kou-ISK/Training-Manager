//
//  ContentView.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/27.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var trainingSessionList: [TrainingSession]
    
    var body: some View {
        TabView{
            TodaySessionView(trainingSessionList: trainingSessionList)
                .tabItem {
                    Label("今日のセッション", systemImage: "figure.run.circle.fill")
                }
            TrainingMenuHistory(trainingSessionList: trainingSessionList)
                .tabItem {
                    Label("メニュー履歴", systemImage: "doc.text")
                }
            TrainingSessionListView(trainingSessionList: trainingSessionList).tabItem {
                Label("セッション管理", systemImage: "calendar.circle")
            }
        }
    }
}

#Preview {
    ContentView()
}
