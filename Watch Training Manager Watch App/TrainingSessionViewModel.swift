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
    private var retryCount: Int = 0
    private let maxRetries: Int = 3
    
    init(session: WCSession = .default, modelContext: ModelContext) {
        self.session = session
        self.modelContext = modelContext
        super.init()
        
        self.session.delegate = self
        self.session.activate()
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
            print("WCSession status: \(connectionStatus), isReachable: \(session.isReachable)")
        @unknown default:
            connectionStatus = "Unknown state"
        }
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
    
    func sendMessage() {
        // 既存のセッションをクリア
        todayTrainingSession = nil
        
        checkAndReconnectSession()
        
        guard session.isReachable else {
            retryConnection()
            return
        }
        
        let message: [String: Any] = ["request": "getTrainingData"]
        print("Attempting to send message to iPhone...")
        
        session.sendMessage(message, replyHandler: { [weak self] response in
            DispatchQueue.main.async {
                self?.retryCount = 0 // リセット
                
                if let error = response["error"] as? String {
                    ErrorLogger.shared.logError(message: "Error from iPhone: \(error)")
                    return
                }
                
                guard let trainingSessionData = response["trainingSession"] as? String else {
                    ErrorLogger.shared.logError(message: "Invalid response format")
                    return
                }
                
                self?.decodeAndSaveTrainingSession(from: trainingSessionData)
            }
        }, errorHandler: { [weak self] error in
            DispatchQueue.main.async {
                self?.retryCount = 0
                ErrorLogger.shared.logError(message: "Message sending failed: \(error.localizedDescription)")
            }
        })
    }
    
    private func retryConnection() {
        guard retryCount < maxRetries else {
            ErrorLogger.shared.logError(message: "Max retry attempts reached")
            retryCount = 0
            return
        }
        
        retryCount += 1
        print("Retry attempt \(retryCount) of \(maxRetries)")
        
        // リトライ間隔を指数関数的に増加
        let delay = Double(retryCount) * 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            
            print("Attempting reconnection...")
            self.checkAndReconnectSession()
            
            if self.session.isReachable {
                print("Session is now reachable, sending message...")
                self.sendMessage()
            } else {
                print("Session is still not reachable after retry")
                if self.retryCount < self.maxRetries {
                    self.retryConnection()
                }
            }
        }
    }
    
    private func checkAndReconnectSession() {
        guard WCSession.isSupported() else {
            connectionStatus = "WCSession not supported"
            return
        }
        
        if session.activationState != .activated {
            print("Activating WCSession...")
            session.activate()
        }
        
        isReachable = session.isReachable
        updateConnectionStatus()
    }
    
    private func decodeAndSaveTrainingSession(from jsonString: String) {
        do {
            guard let jsonData = jsonString.data(using: .utf8) else {
                ErrorLogger.shared.logError(message: "Failed to convert string to data")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            // デコード前に既存のセッションをクリア
            let descriptor = FetchDescriptor<TrainingSession>()
            if let existingSessions = try? modelContext.fetch(descriptor) {
                for session in existingSessions {
                    modelContext.delete(session)
                }
            }
            
            let session = try decoder.decode(TrainingSession.self, from: jsonData)
            modelContext.insert(session)
            try modelContext.save()
            
            DispatchQueue.main.async { [weak self] in
                self?.todayTrainingSession = session
            }
            
        } catch {
            ErrorLogger.shared.logError(message: "Decoding error: \(error.localizedDescription)")
            print("Decoding error details: \(error)")
        }
    }
}

extension TrainingSessionViewModel: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let error = error {
                ErrorLogger.shared.logError(message: "WCSession activation error: \(error.localizedDescription)")
            } else {
                print("WCSession activated with state: \(activationState.rawValue)")
                self?.isReachable = session.isReachable
                if session.isReachable {
                    self?.sendMessage()
                }
            }
            self?.updateConnectionStatus()
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { [weak self] in
            self?.isReachable = session.isReachable
            self?.updateConnectionStatus()
            if session.isReachable {
                self?.sendMessage()
            }
        }
    }
}
