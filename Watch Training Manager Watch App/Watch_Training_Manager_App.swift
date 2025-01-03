//
//  Watch_Training_Manager_App.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import SwiftUI
import SwiftData

@main
struct Watch_Training_Manager_Watch_App: App {
    @StateObject var viewModel = TrainingSessionViewModel()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TrainingSession.self,
            TrainingMenu.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    private func setupCrashHandler() {
        NSSetUncaughtExceptionHandler { exception in
            let stackTrace = exception.callStackSymbols.joined(separator: "\n")
            let message = "Exception: \(exception.name)\nReason: \(exception.reason ?? "Unknown")\n\(stackTrace)"
            
            // ログの保存や送信
            ErrorLogger.shared.logError(message: message)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewModel).modelContainer(sharedModelContainer).onAppear {
                setupCrashHandler()
            }
        }
    }
}
