//
//  AddPlayerFormView.swift
//  PTCGLeagueManager
//
//  Created by Michael Parker on 8/2/24.
//

import SwiftUI

struct AddPlayerFormView: View {
    @EnvironmentObject var playerList: PlayerListModel
    @Environment(\.presentationMode) var presentationMode

    @State var newPlayer = Player()
    @State private var includeDOB = false

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var isShowingGroupView = false

    var body: some View {
        Form {
            Section(header: Text("Player Information")) {
                CustomTextField(placeholder: "First Name", text: $newPlayer.firstName)
                CustomTextField(placeholder: "Last Name", text: $newPlayer.lastName)
                
                Toggle("Include Date of Birth", isOn: $includeDOB)
                if includeDOB {
                    YearPicker(selection: Binding(
                        get: { newPlayer.dob ?? Date() },
                        set: { newPlayer.dob = $0 }
                    ))
                }

                CustomTextField(placeholder: "Player ID", text: $newPlayer.playerid)
                CustomTextField(placeholder: "Email", text: $newPlayer.email)
                CustomTextField(placeholder: "Discord", text: $newPlayer.discord)
                CustomTextField(placeholder: "Phone Number", text: $newPlayer.phoneNumber)
            }
            
            Button("Add to Group") {
                isShowingGroupView = true
            }

            Button("Save") {
                addPlayer(newPlayer: newPlayer)
            }
        }
        .navigationTitle("Add Player")
        .sheet(isPresented: $isShowingGroupView) {
                GroupView(player: $newPlayer)
        }
        .alert(errorTitle, isPresented: $showingError) {
        } message: {
            Text(errorMessage)
        }
    }

    func addPlayer(newPlayer: Player) {
        guard isFullName(firstName: newPlayer.firstName, lastName: newPlayer.lastName) else {
            addPlayerError(title: "Full name required", message: "Please include a first and last name")
            return
        }

        if !includeDOB {
            self.newPlayer.dob = nil
        }

        playerList.players.append(newPlayer)
        presentationMode.wrappedValue.dismiss()
    }

    func isFullName(firstName: String, lastName: String) -> Bool {
        return (firstName != "" && lastName != "")
    }

    func addPlayerError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

