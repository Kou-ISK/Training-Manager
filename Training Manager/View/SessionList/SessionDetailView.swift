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
                    // メニュー名の表示
                    DisclosureGroup(content: {
                        // メニュー詳細を階層的に表示
                        VStack(alignment: .leading, spacing: 8) {
                            // 練習のゴール
                            if !menu.goal.isEmpty {
                                Text("練習のゴール:")
                                    .font(.headline)
                                Text(menu.goal)
                                    .font(.body)
                                    .padding(.bottom, 4)
                            }
                            
                            // フォーカスポイント
                            if !menu.focusPoints.isEmpty {
                                Text("フォーカスポイント:")
                                    .font(.headline)
                                ForEach(menu.focusPoints, id: \.self) { point in
                                    Text(point.label)
                                        .font(.body)
                                }
                                .padding(.bottom, 4)
                            }
                            
                            // 備考
                            if let description = menu.menuDescription, !description.isEmpty {
                                Text("備考:")
                                    .font(.headline)
                                Text(description)
                                    .font(.body)
                            }
                        }
                        .padding(.vertical, 8)
                    }){
                        if isEditMode {
                            HStack{
                                Button(action: {
                                    isShowDeleteAlart.toggle()
                                }, label:{
                                    Image(systemName: "minus.circle.fill").foregroundStyle(.red)
                                }).buttonStyle(.borderless).background(.clear)
                                    .alert("メニューの削除", isPresented: $isShowDeleteAlart, actions: {
                                        Button("削除", role: .destructive) {
                                            print(menu)
                                            deleteMenu(menu: menu)
                                        }
                                        Button("キャンセル", role: .cancel) {}
                                    })
                            }
                        }
                        Text(menu.name)
                        if(isEditMode){
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
                                    updateMenu(menu: menuToEdit)
                                })
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
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
