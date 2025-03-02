//
//  SessionHeaderView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/12/27.
//

import SwiftUI

struct SessionHeaderView: View {
    let session: TrainingSession
    let isEditMode: Bool
    let onDelete: () -> Void

    @State private var isShowDeleteSessionAlert: Bool = false
    
    var totalDuration: TimeInterval {
        session.menus.compactMap { $0.duration }.reduce(0, +)
    }

    var body: some View {
        HStack {
            if isEditMode {
                Button(action: {
                    isShowDeleteSessionAlert.toggle()
                }, label: {
                    Image(systemName: "minus.circle.fill").foregroundStyle(.red)
                })
                .buttonStyle(.borderless)
                .background(.clear)
                .alert("セッションの削除", isPresented: $isShowDeleteSessionAlert, actions: {
                    Button("削除", role: .destructive) {
                        onDelete()
                    }
                    Button("キャンセル", role: .cancel) {}
                })
            }

            VStack(alignment: .leading) {
                Text(session.sessionDate ?? Date(), formatter: dateFormatter)
                Text("テーマ: \(session.theme ?? "")").font(.subheadline)
                Text("備考: \(session.sessionDescription ?? "")")
                Text("合計時間: \(formatTrainingDuration(totalDuration))")
            }
            .padding(8)
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    SessionHeaderView(session: TrainingSession(theme: "Theme", sessionDescription: "Description", sessionDate: Date(), menus: [
        TrainingMenu(name: "Menu1", goal: "Goal", duration: 100, focusPoints: ["fp"], menuDescription: "description", orderIndex: 0),
        TrainingMenu(name: "Menu2", goal: "Goal", duration: 200, focusPoints: ["fp"], menuDescription: "description", orderIndex: 0),
        TrainingMenu(name: "Menu3", goal: "Goal", duration: 300, focusPoints: ["fp"], menuDescription: "description", orderIndex: 0),
        TrainingMenu(name: "Menu4", goal: "Goal", duration: 400, focusPoints: ["fp"], menuDescription: "description", orderIndex: 0),
        TrainingMenu(name: "Menu5", goal: "Goal", duration: 500, focusPoints: ["fp"], menuDescription: "description", orderIndex: 0)
    ]), isEditMode: false, onDelete: {print("削除")})
}
