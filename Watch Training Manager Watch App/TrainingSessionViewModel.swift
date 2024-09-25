//
//  TrainingSessionViewModel.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import Foundation
import Combine
import WatchConnectivity

class TrainingSessionViewModel: ObservableObject{
    @Published var todayTrainingSession: TrainingSession?
    
    
    func updateTodayTrainingSession(session: TrainingSession){
        todayTrainingSession = session
    }
    
    func requestTrainingData() {
        // iOSにデータリクエストを送信
        let message = ["request": "getTrainingData"]
        WCSession.default.sendMessage(message, replyHandler: { response in
            if let trainingSessionData = response["trainingSession"] as? String {
                print("Received training session data: \(trainingSessionData)")
                
                // JSONをデコードしてViewModelに格納
                self.decodeTrainingSession(from: trainingSessionData)
            }
        }, errorHandler: { error in
            print("Error sending message: \(error.localizedDescription)")
        })
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
