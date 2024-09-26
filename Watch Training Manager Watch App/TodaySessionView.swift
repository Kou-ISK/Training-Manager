//
//  TodaySessionView.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import SwiftUI

struct TodaySessionView: View {
    @EnvironmentObject var viewModel: TrainingSessionViewModel
    @StateObject var timerViewModel = TimerViewModel(initialTime: 0, menuName: "")
    
    @State var currentMenu: TrainingMenu? = nil

    var body: some View {
        VStack {
                if let session = viewModel.todayTrainingSession {
                        if (currentMenu != nil){
                            VStack{
                                HStack{
                                    VStack{
                                        Text(currentMenu!.name)
                                    }
                                    TimerView(viewModel: timerViewModel)
                                }
                                ScrollView{
                                    Text(currentMenu!.goal)
                                    ForEach(currentMenu!.focusPoints, id:\.self){point in
                                        Text("・\(point)")
                                    }
                                }.frame(height: 40)
                            }.frame(height: 80)
                        }
                    
                    List(session.menus, id:\.self.id) { menu in
                        HStack{
                            HStack{
                                Image(systemName: "stopwatch")
                                Text(viewModel.formatDuration(duration: menu.duration ?? 0))
                            }.foregroundStyle(.white).fontWeight(.bold).padding(5).background(.green).cornerRadius(30)
                            Button(action: {
                                currentMenu = menu
                                // メニューを選択したらタイマーをセット
                                timerViewModel.setRemainingTime(time: menu.duration ?? 0, menuName: menu.name)
                            }) {
                                Text(menu.name)
                            }
                        }
                    }
                } else {
                    Text("本日のセッションデータがありません")
                    Button("iPhone/iPadから取得") {
                        viewModel.sendMessage()
                    }
                }
            }
        .onAppear {
            viewModel.sendMessage()
        }
    }
}


#Preview {
    TodaySessionView()
}
