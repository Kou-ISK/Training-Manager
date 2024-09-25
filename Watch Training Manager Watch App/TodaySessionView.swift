//
//  TodaySessionView.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import SwiftUI

struct TodaySessionView: View {
    @EnvironmentObject var viewModel: TrainingSessionViewModel
    
    var body: some View {
        VStack{
            NavigationStack{
                if let session = viewModel.todayTrainingSession {
                    Text("本日のセッション")
                    Text(session.theme ?? "")
                    ForEach(session.menus){menu in
                        NavigationLink(menu.name, destination: TrainingMenuDetailView(menu: menu))
                    }
                }else{
                    Text("本日のセッションデータがありません")
                    Button("リクエスト"){
                        viewModel.sendMessage()
                    }
                }
            }
        }.onAppear{
            viewModel.sendMessage()
            print("アクセスはしてみた")
        }
        
    }
}

#Preview {
    TodaySessionView()
}
