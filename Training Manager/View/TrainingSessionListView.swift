//
//  TrainingSessionListView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/05.
//

import SwiftUI

struct TrainingSessionListView: View {
    @State var trainingSessionList: [TrainingSession]
    
    var body: some View {
        NavigationStack{
            Text("セッション一覧").font(.title)
            List(trainingSessionList) { session in
                NavigationLink(destination: SessionDetailView(session: session)) {
                    VStack(alignment: .leading) {
                        Text(session.sessionDate ?? Date(), formatter: dateFormatter)
                            .font(.headline)
                        Text(session.theme ?? "")
                            .font(.subheadline)
                        Text(session.sessionDescription ?? "")
                            .font(.subheadline)
                    }
                }
            }
        }
    }
}

#Preview {
    TrainingSessionListView(trainingSessionList: [TrainingSession(theme: "テーマ", sessionDescription: "備考",sessionDate: Date())])
}
