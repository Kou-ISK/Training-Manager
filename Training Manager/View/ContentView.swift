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
            CreateTrainingSessionView(trainingSessionList: trainingSessionList)
                .tabItem {
                    Label("新規トレーニング", systemImage: "tray.and.arrow.down.fill")
                }
            Load_Old_Training()
                .tabItem {
                    Label("トレーニング履歴", systemImage: "book")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
