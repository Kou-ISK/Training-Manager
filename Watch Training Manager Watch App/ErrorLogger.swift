//
//  ErrorLogger.swift
//  Training Manager Watch App
//
//  Created by 井坂航 on 2024/11/27.
//

import Foundation
import WatchConnectivity

class ErrorLogger: NSObject, ObservableObject {
    static let shared = ErrorLogger()
    private var session: WCSession?
    private var unsentErrors: [String] = []

    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    /// エラーログを記録し、iPhoneに送信を試みる
    func logError(message: String) {
        let timestampedMessage = "[\(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium))] \(message)"
        
        // ローカル保存
        saveErrorLocally(timestampedMessage)

        // iPhoneに送信
        sendErrorToiPhone(timestampedMessage)
    }

    /// ローカルにエラーログを保存
    private func saveErrorLocally(_ message: String) {
        var savedErrors = UserDefaults.standard.array(forKey: "errorLogs") as? [String] ?? []
        savedErrors.append(message)
        UserDefaults.standard.set(savedErrors, forKey: "errorLogs")
    }

    /// 保存されたエラーログを取得
    func fetchSavedErrors() -> [String] {
        return UserDefaults.standard.array(forKey: "errorLogs") as? [String] ?? []
    }

    /// iPhone にエラーを送信
    private func sendErrorToiPhone(_ message: String) {
        guard let session = session, session.isReachable else {
            unsentErrors.append(message) // 送信失敗時にキューに追加
            return
        }

        session.sendMessage(["error": message], replyHandler: nil) { error in
            print("Error sending message: \(error.localizedDescription)")
            self.unsentErrors.append(message) // 失敗した場合もキューに追加
        }
    }

    /// 未送信のエラーを再送信
    private func retryUnsentErrors() {
        guard let session = session, session.isReachable else { return }

        unsentErrors.forEach { error in
            session.sendMessage(["error": error], replyHandler: nil) { error in
                print("Retry failed: \(error.localizedDescription)")
            }
        }

        // 送信成功後にキューをクリア
        unsentErrors.removeAll()
    }
}

// MARK: - WCSessionDelegate
extension ErrorLogger: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // 必要に応じてメッセージを処理
        if let receivedError = message["acknowledgedError"] as? String {
            print("Received acknowledgment for error: \(receivedError)")
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            retryUnsentErrors() // 到達可能になったら未送信エラーを再送信
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated successfully.")
            retryUnsentErrors() // 再接続時に未送信エラーを再送信
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    #endif
}
