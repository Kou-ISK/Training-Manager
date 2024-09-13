//
//  TodaySessionViewModel.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/06.
//

import SwiftUI
import Combine

class TodaySessionViewModel: ObservableObject {
    @Environment(\.modelContext) private var modelContext
    
    @Published var trainingSessionList: [TrainingSession]
    @Published var currentTrainingSession: TrainingSession?
    @Published var currentTrainingMenu: TrainingMenu?
    @Published var timerViewModel: TimerViewModel? = nil
    @Published var trainingMenuList: [TrainingMenu]
    
    @Published var isShowAddView: Bool = false
    @Published var isShowNewSessionView: Bool = false
    @Published var isShowSelectMenuView: Bool = false
    @Published var isEditMode: Bool = false
    @Published var isShowDeleteAlart: Bool = false
    
//    // メニューを orderIndex の順にソートする
//    var sortedMenus: [TrainingMenu] {
//        currentTrainingSession?.menus.sorted(by: { $0.orderIndex < $1.orderIndex }) ?? []
//    }

    
    init(trainingSessionList: [TrainingSession], trainingMenuList: [TrainingMenu]) {
        self.trainingSessionList = trainingSessionList
        self.trainingMenuList = trainingMenuList
        filterTodaySessions()
    }
    
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
        timerViewModel = TimerViewModel(initialTime: menu.duration ?? 0, menuName: menu.name ?? "")
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
    
    func deleteMenu(menu: TrainingMenu) {
            // モデルから削除
            modelContext.delete(menu)
            
            // 現在のセッションからメニューを削除
            if let index = currentTrainingSession?.menus.firstIndex(of: menu) {
                currentTrainingSession?.menus.remove(at: index)
            }
        }
    
    // メニューを並び替えるロジック
    func moveMenu(from source: IndexSet, to destination: Int) {
        guard let session = currentTrainingSession else { return }
        
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
    }
}
