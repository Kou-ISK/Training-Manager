//
//  SessionDetailView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/05.
//

import SwiftUI

struct SessionDetailView: View {
    var session: TrainingSession
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var onDelete: (() -> Void)?  // 削除時のコールバック
    
    var body: some View {
        VStack {
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
            
            // メニューリスト表示
            List {
                ForEach(session.menus) { menu in
                    // メニュー名の表示
                    DisclosureGroup(menu.name) {
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
                                    Text(point)
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
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("削除") {
                    deleteSession()
                }
                .foregroundColor(.red)
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
}

#Preview {
    SessionDetailView(session: TrainingSession(theme: "テーマ", sessionDescription: "備考", sessionDate: Date(), menus: [
        TrainingMenu(name: "メニュー1", goal: "ゴール1", duration: 300, focusPoints: ["ポイント1-1", "ポイント1-2", "ポイント1-3"], menuDescription: "備考1", orderIndex: 0),
        TrainingMenu(name: "メニュー2", goal: "ゴール2", duration: 300, focusPoints: ["ポイント2-1", "ポイント2-2", "ポイント2-3"], menuDescription: "備考2", orderIndex: 1)
    ]))
}
