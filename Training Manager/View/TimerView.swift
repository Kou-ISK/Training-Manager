//
//  TimerView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/02.
//

import SwiftUI

struct TimerView: View {
    @StateObject var viewModel:TimerViewModel
    var countDownTime: TimeInterval
    
    var body: some View {
        ZStack{
            VStack(alignment: .center) {
                // mm:ss形式でタイマー表示
                Text(viewModel.timeString)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(5)
                // Start/Stop Timer Button
                Button(action: {
                    if viewModel.timer == nil {
                        viewModel.start(time: countDownTime) // 1分間のカウントダウンを開始
                    } else {
                        viewModel.stop()
                    }
                }) {
                    Text(viewModel.timer == nil ? "開始" : "停止").fontWeight(.bold)
                }.buttonStyle(.borderedProminent)
            }
            CircleProgressBarView(progress: $viewModel.progress).padding(50)
        }.onAppear(perform: {viewModel.setRemainingTime(time: countDownTime)})
    }
}

#Preview {
    TimerView(viewModel: TimerViewModel(),countDownTime: TimeInterval(355))
}
