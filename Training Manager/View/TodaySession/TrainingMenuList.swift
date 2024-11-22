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
    // 編集中のメニューを保持
    @State private var editingMenu: TrainingMenu? = nil
    
    var selectMenu: ((TrainingMenu)->Void)
    
    // TODO: コンポーネントに切り分け
    var body: some View {
        List{
            ForEach(sortedMenus, id: \.id) { menu in
                TrainingMenuRow(
                    menu: menu,
                    isEditMode: isEditMode,
                    isCurrentTraining: currentTrainingMenu?.id == menu.id,
                    onDelete: { prepareToDelete(menu: menu) },
                    onEdit: { editingMenu = menu },
                    onSelect: { selectMenu(menu) }
                )
                .alert("メニューの削除", isPresented: $isShowDeleteAlert) {
                    deleteAlertActions()
                }
            }.onMove { source, destination in
                if isEditMode {
                    moveMenu(from: source, to: destination)
                }
            }.moveDisabled(!isEditMode)// 編集モードでない場合はリスト項目を移動できないようにする
        }
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
    
    //    TrainingMenuList(session: TrainingSession(), trainingSessionList: [TrainingSession()], isEditMode: true, editingMenu: .constant(TrainingMenu()), currentTrainingMenu: .constant(TrainingMenu()), currentTrainingSession: .constant(TrainingSession()), menuToDelete: .constant(TrainingMenu()), isShowDeleteAlert: .constant(true), selectMenu: { menu in
    //        print("Selected menu: \(menu.name)")})
}