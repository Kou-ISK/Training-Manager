//
//  TrainingSessionViewModel.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import Foundation
import Combine
import WatchConnectivity

class TrainingSessionViewModel: NSObject, ObservableObject{
    @Published var todayTrainingSession: TrainingSession?
    
    var session: WCSession

        init(session: WCSession  = .default) {
            self.session = session
            super.init()
            self.session.delegate = self
            session.activate()
        }
    
    
    func updateTodayTrainingSession(session: TrainingSession){
        todayTrainingSession = session
    }
    
    func sendMessage() {
            let messages: [String: Any] =
                ["request": "getTrainingData"]
            // 動物名と絵文字を突っ込んだ配列を送信する
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
    
//    func requestTrainingData() {
//        // iOSにデータリクエストを送信
//        let message = ["request": "getTrainingData"]
//        WCSession.default.sendMessage(message, replyHandler: { response in
//            if let trainingSessionData = response["trainingSession"] as? String {
//                print("Received training session data: \(trainingSessionData)")
//                
//                // JSONをデコードしてViewModelに格納
//                self.decodeTrainingSession(from: trainingSessionData)
//            }
//        }, errorHandler: { error in
//            print("Error sending message: \(error.localizedDescription)")
//        })
//    }
    
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
