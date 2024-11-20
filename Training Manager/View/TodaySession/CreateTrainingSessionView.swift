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
    
    var sessionDate: Date
    @State private var newSession = TrainingSession(sessionDate: Date())
    @State private var duration: Int64 = 0
    @State var trainingSessionList: [TrainingSession]
    
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
                    TextEditor(text: Binding(
                        get: { newSession.sessionDescription ?? ""},
                        set: { newSession.sessionDescription = $0 }
                    ))
                        .overlay(alignment: .topLeading) {
                            if newSession.sessionDescription?.isEmpty ?? true {
                                Text("備考")
                                    .foregroundColor(.gray) // プレースホルダーっぽく見せるために色を変更
                                    .allowsHitTesting(false)
                                    .padding(.top, 8) // テキストエディタの内側にマージンを設定
                            }
                        }
                
                NavigationLink("既存のセッションから追加", destination: SelectExistingSessionView(trainingSession: newSession, trainingSessionList: trainingSessionList))
                
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("保存") {
                        modelContext.insert(newSession)
                        // データベースに保存
                        do {
                            try modelContext.save() // 変更を保存
                        } catch {
                            print("Failed to save context: \(error)")
                        }
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
            .onAppear{
                newSession.sessionDate = sessionDate
            }
        }
    }
}

#Preview {
    CreateTrainingSessionView(sessionDate: Date(), trainingSessionList:  [
        TrainingSession(theme: "テーマ1", sessionDescription: "備考1", sessionDate: Date(), menus:
                            [TrainingMenu(name: "メニュー1", goal: "ゴール1", duration: TimeInterval(500), focusPoints: ["FP1", "FP2"], menuDescription: "マーカーを置いておく", orderIndex: 0)
                            ]
                       ),
        TrainingSession(theme: "テーマ2", sessionDescription: "備考2", sessionDate: Date(), menus:
                            [TrainingMenu(name: "メニュー2", goal: "ゴール2", duration: TimeInterval(500), focusPoints: ["FP1", "FP2"], menuDescription: "マーカーを置いておく", orderIndex: 0)
                            ]
                       )
    ], onSave: { _ in })
}
