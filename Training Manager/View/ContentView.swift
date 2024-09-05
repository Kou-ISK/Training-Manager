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
    
    var body: some View {
        TabView{
            TodaySessionView(trainingSessionList: trainingSessionList)
                .tabItem {
                    Label("新規セッション", systemImage: "tray.and.arrow.down.fill")
                }
            TrainingMenuHistory(trainingMenuList: trainingMenuList)
                .tabItem {
                    Label("メニュー履歴", systemImage: "doc.text")
                }
            TrainingSessionListView(trainingSessionList: trainingSessionList).tabItem {
                Label("セッション一覧", systemImage: "book.closed.fill")
            }
        }
    }
}

#Preview {
    ContentView()
}
