//
//  AppDelegate.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/07.
//

import UIKit
import UserNotifications
import WatchConnectivity
import SwiftData
import _SwiftData_SwiftUI
import SwiftUICore
import FirebaseCore

func requestNotificationAuthorization() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
        } else {
            print("Notification permission granted: \(granted)")
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private var modelContext: ModelContext?
    private var connectivityManager: iPhoneConnectivityManager?
    
    // ModelContainerの宣言
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TrainingSession.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        requestNotificationAuthorization()
        
        // SwiftDataのモデルコンテキストを初期化
        modelContext = ModelContext(sharedModelContainer)
        
        // ConnectivityManagerの初期化
        connectivityManager = iPhoneConnectivityManager.shared
        connectivityManager?.setupModelContext(modelContext!)
        
        // Firebaseの初期化
        FirebaseApp.configure()
        return true
    }
    
    // フォアグラウンドで通知を表示する
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound]) // フォアグラウンドでバナーとサウンドを表示
    }
}

@objc class iPhoneConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = iPhoneConnectivityManager()
    private var modelContext: ModelContext!
    private var session: WCSession?
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func setupModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - WCSessionDelegate Methods
    @objc func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("WCSession activation failed with error: \(error.localizedDescription)")
            } else {
                print("WCSession activated successfully with state: \(activationState.rawValue)")
                print("isPaired: \(session.isPaired)")
                print("isWatchAppInstalled: \(session.isWatchAppInstalled)")
            }
        }
    }
    
    @objc func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession became inactive")
    }
    
    @objc func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated")
        WCSession.default.activate()
    }

        // 重要: このメソッドを追加
    @objc func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("Received message without reply handler: \(message)")
    }
    
    @objc func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print("iPhone: メッセージ受信")
        print(message)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                replyHandler(["error": "Internal error"])
                return
            }
            
            guard message["request"] as? String == "getTrainingData" else {
                replyHandler(["error": "Invalid request type"])
                return
            }
            
            guard let todaySession = self.fetchTodaySession() else {
                replyHandler(["error": "No session found for today"])
                return
            }
            
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let jsonData = try encoder.encode(todaySession)
                
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    replyHandler(["error": "Failed to encode session data"])
                    return
                }
                
                print("Sending training session data to Watch")
                replyHandler(["trainingSession": jsonString])
            } catch {
                replyHandler(["error": "Encoding error: \(error.localizedDescription)"])
            }
        }
    }
    
    // SwiftDataから今日のトレーニングセッションを取得
    func fetchTodaySession() -> TrainingSession? {
        let today = Calendar.current.startOfDay(for: Date())
        
        // SwiftDataからデータを取得
        let fetchRequest = FetchDescriptor<TrainingSession>()
        
        do {
            let trainingSessions = try modelContext.fetch(fetchRequest) // 全てのトレーニングセッションをフェッチ
            // 今日の日付に対応するセッションを取得
            return trainingSessions.first { session in
                guard let sessionDate = session.sessionDate else { return false }
                return Calendar.current.isDate(sessionDate, inSameDayAs: today)
            }
        } catch {
            print("Error fetching training sessions: \(error)")
            return nil
        }
    }
}

