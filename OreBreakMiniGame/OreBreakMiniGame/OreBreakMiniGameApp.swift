//
//  OreBreakMiniGameApp.swift
//  OreBreakMiniGame
//
//  Created by 石原脩平 on 2025/11/26.
//

import SwiftUI
import CoreData

@main
struct OreBreakMiniGameApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
