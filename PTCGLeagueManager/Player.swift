//
//  Player.swift
//  PTCGLeagueManager
//
//  Created by Glen Parker on 2/5/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model public class PlayerObject {
    @Attribute(.unique) public var id: UUID
    public var firstName: String
    public var lastName: String
    public var playerid: String
    public var dob: Date?
    public var email: String
    public var phoneNumber: String
    public var discord: String
    public var groupID: UUID
    public var isChecked: Bool
    public var attendance: Int
    public var lastDateChecked: Date?
    
    public init (){
        self.id = UUID()
        self.firstName = ""
        self.lastName = ""
        self.playerid = ""
        self.dob = Date()
        self.email = ""
        self.phoneNumber = ""
        self.discord = ""
        self.groupID = ungroupedUUID
        self.isChecked = false
        self.attendance = 0
        self.lastDateChecked = Date()
    }
}

@Model class AttendanceRecord {
    @Attribute(.unique) public var id: UUID
    var date: Date
    var player: PlayerObject?
    
    init(id: UUID = UUID(), date: Date, player: PlayerObject? = nil) {
        self.id = id
        self.date = date
        self.player = player
    }
}
