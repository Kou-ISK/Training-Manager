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
    let modelContainer: ModelContainer
    @StateObject private var viewModel: TrainingSessionViewModel
    
    init() {
        let schema = Schema([
            TrainingSession.self,
            TrainingMenu.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.modelContainer = container
            let context = ModelContext(container)
            self._viewModel = StateObject(wrappedValue: TrainingSessionViewModel(modelContext: context))
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .modelContainer(modelContainer)
        }
    }
}
