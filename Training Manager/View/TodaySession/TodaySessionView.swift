//  TodaySessionView.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/30.
//

import SwiftUI

struct TodaySessionView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State var trainingSessionList: [TrainingSession]
    
    @State private var editingMenu: TrainingMenu? // 編集中のメニューを保持
    
    @State private var currentTrainingSession: TrainingSession?
    @State private var currentTrainingMenu: TrainingMenu?
    @State private var timerViewModel: TimerViewModel? = nil
    
    @State private var isShowAddView: Bool = false
    @State private var isShowNewSessionView: Bool = false
    @State private var isShowSelectMenuView: Bool = false
    @State private var isEditMode: Bool = false
    @State private var isShowDeleteAlart: Bool = false
    @State private var isShowDeleteSessionAlert: Bool = false
    // 削除対象のメニューを保持するプロパティ
    @State private var menuToDelete: TrainingMenu?
    
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
    
    func formatDuration(duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func addSession(newSession: TrainingSession) {
        trainingSessionList.append(newSession)
        currentTrainingSession = newSession
        isShowNewSessionView = false
    }
    
    func addMenu(newMenu: TrainingMenu) {
        modelContext.insert(newMenu)
    }
    
    func showAddView() {
        isShowAddView = true
    }
    
    func showNewSessionView() {
        isShowNewSessionView = true
    }
    
    func dismissAddView() {
        isShowAddView = false
    }
    
    func dismissNewSessionView() {
        isShowNewSessionView = false
    }
    
    // メニューを削除する処理
    func deleteMenu(menu: TrainingMenu) {
        guard let session = trainingSessionList.first(where: {$0.id == currentTrainingSession?.id}) else { return }
        
        
        // session からメニューを削除
        if let index = session.menus.firstIndex(where: { $0.id == menu.id }) {
            session.menus.remove(at: index)
            
            // データベースから削除
            modelContext.delete(menu)
            // データベースに保存
            do {
                try modelContext.save() // 変更を保存
            } catch {
                print("Failed to save context: \(error)")
            }
            // 現在のメニューが削除されたメニューなら、別のメニューを選択する
            if currentTrainingMenu == menu {
                currentTrainingMenu = session.menus.first
            }
        }
    }
    
    func updateMenu(menu: TrainingMenu) {
        guard let session = trainingSessionList.first(where: {$0.id == currentTrainingSession?.id}) else { return }
        
        // session から該当のメニューを探す
        if let index = session.menus.firstIndex(where: { $0.id == menu.id }) {
            // メニューの更新
            session.menus[index] = menu
            
            // データベースに保存
            do {
                try modelContext.save() // 変更を保存
            } catch {
                print("Failed to save context: \(error)")
            }
            
            // 現在のメニューが更新されたメニューなら、最新の情報を反映
            if currentTrainingMenu?.id == menu.id {
                currentTrainingMenu = menu
            }
        }
    }
    
    // メニューを並び替えるロジック
    func moveMenu(from source: IndexSet, to destination: Int) {
        guard let session = trainingSessionList.first(where: {$0.id == currentTrainingSession?.id}) else { return }
        
        
        // メニューのリストをソートされた順序で取得
        var menus = session.menus.sorted(by: { $0.orderIndex < $1.orderIndex })
        
        // 並べ替えを適用
        menus.move(fromOffsets: source, toOffset: destination)
        
        // 新しい順序に基づいて orderIndex を再設定
        for (newIndex, menu) in menus.enumerated() {
            menu.orderIndex = newIndex
        }
        
        // トレーニングセッションに新しい順序を適用
        session.menus = menus
        
        // データベースに保存
        do {
            try modelContext.save() // 変更を保存
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // セッションを削除する処理
    func deleteSession(session: TrainingSession) {
        trainingSessionList.removeAll(where: {$0.id == session.id})
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
            VStack {
                if let session = currentTrainingSession {
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
                        VStack(alignment: .center) {
                            Text(session.sessionDate ?? Date(), formatter: dateFormatter)
                                .font(.headline)
                            Text(session.theme ?? "")
                                .font(.subheadline)
                            Text(session.sessionDescription ?? "")
                        }
                    }
                    
                    if let menu = currentTrainingMenu {
                        Divider()
                        VStack(alignment: .trailing){
                            
                            Button(action: {
                                currentTrainingMenu = nil
                            }, label: {
                                Image(systemName: "xmark.circle")
                            }
                            ).buttonStyle(.borderless)
                            
                            HStack(alignment: .top){
                                VStack(alignment:.leading){
                                    Text(menu.name).font(.headline)
                                    Text(menu.goal)
                                    ForEach(menu.focusPoints, id:\.id){point in
                                        Text(point.label)
                                    }
                                }.padding(.horizontal, 20)
                                
                                if let timerVM = timerViewModel {
                                    TimerView(viewModel: timerVM).padding(.trailing, 20)
                                }
                            }
                        }
                    }
                    
                    List{
                        ForEach(session.menus.sorted(by: { $0.orderIndex < $1.orderIndex }), id: \.self) { menu in
                            let isCurrentTraining = currentTrainingMenu == menu
                            HStack {
                                if isEditMode {
                                    HStack{
                                        Button(action: {
                                            menuToDelete = menu // 削除対象のメニューを設定
                                            isShowDeleteAlart.toggle()
                                        }, label:{
                                            Image(systemName: "minus.circle.fill").foregroundStyle(.red)
                                        }).buttonStyle(.borderless).background(.clear)
                                            .alert("メニューの削除", isPresented: $isShowDeleteAlart, actions: {
                                                Button("削除", role: .destructive) {
                                                    print(menu)
                                                    if let menuToDelete = menuToDelete {
                                                        deleteMenu(menu: menuToDelete, modelContext: modelContext) // 削除対象のメニューを削除
                                                    }
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
                                    ForEach(menu.focusPoints, id:\.id){point in
                                        Text("・\(point.label)")
                                    }
                                    if(menu.menuDescription != "" || menu.menuDescription != nil){
                                        Text(menu.menuDescription ?? "").font(.caption).foregroundStyle(.gray)
                                    }
                                    
                                }
                                Spacer()
                                if(isEditMode){
                                    HStack{
                                        Button(action: {
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
                                                updateMenu(menu: menuToEdit, modelContext: modelContext)
                                            })
                                        }
                                        
                                        Image(systemName: "line.horizontal.3")
                                    }
                                }else{
                                    VStack{
                                        HStack{
                                            Image(systemName: "stopwatch")
                                            Text(formatDuration(duration: menu.duration ?? 0))
                                        }.foregroundStyle(.white).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).padding(5).background(.green).cornerRadius(30)
                                        
                                        Button(action: {
                                            selectMenu(menu: menu)
                                        }, label: {
                                            Text(isCurrentTraining ? "実施中" : "開始").fontWeight(.bold)
                                        }).buttonStyle(.borderedProminent)
                                    }
                                }
                            }
                        }.onMove { source, destination in
                            if isEditMode {
                                moveMenu(from: source, to: destination)
                            }
                        }.moveDisabled(!isEditMode)// 編集モードでない場合はリスト項目を移動できないようにする
                    }
                    
                } else {
                    Text("本日の日付のセッションが見つかりません")
                        .font(.headline)
                    Button("新規作成"){
                        showNewSessionView()
                    }.buttonStyle(.borderless)
                }
            }.onAppear{
                filterTodaySessions()
            }
            .sheet(isPresented: $isShowAddView) {
                if let todaySession = currentTrainingSession {
                    CreateTrainingMenuView(
                        session: todaySession)
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
                        showAddView()
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
