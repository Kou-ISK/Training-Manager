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
    @Query private var trainingMenuList: [TrainingMenu]
    
    // ContentViewModel を @StateObject として宣言
    @StateObject private var contentViewModel = ContentViewModel(trainingSessionList: [], trainingMenuList: [])
    
    var body: some View {
        Button("Crash") {
          fatalError("Crash was triggered")
        }
        TabView{
            TodaySessionView(viewModel: TodaySessionViewModel(contentViewModel: contentViewModel))
                .tabItem {
                    Label("今日のセッション", systemImage: "figure.run.circle.fill")
                }
            TrainingMenuHistory(contentViewModel: contentViewModel)
                .tabItem {
                    Label("メニュー履歴", systemImage: "doc.text")
                }
            TrainingSessionListView(contentViewModel: contentViewModel).tabItem {
                Label("セッション管理", systemImage: "calendar.circle")
            }
        }.onAppear {
            // 初期データを ViewModel にセット
            contentViewModel.trainingSessionList = trainingSessionList
            contentViewModel.trainingMenuList = trainingMenuList
        }
    }
}

#Preview {
    ContentView()
}
