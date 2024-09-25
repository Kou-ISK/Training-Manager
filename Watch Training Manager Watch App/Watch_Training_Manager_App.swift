//
//  Watch_Training_Manager_App.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import SwiftUI

@main
struct Watch_Training_Manager_Watch_App: App {
    @StateObject var viewModel = TrainingSessionViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewModel)
        }
    }
}
