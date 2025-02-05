//
//  PTCGLeagueManagerApp.swift
//  PTCGLeagueManager
//
//  Created by Michael Parker on 7/15/24.
//

import SwiftUI
import SwiftData

@main
struct PTCGLeagueManagerApp: App {
//    @StateObject private var playerList = PlayerListModel()
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([PlayerObject.self, AttendanceRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .environmentObject(playerList)
                .modelContainer(sharedModelContainer)
        }
    }
}
