//
//  DuokuApp.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//

import SwiftUI
import SwiftData

@main
struct DuokuApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
            // The main view of the app is our custom SudokuView.
            SudokuView()
        }
        .modelContainer(sharedModelContainer)
    }
}
