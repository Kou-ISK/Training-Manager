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
    @Published var isReachable: Bool = false
    @Published var connectionStatus: String = "Checking connection..."
    @Published var timerViewModel: TimerViewModel? = nil
    
    private let session: WCSession
    private let modelContext: ModelContext
    
    init(session: WCSession = .default, modelContext: ModelContext) {
        self.session = session
        self.modelContext = modelContext
        super.init()
        
        self.session.delegate = self
        self.session.activate()
        self.isReachable = session.isReachable
        self.updateConnectionStatus()
    }
    
    private func updateConnectionStatus() {
        let status = session.activationState
        switch status {
        case .notActivated:
            connectionStatus = "Not activated"
        case .inactive:
            connectionStatus = "Inactive"
        case .activated:
            connectionStatus = session.isReachable ? "Connected" : "Not reachable"
        @unknown default:
            connectionStatus = "Unknown state"
        }
        print("Watch Connectivity Status: \(connectionStatus)")
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
    
    func checkAndReconnectSession() {
        guard WCSession.isSupported() else {
            connectionStatus = "WCSession not supported"
            return
        }
        
        if session.activationState != .activated {
            session.activate()
        }
        
        isReachable = session.isReachable
        updateConnectionStatus()
    }
    
    func sendMessage() {
        checkAndReconnectSession()
        
        guard session.isReachable else {
            let errorMessage = "WCSession is not reachable"
            ErrorLogger.shared.logError(message: errorMessage)
            return
        }
        
        print("Sending message to iPhone...")
        let message: [String: Any] = ["request": "getTrainingData"]
        
        session.sendMessage(message, replyHandler: { [weak self] response in
            DispatchQueue.main.async {
                print("Received response from iPhone")
                if let error = response["error"] as? String {
                    ErrorLogger.shared.logError(message: "Error from iPhone: \(error)")
                    return
                }
                
                guard let trainingSessionData = response["trainingSession"] as? String else {
                    ErrorLogger.shared.logError(message: "Invalid response format")
                    return
                }
                
                self?.decodeTrainingSession(from: trainingSessionData)
            }
        }, errorHandler: { error in
            DispatchQueue.main.async {
                ErrorLogger.shared.logError(message: "Message sending failed: \(error.localizedDescription)")
            }
        })
    }
    
    // JSONデータをデコード
    func decodeTrainingSession(from jsonString: String) {
        do {
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw NSError(domain: "JSONDecoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let session = try decoder.decode(TrainingSession.self, from: jsonData)
            
            DispatchQueue.main.async {
                self.updateTodayTrainingSession(session: session)
            }
        } catch {
            ErrorLogger.shared.logError(message: "Decoding error: \(error.localizedDescription)\nJSON: \(jsonString)")
        }
    }
}

extension TrainingSessionViewModel: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                let errorMessage = "WCSession activation error: \(error.localizedDescription)"
                print(errorMessage)
                ErrorLogger.shared.logError(message: errorMessage)
            } else {
                print("WCSession activated successfully with state: \(activationState.rawValue)")
                self.isReachable = session.isReachable
                if self.isReachable {
                    self.sendMessage()
                }
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            if self.isReachable {
                self.sendMessage()
            }
        }
    }
}
