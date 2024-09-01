//
//  Training_ManagerApp.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/27.
//

import SwiftUI
import SwiftData

@main
struct Training_ManagerApp: App {
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
            ContentView().modelContainer(sharedModelContainer)
        }
    }
}
