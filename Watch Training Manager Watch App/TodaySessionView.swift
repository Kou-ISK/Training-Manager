//
//  TodaySessionView.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import SwiftUI

struct TodaySessionView: View {
    @EnvironmentObject var viewModel: TrainingSessionViewModel
    @Environment(\.modelContext) var modelContext
    @State private var isInitialLoadComplete = false
    @State private var showLoadingIndicator = false
    
    @StateObject var timerViewModel = TimerViewModel(initialTime: 0, menuName: "")
    
    @State var currentMenu: TrainingMenu? = nil
    
    var body: some View {
        VStack {
            if showLoadingIndicator {
                ProgressView("データを同期中...")
            } else {
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
                        List(session.menus.sorted(by: { firstMenu, secondMenu in
                            return firstMenu.orderIndex < secondMenu.orderIndex
                        }), id: \.self.id) { menu in
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
                                    withAnimation {
                                        showLoadingIndicator = true
                                        viewModel.sendMessage()
                                    }
                                }) {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                }.buttonStyle(.borderless)
                            }
                        }
                    }
                } else {
                    VStack {
                        Text("本日のセッションデータがありません")
                        Button("iPhone/iPadから取得") {
                            withAnimation {
                                showLoadingIndicator = true
                                viewModel.sendMessage()
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            // 初回のみ実行
            if !isInitialLoadComplete {
                // 少し遅延を入れてWCSessionの初期化を待つ
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showLoadingIndicator = true
                    viewModel.sendMessage()
                    isInitialLoadComplete = true
                }
            }
        }
        .onChange(of: viewModel.todayTrainingSession) { _ in
            // データ取得完了時にローディングを非表示
            showLoadingIndicator = false
        }
    }
}

#Preview {
    TodaySessionView()
}
