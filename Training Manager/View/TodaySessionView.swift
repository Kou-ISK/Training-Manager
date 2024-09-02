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
    
    @State private var currentTrainingMenu: TrainingMenu? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                if let session = currentTrainingSession {
                    VStack(alignment: .center) {
                        Text(session.sessionDate ?? Date(), formatter: DateFormatter())
                            .font(.title)
                        Text(session.theme ?? "")
                            .font(.headline)
                        
                        
                            if currentTrainingMenu != nil{
                                // 実施中のmenuを表示
                                HStack(alignment: .center){
                                VStack{
                                    Text(currentTrainingMenu?.name ??  "N/A").font(.title)
                                        .padding(5)
                                    Text("フォーカスポイント: ")
                                    Text(currentTrainingMenu?.keyFocus1 ?? "")
                                    Text(currentTrainingMenu?.keyFocus2 ?? "")
                                    Text(currentTrainingMenu?.keyFocus3 ?? "")
                                }
                                    TimerView(viewModel: TimerViewModel(), countDownTime: currentTrainingMenu?.duration ?? 60)
                            }
                        }
                        
                        List(session.menus) { menu in
                            let isCurrentTraining = currentTrainingMenu == menu
                            HStack{
                                VStack(alignment: .leading) {
                                    HStack{
                                        Text(menu.name ?? "")
                                            .font(.title)
                                        Text(formatDuration(duration: menu.duration ?? 60))
                                    }
                                    Text(menu.goal ?? "")
                                        .font(.title2)
                                    Text(menu.keyFocus1 ?? "")
                                        .font(.body)
                                    Text(menu.keyFocus2 ?? "")
                                        .font(.body)
                                    Text(menu.keyFocus3 ?? "")
                                        .font(.body)
                                }
                                Spacer()
                                Button(action:{
                                    currentTrainingMenu = menu
                                },label:{
                                    Text(isCurrentTraining ? "実施中" :"開始").fontWeight(.bold)
                                }).buttonStyle(.borderedProminent)
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
    
    // 時間をmm:ss形式で表示
    func formatDuration(duration: TimeInterval)->String{
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        // 分が1桁の場合も2桁で表示するためにフォーマット
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    TodaySessionView(trainingSessionList: [])
}
