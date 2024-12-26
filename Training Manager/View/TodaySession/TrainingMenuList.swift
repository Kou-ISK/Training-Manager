//
//  TrainingMenuList.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/11/22.
//

import SwiftUI

struct TrainingMenuList: View {
    @Environment(\.modelContext)private var modelContext
    
    var menus: [TrainingMenu]
    
    private var sortedMenus:[TrainingMenu]{
        return menus.sorted(by: { firstMenu, secondMenu in
            return firstMenu.orderIndex < secondMenu.orderIndex
        })
    }
    
    var trainingSessionList: [TrainingSession]
    var isEditMode: Bool
    
    @Binding var currentTrainingMenu: TrainingMenu?
    @Binding var currentTrainingSession: TrainingSession?
    
    @State private var isShowDeleteAlert = false
    // 削除対象のメニューを保持するプロパティ
    @State private var menuToDelete: TrainingMenu? = nil
    
    var selectMenu: ((TrainingMenu)->Void)
    
    // TODO: 共通コンポーネント化出来るか検討
    var body: some View {
        List{
            ForEach(sortedMenus, id: \.id) { menu in
                TrainingMenuRow(
                    menu: menu,
                    isEditMode: isEditMode,
                    isTodaySession: true,
                    isCurrentTraining: currentTrainingMenu?.id == menu.id,
                    onDelete: { prepareToDelete(menu: menu) },
                    onEdit: { updateMenu(menu: menu) },
                    onSelect: { selectMenu(menu) }
                ).listRowSeparator(.hidden) // セパレータを非表示
                .alert("メニューの削除", isPresented: $isShowDeleteAlert) {
                    deleteAlertActions()
                }
            }.onMove { source, destination in
                if isEditMode {
                    moveMenu(from: source, to: destination)
                }
            }.moveDisabled(!isEditMode)// 編集モードでない場合はリスト項目を移動できないようにする
        }.listStyle(PlainListStyle()) // Listの背景をクリアにする
    }
    
    private func prepareToDelete(menu: TrainingMenu) {
        menuToDelete = menu
        isShowDeleteAlert.toggle()
    }
    
    private func deleteAlertActions() -> some View {
        Group {
            Button("削除", role: .destructive) {
                if let menuToDelete = menuToDelete {
                    deleteMenu(menu: menuToDelete)
                }
            }
            Button("キャンセル", role: .cancel) {}
        }
    }
    
    private func deleteMenu(menu: TrainingMenu) {
        guard let session = trainingSessionList.first(where: { $0.id == currentTrainingSession?.id }),
              let index = session.menus.firstIndex(where: { $0.id == menu.id }) else { return }
        
        session.menus.remove(at: index)
        modelContext.delete(menu)
        saveChanges()
        if currentTrainingMenu == menu {
            currentTrainingMenu = session.menus.first
        }
    }
    
    private func updateMenu(menu: TrainingMenu) {
        guard let session = trainingSessionList.first(where: { $0.id == currentTrainingSession?.id }),
              let index = session.menus.firstIndex(where: { $0.id == menu.id }) else { return }
        
        session.menus[index] = menu
        saveChanges()
        if currentTrainingMenu?.id == menu.id {
            currentTrainingMenu = menu
        }
    }
    
    private func moveMenu(from source: IndexSet, to destination: Int) {
        guard let session = trainingSessionList.first(where: { $0.id == currentTrainingSession?.id }) else { return }
        
        var menus = session.menus.sorted { $0.orderIndex < $1.orderIndex }
        menus.move(fromOffsets: source, toOffset: destination)
        menus.enumerated().forEach { $1.orderIndex = $0 }
        session.menus = menus
        saveChanges()
    }
    
    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

#Preview {
    TrainingMenuList(menus: [TrainingMenu(name: "NAME", goal: "GOAL", duration: TimeInterval(100), focusPoints: ["FP1", "FP2"], menuDescription: "Description", orderIndex: 0),TrainingMenu(name: "NAME-2", goal: "GOAL-2", duration: TimeInterval(100), focusPoints: ["FP1-2", "FP2-2"], menuDescription: "Description-2", orderIndex: 1)], trainingSessionList: [], isEditMode: true, currentTrainingMenu: .constant(TrainingMenu()), currentTrainingSession: .constant(TrainingSession()), selectMenu: { menu in
        print("Selected menu: \(menu.name)")})
}
