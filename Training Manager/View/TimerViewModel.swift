//
//  TimerViewModel.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/02.
//

import Foundation
import Combine
import AudioToolbox
import UserNotifications

class TimerViewModel: ObservableObject {
    @Published var remainingTime: TimeInterval // 残り時間（秒単位）
    @Published var timer: AnyCancellable? // タイマー
    @Published var progress: CGFloat = 0.0 // プログレスバーの進行度
    @Published var menuName: String
    @Published var timeString: String = "00:00"
    
    private var initialTime: TimeInterval
    private let soundId: SystemSoundID = 1320
    
    // イニシャライザで初期化
    init(initialTime: TimeInterval, menuName: String) {
        self.initialTime = initialTime
        self.remainingTime = initialTime
        self.menuName = menuName
        self.timeString = formatTime(remainingTime)
    }
    
    public func setRemainingTime(time: TimeInterval, menuName:String){
        timer?.cancel()
        // 初期値の設定
        initialTime = time
        // 残り時間を設定
        remainingTime = time
        self.menuName = menuName
        self.timeString = formatTime(remainingTime)
    }
    
    // タイマーの開始
    func start() {
        timer?.cancel()
        
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                    self.timeString = self.formatTime(self.remainingTime) // 更新
                    self.updateProgress()
                } else {
                    self.push()
                    self.stop()
                }
            }
    }
    
    // タイマーの停止
    func stop() {
        print("stop Timer")
        timer?.cancel()
        timer = nil
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // プログレス更新
    private func updateProgress() {
        progress = CGFloat((initialTime - remainingTime) / initialTime)
    }
    
    private func push(){
        // タイトル、本文、サウンド設定の保持
        let content = UNMutableNotificationContent()
        content.title = "メニュー終了"
        content.subtitle = self.menuName
        content.body = "タップしてアプリを開いてください"
        content.sound = UNNotificationSound.default
        
        // seconds後に起動するトリガーを保持
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        // 識別子とともに通知の表示内容とトリガーをrequestに内包する
        let request = UNNotificationRequest(identifier: "Timer",
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("Notification added successfully.")
            }
        }

        
        // UNUserNotificationCenterにrequest
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
