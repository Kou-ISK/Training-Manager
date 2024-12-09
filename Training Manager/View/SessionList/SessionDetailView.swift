//
//  SessionDetailView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/05.
//

import SwiftUI

struct SessionDetailView: View {
    @State var session: TrainingSession
    @State var trainingSessionList: [TrainingSession]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var isEditMode:Bool = false
    @State private var isShowAddView:Bool = false
    @State private var editingMenu: TrainingMenu?
    @State private var isShowDeleteSessionAlert: Bool = false
    @State private var isShowDeleteAlart:Bool = false
    
    var onDelete: (() -> Void)?  // 削除時のコールバック
    
    var body: some View {
        VStack {
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
                                deleteSession()
                            }
                            Button("キャンセル", role: .cancel) {}
                        })
                }
                // セッションのテーマ、日付、説明をヘッダーとして表示
                VStack(alignment: .leading, spacing: 8) {
                    Text(session.sessionDate ?? Date(), formatter: dateFormatter)
                        .font(.headline)
                    if let theme = session.theme, !theme.isEmpty {
                        Text("テーマ: \(theme)")
                            .font(.headline)
                    }
                    
                    if let description = session.sessionDescription, !description.isEmpty {
                        Text("備考: \(description)")
                            .font(.body)
                    }
                }
            }
            
            // メニューリスト表示
            List {
                ForEach(session.menus.sorted(by: { $0.orderIndex < $1.orderIndex })) { menu in
                    TrainingMenuRow(
                        menu: menu,
                        isEditMode: isEditMode,
                        isTodaySession: false,
                        isCurrentTraining: false,
                        onDelete: { deleteMenu(menu: menu) },
                        onEdit: { updateMenu(menu: menu) },
                        onSelect: {}
                    )
                }
            }
            .listStyle(PlainListStyle())
        }
        .sheet(isPresented: $isShowAddView) {
            CreateTrainingMenuView(
                session: $session,trainingSessionList: $trainingSessionList)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowAddView = true
                } label: {
                    Image(systemName: "plus")
                }
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
    
    private func deleteSession() {
        // データベースに保存し、エラーを処理
        do {
            dismiss()
            try modelContext.save() // 変更を保存
            // モデルコンテキストからセッションを削除
            modelContext.delete(session)
            onDelete?()
        } catch {
            print("Failed to save context: \(error)")
            // エラー処理が必要な場合はここで行う
        }
    }
    
    // メニューを削除する処理
    func deleteMenu(menu: TrainingMenu) {
        
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
        }
    }
    
    func updateMenu(menu: TrainingMenu) {
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
        }
    }
}

#Preview {
    SessionDetailView(session: TrainingSession(theme: "テーマ", sessionDescription: "備考", sessionDate: Date(), menus: [
        TrainingMenu(name: "メニュー1", goal: "ゴール1", duration: 300, focusPoints: ["ポイント1-1", "ポイント1-2", "ポイント1-3"], menuDescription: "備考1", orderIndex: 0),
        TrainingMenu(name: "メニュー2", goal: "ゴール2", duration: 300, focusPoints: ["ポイント2-1", "ポイント2-2", "ポイント2-3"], menuDescription: "備考2", orderIndex: 1)
    ]), trainingSessionList: [TrainingSession()])
}
