//
//  TrainingSessionViewModel.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import Foundation
import Combine
import WatchConnectivity
import SwiftData

class TrainingSessionViewModel: NSObject, ObservableObject{
    @Published var todayTrainingSession: TrainingSession?
    @Published var timerViewModel: TimerViewModel? = nil
    
    var session: WCSession
    
    init(session: WCSession  = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    // 当日の日付以外のTrainingSessionを削除するメソッド
     func deleteOldSessions(modelContext: ModelContext) {
         let today = Date()
         let calendar = Calendar.current
         
         // `TrainingSession` の全データを取得
         let sessions: [TrainingSession] = try! modelContext.fetch(
             FetchDescriptor<TrainingSession>()
         )
         
         // 今日の日付でないセッションを削除
         for session in sessions {
             if let sessionDate = session.sessionDate,
                !calendar.isDate(sessionDate, inSameDayAs: today) {
                 // 今日の日付でない場合は削除
                 modelContext.delete(session)
             }
         }
         
         // モデルコンテキストの保存
         do {
             try modelContext.save()
         } catch {
             print("Error deleting old sessions: \(error)")
         }
     }
    
    
    func updateTodayTrainingSession(session: TrainingSession){
        todayTrainingSession = session
    }
    
    func selectMenu(menu: TrainingMenu) {
        
        // もし TimerViewModel が存在している場合は停止する
        timerViewModel?.stop()
        
        // 新しいメニューに基づいて TimerViewModel を再初期化
        timerViewModel = TimerViewModel(initialTime: menu.duration ?? 0, menuName: menu.name)
    }
    
    func formatDuration(duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func sendMessage() {
        let messages: [String: Any] =
        ["request": "getTrainingData"]
        self.session.sendMessage(messages, replyHandler: {
            response in
            if let trainingSessionData = response["trainingSession"] as? String {
                print("Received training session data: \(trainingSessionData)")
                
                // JSONをデコードしてViewModelに格納
                self.decodeTrainingSession(from: trainingSessionData)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func decodeTrainingSession(from jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Failed to convert JSON string to Data")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let session = try decoder.decode(TrainingSession.self, from: jsonData)
            DispatchQueue.main.async {
                // ViewModelを更新
                self.updateTodayTrainingSession(session: session)
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
}

extension TrainingSessionViewModel: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("The session has completed activation.")
        }
    }
}
