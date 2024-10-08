//
//  TodaySessionView.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import SwiftUI

struct TodaySessionView: View {
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject var viewModel: TrainingSessionViewModel
    @StateObject var timerViewModel = TimerViewModel(initialTime: 0, menuName: "")
    
    @State var currentMenu: TrainingMenu? = nil
    
    var body: some View {
        VStack {
            if let session = viewModel.todayTrainingSession {
                if let menu = currentMenu {
                    VStack{
                        HStack{
                            VStack{
                                Text(menu.name)
                            }
                            TimerView(viewModel: timerViewModel)
                        }
                        ScrollView{
                            Text(menu.goal)
                            ForEach(menu.focusPoints, id: \.self){ point in
                                Text("・\(point.label)")
                            }
                        }.frame(height: 40)
                    }.frame(height: 80)
                }
                ZStack{
                    List(session.menus, id: \.self.id) { menu in
                        HStack{
                            HStack{
                                Text(viewModel.formatDuration(duration: menu.duration ?? 0))
                            }
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .padding(3)
                            .background(.green)
                            .cornerRadius(30)
                            
                            Button(action: {
                                currentMenu = menu
                                // メニューを選択したらタイマーをセット
                                timerViewModel.setRemainingTime(time: menu.duration ?? 0, menuName: menu.name)
                                print("Selected menu: \(menu.name)")
                            }) {
                                Text(menu.name)
                            }
                        }
                    }
                    // フローティングリロードボタン
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.sendMessage()
                                viewModel.deleteOldSessions(modelContext: modelContext)
                            }) {
                                Image(systemName: "arrow.clockwise.circle.fill")
                            }.buttonStyle(.borderless)
                        }
                    }
                }
            } else {
                Text("本日のセッションデータがありません")
                Button("iPhone/iPadから取得") {
                    viewModel.sendMessage()
                    viewModel.deleteOldSessions(modelContext: modelContext)
                }
            }
        }
        .onAppear {
            viewModel.sendMessage()
            // 古いセッションを削除
            viewModel.deleteOldSessions(modelContext: modelContext)
        }
    }
}

#Preview {
    TodaySessionView()
}
