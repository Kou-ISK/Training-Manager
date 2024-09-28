//  TodaySessionView.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/30.
//

import SwiftUI

struct TodaySessionView: View {
    @StateObject var viewModel: TodaySessionViewModel
    
    @State private var editingMenu: TrainingMenu? // 編集中のメニューを保持
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            VStack {
                if let session = viewModel.currentTrainingSession {
                        HStack{
                            // セッションの削除
                            if viewModel.isEditMode {
                                    Button(action: {
                                        viewModel.isShowDeleteSessionAlert.toggle()
                                    }, label:{
                                        Image(systemName: "minus.circle.fill").foregroundStyle(.red)
                                    }).buttonStyle(.borderless).background(.clear)
                                        .alert("セッションの削除", isPresented: $viewModel.isShowDeleteSessionAlert, actions: {
                                            Button("削除", role: .destructive) {
                                                viewModel.deleteSession(session: session, modelContext: modelContext)
                                            }
                                            Button("キャンセル", role: .cancel) {}
                                        })
                            }
                            VStack(alignment: .center) {
                                Text(session.sessionDate ?? Date(), formatter: dateFormatter)
                                    .font(.headline)
                                Text(session.theme ?? "")
                                    .font(.subheadline)
                                Text(session.sessionDescription ?? "")
                            }
                        }
                        
                        if let menu = viewModel.currentTrainingMenu {
                            Divider()
                            VStack(alignment: .trailing){
                                    
                                    Button(action: {
                                        viewModel.currentTrainingMenu = nil
                                    }, label: {
                                        Image(systemName: "xmark.circle")
                                    }
                                    ).buttonStyle(.borderless)
                                
                                HStack(alignment: .top){
                                    VStack(alignment:.leading){
                                        Text(menu.name).font(.headline)
                                        Text(menu.goal)
                                        ForEach(menu.focusPoints, id:\.self){point in
                                            Text(point)
                                        }
                                    }.padding(.horizontal, 20)
                                    
                                    if let timerVM = viewModel.timerViewModel {
                                        TimerView(viewModel: timerVM).padding(.trailing, 20)
                                    }
                                }
                            }
                        }
                        
                        List{
                            ForEach(session.menus.sorted(by: { $0.orderIndex < $1.orderIndex }), id: \.self) { menu in
                                let isCurrentTraining = viewModel.currentTrainingMenu == menu
                                HStack {
                                    if viewModel.isEditMode {
                                        HStack{
                                            Button(action: {
                                                viewModel.isShowDeleteAlart.toggle()
                                            }, label:{
                                                Image(systemName: "minus.circle.fill").foregroundStyle(.red)
                                            }).buttonStyle(.borderless).background(.clear)
                                                .alert("メニューの削除", isPresented: $viewModel.isShowDeleteAlart, actions: {
                                                    Button("削除", role: .destructive) {
                                                        print(menu)
                                                        viewModel.deleteMenu(menu: menu, modelContext: modelContext)
                                                    }
                                                    Button("キャンセル", role: .cancel) {}
                                                })
                                        }
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(menu.name)
                                                .font(.headline)
                                        }
                                        Text(menu.goal)
                                            .font(.subheadline).underline()
                                        ForEach(menu.focusPoints, id:\.self){point in
                                            Text("・\(point)")
                                        }
                                        if(menu.menuDescription != "" || menu.menuDescription != nil){
                                            Text(menu.menuDescription ?? "").font(.caption).foregroundStyle(.gray)
                                        }
                                        
                                    }
                                    Spacer()
                                    if(viewModel.isEditMode){
                                        HStack{
                                            Button(action: {
                                                print("Edit button pressed")
                                                editingMenu = menu // 編集するメニューを設定
                                            }, label: {
                                                Text("編集")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.blue)
                                            })
                                            .buttonStyle(.borderless)
                                            .sheet(item: $editingMenu) { menuToEdit in
                                                EditTrainingMenuView(menu: menuToEdit, onSave: {
                                                    // onSave クロージャー内で保存処理を実行
                                                    viewModel.updateMenu(menu: menuToEdit, modelContext: modelContext)
                                                })
                                            }
                                            
                                            Image(systemName: "line.horizontal.3")
                                        }
                                    }else{
                                        VStack{
                                            HStack{
                                                Image(systemName: "stopwatch")
                                                Text(viewModel.formatDuration(duration: menu.duration ?? 0))
                                            }.foregroundStyle(.white).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).padding(5).background(.green).cornerRadius(30)
                                            
                                            Button(action: {
                                                viewModel.selectMenu(menu: menu)
                                            }, label: {
                                                Text(isCurrentTraining ? "実施中" : "開始").fontWeight(.bold)
                                            }).buttonStyle(.borderedProminent)
                                        }
                                    }
                                }
                            }.onMove { source, destination in
                                if viewModel.isEditMode {
                                    viewModel.moveMenu(from: source, to: destination, modelContext: modelContext)
                                }
                            }
                        }
                    
                } else {
                    Text("本日の日付のセッションが見つかりません")
                        .font(.headline)
                    Button("新規作成"){
                        viewModel.showNewSessionView()
                    }.buttonStyle(.borderless)
                }
            }.onAppear{
                viewModel.filterTodaySessions()
            }
            .sheet(isPresented: $viewModel.isShowAddView) {
                if let todaySession = viewModel.currentTrainingSession {
                    CreateTrainingMenuView(
                        session: todaySession, contentViewModel: viewModel.contentViewModel)
                }
            }
            .sheet(isPresented: $viewModel.isShowNewSessionView) {
                CreateTrainingSessionView(sessionDate: Date(),
                                          trainingSessionList: viewModel.contentViewModel.trainingSessionList, onSave: { newSession in
                    viewModel.addSession(newSession: newSession)
                })
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                            viewModel.showAddView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isEditMode.toggle()
                    } label: {
                        Text(viewModel.isEditMode ? "完了" : "編集")
                    }
                }
            }
        }
    }
}

#Preview {
    TodaySessionView(viewModel: TodaySessionViewModel(
        contentViewModel: ContentViewModel(trainingSessionList: [TrainingSession(
            theme: "テーマ",
            sessionDescription: "備考",
            sessionDate: Date(),
            menus: [TrainingMenu(
                name: "Name",
                goal: "Goal",
                duration: TimeInterval(600),
                focusPoints: ["kf1", "kf2", "kf3"],
                menuDescription: "description",
                orderIndex: 0
            )]
        )],
        trainingMenuList: [TrainingMenu(
            name: "Name",
            goal: "Goal",
            duration: TimeInterval(600),
            focusPoints: ["kf1", "kf2", "kf3"],
            menuDescription: "description",
            orderIndex: 0
        )])
    ))
}

#Preview {
    TodaySessionView(viewModel: TodaySessionViewModel(contentViewModel: ContentViewModel(
        trainingSessionList: [],
        trainingMenuList: []
        )
    ))
}
