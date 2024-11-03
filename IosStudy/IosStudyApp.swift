//
//  IosStudyApp.swift
//  IosStudy
//
//  Created by mathmaster on 8/5/24.
//

import SwiftUI
import SwiftData

@main
struct IosStudyApp: App {
    var modelContainer: ModelContainer = {
        let schema = Schema([Learner.self])
        
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("ModelContainer 생성 실패!!!: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
