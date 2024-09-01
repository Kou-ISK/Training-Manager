//
//  CreateTrainingMenuView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/01.
//

import SwiftUI

struct CreateTrainingMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State var session: TrainingSession
    @State private var trainingMenu = TrainingMenu()
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("メニュー名", text: Binding(
                    get: { trainingMenu.name ?? "" },
                    set: { trainingMenu.name = $0 }
                ))
                
                TextField("重点1", text: Binding(
                    get: { trainingMenu.keyFocus1 ?? "" },
                    set: { trainingMenu.keyFocus1 = $0 }
                ))
                
                TextField("目標", text: Binding(
                    get: { trainingMenu.goal ?? "" },
                    set: { trainingMenu.goal = $0 }
                ))
            }
            .navigationTitle("メニューの追加")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("追加") {
                        // 新しいメニューを追加してセッションに保存
                        session.menus.append(trainingMenu)
                        modelContext.insert(trainingMenu)
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CreateTrainingMenuView(session: TrainingSession())
}
