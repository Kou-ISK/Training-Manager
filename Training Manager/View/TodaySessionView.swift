//  TodaySessionView.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/30.
//

import SwiftUI
import SwiftData

struct TodaySessionView: View {
    @State var trainingSessionList: [TrainingSession]
    @State private var currentTrainingSession: TrainingSession?
    @State private var isShowAddView = false
    @State private var isShowNewSessionView = false
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            VStack {
                if let session = currentTrainingSession {
                    VStack(alignment: .leading) {
                        Text(session.theme ?? "")
                            .font(.headline)
                        
                        Text(session.sessionDate ?? Date(), formatter: DateFormatter())
                            .font(.subheadline)
                        
                        List(session.menus) { menu in
                            VStack(alignment: .leading) {
                                Text(menu.name ?? "")
                                    .font(.title3)
                                Text(menu.goal ?? "")
                                    .font(.body)
                                Text(menu.keyFocus1 ?? "")
                                    .font(.body)
                            }
                        }
                    }
                } else {
                    Text("本日の日付のセッションが見つかりません")
                        .font(.headline)
                }
            }
            .onAppear {
                filterTodaySessions()
            }
            .sheet(isPresented: $isShowAddView) {
                if let todaySession = currentTrainingSession {
                    CreateTrainingMenuView(session: todaySession)
                }
            }
            .sheet(isPresented: $isShowNewSessionView) {
                CreateTrainingSessionView(onSave: { newSession in
                    currentTrainingSession = newSession
                    trainingSessionList.append(newSession)
                    isShowNewSessionView = false
                })
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if currentTrainingSession == nil {
                            isShowNewSessionView = true
                        } else {
                            isShowAddView = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    func filterTodaySessions() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let session = trainingSessionList.first(where: { session in
            guard let sessionDate = session.sessionDate else { return false }
            let sessionDay = Calendar.current.startOfDay(for: sessionDate)
            return sessionDay == today
        }) {
            currentTrainingSession = session
        } else {
            currentTrainingSession = nil
        }
    }
}

#Preview {
    TodaySessionView(trainingSessionList: [])
}
