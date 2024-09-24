//
//  TodaySessionView.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import SwiftUI

struct TodaySessionView: View {
    var todayTrainingSession: TrainingSession
    
    var body: some View {
        VStack{
            NavigationStack{
                Text("本日のセッション")
                Text(todayTrainingSession.theme ?? "")
                ForEach(todayTrainingSession.menus){menu in
                    NavigationLink(menu.name, destination: TrainingMenuDetailView(menu: menu))
                }
            }
        }
        
    }
}

#Preview {
    TodaySessionView()
}
