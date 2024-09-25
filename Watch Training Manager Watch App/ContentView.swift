//
//  ContentView.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: TrainingSessionViewModel // EnvironmentObjectとして使用

    var body: some View {
        TodaySessionView() // ViewModelはEnvironmentObjectから自動的に取得
    }
}

#Preview {
    ContentView()
}
