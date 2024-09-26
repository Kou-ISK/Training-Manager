//
//  TimerView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/02.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel:TimerViewModel
    
    var body: some View {
        HStack(alignment: .bottom){
            ZStack{
                if(viewModel.isAlarmActive){
                    VStack{
                        Button(action: {viewModel.stopAlarm()}, label: {
                            Text("停止")
                        }).tint(.orange).frame(maxWidth: 50)
                    }
                }else{
                    VStack(alignment: .center) {
                        Text(viewModel.timeString)
                            .font(.title3)
                            .padding(5)
                    }.onReceive(viewModel.$timeString) { newValue in}
                    CircleProgressBarView(progress: $viewModel.progress).frame(maxWidth: 30)
                }
            }
            if(!viewModel.isAlarmActive){
            Button(action: {
                if viewModel.timer == nil {
                    viewModel.start() // タイマー開始
                } else {
                    viewModel.stop() // タイマー停止
                }
            }) {
                Image(systemName: viewModel.timer == nil ? "play.circle.fill" : "pause.circle.fill").foregroundStyle(viewModel.timer == nil ? Color.blue : Color.red)
            }.buttonStyle(.borderless)
        }
        }
    }
}

#Preview {
    TimerView(viewModel: TimerViewModel(initialTime: 355, menuName: "3v2"))
}
