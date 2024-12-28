//
//  TrainingMenuHistory.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/30.
//

import SwiftUI

struct TrainingMenuHistory: View {
    @Environment(\.modelContext) private var modelContext
    
    @State var trainingSessionList: [TrainingSession]
    @State private var isEditMode: Bool = false
    @State private var menuToDelete: TrainingMenu?
    @State private var isShowDeleteAlart: Bool = false
    
    private var trainingMenuList: [TrainingMenu]{
        return trainingSessionList.flatMap({$0.menus})
    }
    
    // 検索用のテキスト
    @State private var searchText: String = ""
    // 検索結果
    private var filteredMenu: [TrainingMenu] {
        let searchResult = trainingMenuList.filter { $0.name.localizedStandardContains(searchText) }
        
        return searchText.isEmpty ? trainingMenuList : searchResult
    }
    
    var body: some View {
        NavigationStack {
            VStack{
                List(filteredMenu.sorted(by: { $0.orderIndex < $1.orderIndex })){ menu in
                    TrainingMenuRow(
                        menu: menu,
                        isEditMode: isEditMode,
                        isTodaySession: false,
                        isCurrentTraining: false,
                        onDelete: { deleteMenu(menu: menu) },
                        onEdit: {},
                        onSelect: {}
                    )
                }.searchable(text: $searchText).listStyle(PlainListStyle())
            }
            .toolbar {
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
    
    // 時間をmm:ss形式で表示
    private func formatDuration(duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // メニューを削除する処理
    private func deleteMenu(menu: TrainingMenu) {
        // データベースから削除
        modelContext.delete(menu)
        // データベースに保存
        do {
            try modelContext.save() // 変更を保存
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

#Preview {
    TrainingMenuHistory(trainingSessionList: [TrainingSession(theme: "Theme", sessionDescription: "Session", sessionDate: Date(), menus: [TrainingMenu(name: "Menu", goal: "Goal", duration: TimeInterval(100), focusPoints: ["FP1"], menuDescription: "Description", orderIndex: 1)])])
}
