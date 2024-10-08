//
//  TrainingSessionListView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/05.
//

import SwiftUI

struct TrainingSessionListView: View {
    @State var contentViewModel: ContentViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedDate = Date()
    @State private var isShowNewSessionView:Bool = false
    
    // セッションがある日付を抽出
    var sessionDates: [Date] {
        contentViewModel.trainingSessionList.compactMap { $0.sessionDate }
    }
    
    // 選択された日付に対応するセッションのフィルター
    var filteredSessions: [TrainingSession] {
        contentViewModel.trainingSessionList.filter { session in
            guard let sessionDate = session.sessionDate else { return false }
            return Calendar.current.isDate(sessionDate, inSameDayAs: selectedDate)
        }
    }
    
    // 新規セッション追加
    func addSession(newSession: TrainingSession) {
        contentViewModel.trainingSessionList.append(newSession)
        // データベースに保存
        do {
            try modelContext.save() // 変更を保存
        } catch {
            print("Failed to save context: \(error)")
        }
        isShowNewSessionView = false
    }
    
    // セッション削除後にリストを更新
    func removeSession(_ session: TrainingSession) {
        if let index = contentViewModel.trainingSessionList.firstIndex(of: session) {
            contentViewModel.trainingSessionList.remove(at: index)
        }
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                // カスタムカレンダーを表示
                CustomCalendarView(selectedDate: $selectedDate, sessionDates: sessionDates)
                
                // 選択された日付のセッションを表示する部分
                if !filteredSessions.isEmpty {
                    List(filteredSessions, id: \.self) { session in
                        NavigationLink(destination: SessionDetailView(session: session, contentViewModel: contentViewModel, onDelete: {
                            removeSession(session)
                        })) {
                            VStack(alignment: .leading) {
                                Text(session.theme ?? "")
                                    .font(.headline)
                                Text(session.sessionDescription ?? "")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)  // リストの高さを最大にする
                } else {
                    Spacer()  // 上下のレイアウト調整のために Spacer を追加
                    VStack{
                        Text("選択された日にセッションはありません")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Button("追加"){
                            isShowNewSessionView.toggle()
                        }
                    }
                    
                    Spacer()  // 下にも Spacer を追加して、テキストを中央に配置
                }
            }
        }.sheet(isPresented: $isShowNewSessionView) {
            CreateTrainingSessionView(contentViewModel: contentViewModel, sessionDate: selectedDate,
                                      trainingSessionList: contentViewModel.trainingSessionList, onSave: { newSession in
                addSession(newSession: newSession)
            })
        }
    }
}

#Preview {
    TrainingSessionListView(
        contentViewModel: ContentViewModel(
        trainingSessionList: [
        TrainingSession(theme: "テーマ", sessionDescription: "備考", sessionDate: Date()),
        TrainingSession(theme: "テーマ", sessionDescription: "備考", sessionDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
        TrainingSession(theme: "テーマ2", sessionDescription: "備考2", sessionDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
        TrainingSession(theme: "テーマ", sessionDescription: "備考", sessionDate: Calendar.current.date(byAdding: .day, value: +4, to: Date())!)
        ], trainingMenuList: []))
}
