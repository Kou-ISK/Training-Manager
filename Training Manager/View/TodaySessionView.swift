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
                                if(viewModel.isEditMode){
                                    Button(action: {
                                        viewModel.isShowDeleteAlart.toggle()
                                        
                                    }, label:{ Image(systemName: "minus.circle.fill").foregroundStyle(.red)})
                                    .alert("メニューの削除", isPresented: $viewModel.isShowDeleteAlart, actions: {
                                        Button("削除", role: .destructive) {
                                            viewModel.deleteMenu(menu: menu)
                                        }
                                        Button("キャンセル", role: .cancel) {}
                                    })
                                }
                                
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
                                if(viewModel.isEditMode){
                                    // TODO ドラッグして並び順を変更できるようにする
                                    Image(systemName: "line.horizontal.3")
                                }else{
                                    Button(action: {
                                        viewModel.selectMenu(menu: menu)
                                    }, label: {
                                        Text(isCurrentTraining ? "実施中" : "開始").fontWeight(.bold)
                                    }).buttonStyle(.borderedProminent)
                                }
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
                    CreateTrainingMenuView(session: todaySession, trainingMenuList: viewModel.trainingMenuList)
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isEditMode.toggle()
                    } label: {
                        Text(viewModel.isEditMode ? "キャンセル" : "編集")
                    }
                }
            }
        }
    }
}

#Preview {
    TodaySessionView(viewModel: TodaySessionViewModel(trainingSessionList: [TrainingSession(theme: "テーマ", sessionDescription: "備考", sessionDate: Date())], trainingMenuList: [TrainingMenu(name: "Name", goal: "Goal", duration: TimeInterval(600), keyFocus1: "kf1", keyFocus2: "kf2", keyFocus3: "kf3", menuDescription: "description")]))
}

#Preview {
    TodaySessionView(viewModel: TodaySessionViewModel(trainingSessionList: [], trainingMenuList: []))
}
