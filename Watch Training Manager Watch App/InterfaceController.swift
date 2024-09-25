//
//  InterfaceController.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import WatchKit
import WatchConnectivity
import SwiftUICore

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @EnvironmentObject var viewModel: TrainingSessionViewModel
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // WCSessionをセットアップ
        setupWCSession()
    }
    
    private func setupWCSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        } else {
            print("WCSession is not supported on this device.")
        }
    }

    func session(_ session: WCSession, activationDidChangeWith activationState: WCSessionActivationState) {
        switch activationState {
        case .activated:
            print("WCSession activated.")
            requestData() // アクティブになった際にリクエスト
        case .inactive:
            print("WCSession inactive.")
        case .notActivated:
            print("WCSession not activated.")
        @unknown default:
            print("Unknown WCSession state.")
        }
    }

    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated successfully with state: \(activationState.rawValue)")
            requestData() // アクティブになった後にリクエストを行う
        }
    }
    
    var retryCount = 0

    @IBAction func requestData() {
        let message = ["request": "getTrainingData"]
        WCSession.default.sendMessage(message, replyHandler: { response in
            self.handleResponse(response)
            self.retryCount = 0 // 成功したらリセット
        }, errorHandler: { error in
            print("Error sending message: \(error.localizedDescription)")
            self.retryCount += 1
            if self.retryCount < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.requestData() // 1秒後に再試行
                }
            } else {
                print("Failed to send message after retries")
            }
        })
    }

    
    private func handleResponse(_ response: [String: Any]) {
        if let trainingSessionData = response["trainingSession"] as? String {
            print("Received training session data: \(trainingSessionData)")
            self.decodeTrainingSession(from: trainingSessionData)
        } else {
            print("Invalid response format: \(response)")
        }
    }

    private func decodeTrainingSession(from jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Failed to convert JSON string to Data")
            return
        }

        do {
            let decoder = JSONDecoder()
            let session = try decoder.decode(TrainingSession.self, from: jsonData)
            DispatchQueue.main.async {
                self.viewModel.updateTodayTrainingSession(session: session) // ViewModelに更新を通知
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
}
