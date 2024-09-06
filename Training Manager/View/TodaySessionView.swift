//  TodaySessionView.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/30.
//

import SwiftUI

struct TodaySessionView: View {
    @StateObject var viewModel: TodaySessionViewModel
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            VStack {
                if let session = viewModel.currentTrainingSession {
                    VStack(alignment: .center) {
                        Text(session.sessionDate ?? Date(), formatter: dateFormatter)
                            .font(.title)
                        Text(session.theme ?? "")
                            .font(.title2)
                        Text(session.sessionDescription ?? "")
                        
                        if let menu = viewModel.currentTrainingMenu {
                            HStack(alignment: .center) {
                                VStack(alignment: .center) {
                                    Text(menu.name ?? "N/A").font(.title)
                                        .padding(5)
                                    Text("フォーカスポイント: ")
                                    Text(menu.keyFocus1 ?? "")
                                    Text(menu.keyFocus2 ?? "")
                                    Text(menu.keyFocus3 ?? "")
                                }
                                if let timerVM = viewModel.timerViewModel {
                                    TimerView(viewModel: timerVM)
                                }
                            }
                        }
                        
                        List(session.menus) { menu in
                            let isCurrentTraining = viewModel.currentTrainingMenu == menu
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(menu.name ?? "")
                                            .font(.title)
                                        Text(viewModel.formatDuration(duration: menu.duration ?? 0))
                                    }
                                    Text(menu.goal ?? "")
                                        .font(.title2)
                                    Text(menu.keyFocus1 ?? "")
                                    Text(menu.keyFocus2 ?? "")
                                    Text(menu.keyFocus3 ?? "")
                                }
                                Spacer()
                                Button(action: {
                                    viewModel.selectMenu(menu: menu)
                                }, label: {
                                    Text(isCurrentTraining ? "実施中" : "開始").fontWeight(.bold)
                                }).buttonStyle(.borderedProminent)
                            }
                        }
                    }
                } else {
                    Text("本日の日付のセッションが見つかりません")
                        .font(.headline)
                    Text("右上のボタンからセッションを追加")
                        .font(.subheadline)
                }
            }
            .sheet(isPresented: $viewModel.isShowAddView) {
                if let todaySession = viewModel.currentTrainingSession {
                    CreateTrainingMenuView(session: todaySession)
                }
            }
            .sheet(isPresented: $viewModel.isShowNewSessionView) {
                CreateTrainingSessionView(onSave: { newSession in
                    viewModel.addSession(newSession: newSession)
                })
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if viewModel.currentTrainingSession == nil {
                            viewModel.showNewSessionView()
                        } else {
                            viewModel.showAddView()
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    TodaySessionView(viewModel: TodaySessionViewModel(trainingSessionList: [TrainingSession(theme: "テーマ", sessionDescription: "備考", sessionDate: Date())]))
}

#Preview {
    TodaySessionView(viewModel: TodaySessionViewModel(trainingSessionList: []))
}
