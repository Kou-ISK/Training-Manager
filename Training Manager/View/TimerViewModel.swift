//
//  TimerViewModel.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/02.
//

import Foundation
import Combine

class TimerViewModel: ObservableObject {
    @Published var remainingTime: TimeInterval = 0 // 残り時間（秒単位）
    @Published var timer: AnyCancellable? // タイマー
    
    public func setRemainingTime(time: TimeInterval){
        // 残り時間を設定
        remainingTime = time
    }

    // タイマーの開始
    func start(time: TimeInterval) {
        print("start Timer")
        
        // 残り時間を設定
        remainingTime = time
        
        // 既存のタイマーがあればキャンセル
        timer?.cancel()

        // タイマーを開始（1秒ごとに更新）
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                // 残り時間を減少
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                } else {
                    self.stop() // タイマーが0になったら停止
                }
            }
    }

    // タイマーの停止
    func stop() {
        print("stop Timer")
        timer?.cancel()
        timer = nil
    }

    // 残り時間をmm:ss形式で表示
    var timeString: String {
        let minutes = Int(self.remainingTime) / 60
        let seconds = Int(self.remainingTime) % 60
        // 分が1桁の場合も2桁で表示するためにフォーマット
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
