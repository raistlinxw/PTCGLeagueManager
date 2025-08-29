//
//  PTCGLeagueManagerApp.swift
//  PTCGLeagueManager
//
//  Created by Michael Parker on 7/15/24.
//

import SwiftUI
//import SwiftData

@main
struct PTCGLeagueManagerApp: App {
    @StateObject private var playerList = PlayerListModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(playerList)
        }
    }
}
