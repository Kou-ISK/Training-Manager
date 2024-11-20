//
//  Watch_Training_Manager_App.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import SwiftUI
import SwiftData
import FirebaseCore

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    func applicationDidFinishLaunching() {
        FirebaseApp.configure()
    }
}

@main
struct Watch_Training_Manager_Watch_App: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate
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
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewModel).modelContainer(sharedModelContainer)
        }
    }
}
