//
//  CreateTrainingSessionView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/01.
//

import SwiftUI

struct CreateTrainingSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var newSession = TrainingSession()
    @State private var duration: Int64 = 0
    
    var onSave: (TrainingSession) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("セッション日付", selection: Binding(
                    get: { newSession.sessionDate ?? Date() },
                    set: { newSession.sessionDate = $0 }
                ), displayedComponents: [.date])
                TextField("テーマ", text: Binding(
                    get: { newSession.theme ?? "" },
                    set: { newSession.theme = $0 }
                ))
                TextField("備考", text: Binding(
                    get: { newSession.sessionDescription ?? "" },
                    set: { newSession.sessionDescription = $0 }
                ))
                
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("保存") {
                        modelContext.insert(newSession)
                        onSave(newSession)
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
    CreateTrainingSessionView(onSave: { _ in })
}
