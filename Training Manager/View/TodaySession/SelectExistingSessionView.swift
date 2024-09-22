//
//  SelectExistingSessionView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/20.
//

import SwiftUI

struct SelectExistingSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var trainingSession: TrainingSession
    var trainingSessionList: [TrainingSession]
    
    var body: some View {
        VStack{
            Text("セッション履歴").font(.title)
            List(trainingSessionList){session in
                NavigationLink(destination: SessionDetailView(session: session)) {
                    HStack{
                        VStack(alignment: .leading){
                            HStack(alignment: .center){
                                Text(session.sessionDate ?? Date(), formatter: dateFormatter)
                                Text(session.theme ?? "")
                                Button("追加") {
                                    trainingSession.sessionDate = Date()
                                    trainingSession.sessionDescription = session.sessionDescription
                                    trainingSession.theme = session.theme
                                    trainingSession.createdAt = Date()
                                    trainingSession.updatedAt = Date()
                                    trainingSession.menus = session.menus
                                    dismiss()
                                }.buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
                
            }
        }
    }
}

#Preview {
    SelectExistingSessionView(
        trainingSession: TrainingSession(),
        trainingSessionList:
            [
                TrainingSession(theme: "テーマ1", sessionDescription: "備考1", sessionDate: Date(), menus:
                                    [TrainingMenu(name: "メニュー1", goal: "ゴール1", duration: TimeInterval(500), focusPoints: ["FP1", "FP2"], menuDescription: "マーカーを置いておく", orderIndex: 0)
                                    ]
                               ),
                TrainingSession(theme: "テーマ2", sessionDescription: "備考2", sessionDate: Date(), menus:
                                    [TrainingMenu(name: "メニュー2", goal: "ゴール2", duration: TimeInterval(500), focusPoints: ["FP1", "FP2"], menuDescription: "マーカーを置いておく", orderIndex: 0)
                                    ]
                               )
            ]
    )
}