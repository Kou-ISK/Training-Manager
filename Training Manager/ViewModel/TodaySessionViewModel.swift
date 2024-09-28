//
//  TodaySessionViewModel.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/06.
//

import SwiftUI
import Combine
import SwiftData

class TodaySessionViewModel: ObservableObject {
    @State var contentViewModel: ContentViewModel
    
    @Published var currentTrainingSession: TrainingSession?
    @Published var currentTrainingMenu: TrainingMenu?
    @Published var timerViewModel: TimerViewModel? = nil
    
    @Published var isShowAddView: Bool = false
    @Published var isShowNewSessionView: Bool = false
    @Published var isShowSelectMenuView: Bool = false
    @Published var isEditMode: Bool = false
    @Published var isShowDeleteAlart: Bool = false
    @Published var isShowDeleteSessionAlert: Bool = false
    
    init(contentViewModel: ContentViewModel) {
        self.contentViewModel = contentViewModel
        filterTodaySessions()
    }
    
    func filterTodaySessions() {
        let today = Calendar.current.startOfDay(for: Date())
        if let session = contentViewModel.trainingSessionList.first(where: { session in
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
        contentViewModel.trainingSessionList.append(newSession)
        if(!newSession.menus.isEmpty){
            for menu in newSession.menus {
                contentViewModel.trainingMenuList.append(menu)
            }
        }
        currentTrainingSession = newSession
        isShowNewSessionView = false
    }
    
    func addMenu(newMenu: TrainingMenu) {
        contentViewModel.trainingMenuList.append(newMenu)
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
    func deleteMenu(menu: TrainingMenu, modelContext: ModelContext) {
        guard let session = contentViewModel.trainingSessionList.first(where: {$0.id == currentTrainingSession?.id}) else { return }
        
        
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
    
    func updateMenu(menu: TrainingMenu, modelContext: ModelContext) {
        guard let session = contentViewModel.trainingSessionList.first(where: {$0.id == currentTrainingSession?.id}) else { return }
        
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
    func moveMenu(from source: IndexSet, to destination: Int, modelContext: ModelContext) {
        guard let session = contentViewModel.trainingSessionList.first(where: {$0.id == currentTrainingSession?.id}) else { return }
        
        
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
    func deleteSession(session: TrainingSession, modelContext: ModelContext) {
        contentViewModel.trainingSessionList.removeAll(where: {$0.id == session.id})
        modelContext.delete(session.self)
        // データベースに保存
        do {
            try modelContext.save() // 変更を保存
        } catch {
            print("Failed to save context: \(error)")
        }
        currentTrainingSession = nil
    }
}

