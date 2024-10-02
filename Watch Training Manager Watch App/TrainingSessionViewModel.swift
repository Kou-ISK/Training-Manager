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

class TrainingSessionViewModel: NSObject, ObservableObject {
    @Published var todayTrainingSession: TrainingSession?
    @Published var timerViewModel: TimerViewModel? = nil
    
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    // 当日の日付以外のTrainingSessionを削除するメソッド
    func deleteOldSessions(modelContext: ModelContext) {
        let today = Date()
        let calendar = Calendar.current
        
        do {
            // `TrainingSession` の全データを取得
            let sessions: [TrainingSession] = try modelContext.fetch(
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
            try modelContext.save()
        } catch {
            print("Error deleting old sessions or saving context: \(error)")
        }
    }
    
    func updateTodayTrainingSession(session: TrainingSession) {
        print("Updating today's training session: \(session)")
        todayTrainingSession = session
    }
    
    func selectMenu(menu: TrainingMenu) {
        // もし TimerViewModel が存在している場合は停止する
        timerViewModel?.stop()
        
        // デバッグメッセージ
        print("Menu selected: \(menu.name)")
        
        // 新しいメニューに基づいて TimerViewModel を再初期化
        timerViewModel = TimerViewModel(initialTime: menu.duration ?? 0, menuName: menu.name)
    }
    
    func formatDuration(duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // iPhone/iPadからのデータ取得を要求
    func sendMessage() {
        let messages: [String: Any] = ["request": "getTrainingData"]
        
        // エラーハンドリングを追加
        if session.activationState == .activated {
            self.session.sendMessage(messages, replyHandler: { response in
                if let trainingSessionData = response["trainingSession"] as? String {
                    print("Received training session data: \(trainingSessionData)")
                    
                    // JSONをデコードしてViewModelに格納
                    self.decodeTrainingSession(from: trainingSessionData)
                } else {
                    print("Error: No valid training session data in response.")
                }
            }) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        } else {
            print("WCSession is not activated, unable to send message.")
        }
    }
    
    // JSONデータをデコード
    func decodeTrainingSession(from jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Error: Failed to convert JSON string to Data.")
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
            print("Error decoding JSON: \(error.localizedDescription)")
        }
    }
}

extension TrainingSessionViewModel: WCSessionDelegate {
    // セッションのアクティベーション完了時に呼び出される
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation error: \(error.localizedDescription)")
        } else {
            print("WCSession activated successfully.")
        }
    }
}
