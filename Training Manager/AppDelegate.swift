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
    var modelContext: ModelContext!
    
    // ModelContainerの宣言
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TrainingSession.self,
            TrainingMenu.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        requestNotificationAuthorization()
        // アプリ起動時にWatchConnectivityを有効化
        // SwiftDataのモデルコンテキストを初期化
        modelContext = ModelContext(sharedModelContainer)

        // modelContextをiPhoneConnectivityManagerに渡す
        iPhoneConnectivityManager.shared.setupModelContext(modelContext)
        return true
    }
    
    // フォアグラウンドで通知を表示する
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound]) // フォアグラウンドでバナーとサウンドを表示
    }
}

class iPhoneConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = iPhoneConnectivityManager()
        private var modelContext: ModelContext!

        private override init() {
            super.init()
            if WCSession.isSupported() {
                WCSession.default.delegate = self
                WCSession.default.activate()
            }
        }

        // AppDelegateからmodelContextをセットアップ
        func setupModelContext(_ context: ModelContext) {
            self.modelContext = context
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
    
    // Apple Watchからのメッセージを受信
     func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
         if message["request"] as? String == "getTrainingData" {
             print("Received request from Apple Watch")
             
             // SwiftDataから今日のトレーニングセッションを取得
             if let todaySession = fetchTodaySession() {
                 do {
                     let jsonData = try JSONEncoder().encode(todaySession)
                     if let jsonString = String(data: jsonData, encoding: .utf8) {
                         let dataToSend: [String: Any] = ["trainingSession": jsonString]
                         replyHandler(dataToSend)  // Apple Watchにデータを返信
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

