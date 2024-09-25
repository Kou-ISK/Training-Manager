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


class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        requestNotificationAuthorization()
        // アプリ起動時にWatchConnectivityを有効化
        _ = iPhoneConnectivityManager.shared  // インスタンスを初期化
        return true
    }
    
    // フォアグラウンドで通知を表示する
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound]) // フォアグラウンドでバナーとサウンドを表示
    }
}

class iPhoneConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = iPhoneConnectivityManager()
    @Environment(\.modelContext) private var modelContext
//    @Query private var trainingSessionList: [TrainingSession]

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    // 必須のWCSessionDelegateメソッド
    func sessionDidBecomeInactive(_ session: WCSession) {
        // ここには、必要に応じて処理を記述します
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // ここには、必要に応じて処理を記述します
        // セッションが無効になったら、新しいセッションをアクティブにする
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // セッションのアクティベーションが完了したときに呼ばれる
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated successfully with state: \(activationState.rawValue)")
        }
    }
    
    // Apple Watchからのリクエストを受信
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        // ここでiPhoneから送信するデータを準備する
        if message["request"] as? String == "getTrainingData" {
            print("watchOSからのメッセージを受信しました")
            if let todaySession = getTodaySession() {
                do {
                    let jsonData = try JSONEncoder().encode(todaySession)
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        let dataToSend: [String: Any] = ["trainingSession": jsonString]
                        replyHandler(dataToSend)  // データをApple Watchに返信
                    }
                } catch {
                    print("Error encoding TrainingSession: \(error)")
                    replyHandler(["error": "Failed to encode session data"])
                }
            } else {
                replyHandler(["error": "No session found for today"])
            }
        }
    }

    func getTodaySession() -> TrainingSession? {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Fetch all training sessions
        let fetchRequest = FetchDescriptor<TrainingSession>()
        
        do {
            let trainingSessions = try modelContext.fetch(fetchRequest) // Fetch all training sessions
            // Find today's session
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

