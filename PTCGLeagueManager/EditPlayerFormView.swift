//
//  EditPlayerFormView.swift
//  PTCGLeagueManager
//
//  Created by Michael Parker on 8/2/24.
//

import SwiftUI

struct EditPlayerFormView: View {
    @Binding var player: Player
    @Environment(\.presentationMode) var presentationMode

    @State private var firstName: String
    @State private var lastName: String
    @State private var playerid: String
    @State private var dob: Date?
    @State private var email: String
    @State private var phoneNumber: String
    @State private var discord: String
    @State private var includeDOB: Bool
    @State private var isShowingGroupView = false

    init(player: Binding<Player>) {
        self._player = player
        self._firstName = State(initialValue: player.wrappedValue.firstName)
        self._lastName = State(initialValue: player.wrappedValue.lastName)
        self._playerid = State(initialValue: player.wrappedValue.playerid)
        self._dob = State(initialValue: player.wrappedValue.dob)
        self._email = State(initialValue: player.wrappedValue.email)
        self._phoneNumber = State(initialValue: player.wrappedValue.phoneNumber)
        self._discord = State(initialValue: player.wrappedValue.discord)
        self._includeDOB = State(initialValue: player.wrappedValue.dob != nil)
    }

    var body: some View {
        Form {
            Section(header: Text("Edit Player Information")) {
                CustomTextField(placeholder: "First Name", text: $firstName)
                CustomTextField(placeholder: "Last Name", text: $lastName)
                
                Toggle("Include Date of Birth", isOn: $includeDOB)
                if includeDOB {
                    YearPicker(selection: Binding(
                        get: { dob ?? Date() },
                        set: { dob = $0 }
                    ))
                }
                
                CustomTextField(placeholder: "Player ID", text: $playerid)
                CustomTextField(placeholder: "Email", text: $email)
                CustomTextField(placeholder: "Discord", text: $discord)
                CustomTextField(placeholder: "Phone Number", text: $phoneNumber)
            }
            
            Button("Add to Group") {
                isShowingGroupView = true
            }

            Button("Save") {
                saveChanges()
                presentationMode.wrappedValue.dismiss()
            }
        }
        .sheet(isPresented: $isShowingGroupView) {
                GroupView(player: $player)
        }
        .navigationTitle("Edit Player")
    }

    func saveChanges() {
        player.firstName = firstName
        player.lastName = lastName
        player.playerid = playerid
        player.dob = includeDOB ? dob : nil
        player.email = email
        player.phoneNumber = phoneNumber
        player.discord = discord
    }
}
