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
        ZStack{
            if(viewModel.isAlarmActive){
                VStack{
                    Button(action: {viewModel.stopAlarm()}, label: {
                        Text("アラーム停止").bold().padding(10)
                            .foregroundColor(.white)
                        .background(.orange,in: RoundedRectangle(cornerRadius: 12))})
                }
            }else{
                VStack(alignment: .center) {
                    Text(viewModel.timeString)
                        .font(.headline)
                        .padding(5)
                    Button(action: {
                        if viewModel.timer == nil {
                            viewModel.start() // タイマー開始
                        } else {
                            viewModel.stop() // タイマー停止
                        }
                    }) {
                        Text(viewModel.timer == nil ? "開始" : "停止").fontWeight(.bold)
                    }.buttonStyle(.borderedProminent)
                }.onReceive(viewModel.$timeString) { newValue in}
                CircleProgressBarView(progress: $viewModel.progress).frame(maxWidth: 120)
            }
        }
    }
}

#Preview {
    TimerView(viewModel: TimerViewModel(initialTime: 355, menuName: "3v2"))
}
