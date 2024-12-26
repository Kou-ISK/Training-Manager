//  TodaySessionView.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/30.
//

import SwiftUI

struct TodaySessionView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State var trainingSessionList: [TrainingSession]
    
    @State private var currentTrainingSession: TrainingSession?
    @State private var currentTrainingMenu: TrainingMenu?
    @State private var timerViewModel: TimerViewModel? = nil
    
    @State private var isShowAddView: Bool = false
    @State private var isShowNewSessionView: Bool = false
    @State private var isShowSelectMenuView: Bool = false
    @State private var isEditMode: Bool = false
    @State private var isShowDeleteSessionAlert: Bool = false
    
    func filterTodaySessions() {
        let today = Calendar.current.startOfDay(for: Date())
        if let session = trainingSessionList.first(where: { session in
            guard let sessionDate = session.sessionDate else { return false }
            let isSameDay = Calendar.current.isDate(sessionDate, inSameDayAs: today)
            return isSameDay
        }) {
            currentTrainingSession = session
        } else {
            currentTrainingSession = nil
        }
    }
    
    func selectMenu(menu: TrainingMenu) {
        currentTrainingMenu = menu
        
        // もし TimerViewModel が存在している場合は停止する
        timerViewModel?.stop()
        
        // 新しいメニューに基づいて TimerViewModel を再初期化
        timerViewModel = TimerViewModel(initialTime: menu.duration ?? 0, menuName: menu.name)
    }
    
    func addSession(newSession: TrainingSession) {
        trainingSessionList.append(newSession)
        modelContext.insert(newSession)
        currentTrainingSession = newSession
        isShowNewSessionView = false
        // データベースに保存
        do {
            try modelContext.save() // 変更を保存
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // セッションを削除する処理
    func deleteSession(session: TrainingSession) {
        modelContext.delete(session.self)
        // データベースに保存
        do {
            try modelContext.save() // 変更を保存
        } catch {
            print("Failed to save context: \(error)")
        }
        currentTrainingSession = nil
    }
    
    // TODO: コンポーネントに切り分ける
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                if let session = currentTrainingSession {
                    ZStack{
                        VStack(alignment: .leading) {
                            // ヘッダー部
                            // TODO: ヘッダー部をSessionDetailViewのものと共通に出来るか検討
                            HStack{
                                // セッションの削除
                                if isEditMode {
                                    Button(action: {
                                        isShowDeleteSessionAlert.toggle()
                                    }, label:{
                                        Image(systemName: "minus.circle.fill").foregroundStyle(.red)
                                    }).buttonStyle(.borderless).background(.clear)
                                        .alert("セッションの削除", isPresented: $isShowDeleteSessionAlert, actions: {
                                            Button("削除", role: .destructive) {
                                                deleteSession(session: session)
                                                isEditMode.toggle()
                                            }
                                            Button("キャンセル", role: .cancel) {}
                                        })
                                }
                                VStack(alignment: .leading) {
                                    Text(currentTrainingSession?.sessionDate ?? Date(), formatter: dateFormatter)
                                    Text("テーマ: \(session.theme ?? "")")
                                        .font(.subheadline)
                                    Text("備考: \(session.sessionDescription ?? "")")
                                }.padding(8)
                            }.padding(.horizontal, 8)
                            TrainingMenuList(menus: session.menus, trainingSessionList: trainingSessionList, isEditMode: isEditMode, currentTrainingMenu: $currentTrainingMenu, currentTrainingSession: $currentTrainingSession, selectMenu: selectMenu)
                            Spacer()
                        }
                        
                        // フローティングのコントローラー
                        if currentTrainingMenu != nil {
                            VStack{
                                Spacer()
                                HStack(alignment: .top){
                                    Spacer().frame(width: 8) // 左側の余白
                                    HStack(alignment: .top){
                                        HStack(alignment: .center){
                                            Text(currentTrainingMenu?.name ?? "").padding(8)
                                            Spacer()
                                            if let timerVM = timerViewModel {
                                                TimerView(viewModel: timerVM)
                                            }
                                        }
                                        Button(action: {
                                            currentTrainingMenu = nil
                                        }, label: {
                                            Image(systemName: "xmark.circle")
                                        }
                                        ).buttonStyle(.borderless).padding(4)
                                    }.frame(maxWidth: .infinity, maxHeight: 64)
                                        .background(Color.gray.opacity(0.2)) // 背景色を適用
                                        .cornerRadius(8) // 背景色の角を丸める
                                    Spacer().frame(width: 8) // 左側の余白
                                }
                            }
                        }
                    }
                } else {
                    Text("本日の日付のセッションが見つかりません")
                        .font(.headline)
                    Button("新規作成"){
                        isShowNewSessionView.toggle()
                    }.buttonStyle(.borderless)
                }
            }.onAppear{
                filterTodaySessions()
            }
            .sheet(isPresented: $isShowAddView) {
                // TODO: メニュー追加されない事象に対応
                if let todaySession = currentTrainingSession {
                    CreateTrainingMenuView(
                        session: Binding(
                            get: { todaySession },
                            set: { currentTrainingSession = $0 }
                        ), trainingSessionList: $trainingSessionList)
                }
            }
            .sheet(isPresented: $isShowNewSessionView) {
                CreateTrainingSessionView(sessionDate: Date(), trainingSessionList: trainingSessionList, onSave: { newSession in
                    addSession(newSession: newSession)
                })
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowAddView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }.disabled(currentTrainingSession == nil)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isEditMode.toggle()
                    } label: {
                        Text(isEditMode ? "完了" : "編集")
                    }
                }
            }
        }
    }
}

#Preview {
    TodaySessionView(
        trainingSessionList: [TrainingSession(
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
            )])
        ]
    )
}

#Preview{
    TodaySessionView(
        trainingSessionList: []
    )
}
