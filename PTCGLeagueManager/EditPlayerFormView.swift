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
    @State private var dob: Date = Date()
//    @State private var dob: Date? = Date()
    @State private var email: String
    @State private var phoneNumber: String
    @State private var discord: String
    @State private var includeDOB: Bool
    @State private var isShowingGroupView = false
    @State private var editAlert = false

    init(player: Binding<Player>) {
        self._player = player
        self._firstName = State(initialValue: player.wrappedValue.firstName)
        self._lastName = State(initialValue: player.wrappedValue.lastName)
        self._playerid = State(initialValue: player.wrappedValue.playerid)
        self._dob = State(initialValue: player.wrappedValue.dob ?? Date())
        self._email = State(initialValue: player.wrappedValue.email)
        self._phoneNumber = State(initialValue: player.wrappedValue.phoneNumber)
        self._discord = State(initialValue: player.wrappedValue.discord)
        self._includeDOB = State(initialValue: player.wrappedValue.dob != nil)
    }
    
    private var hasChanges: Bool {
        return firstName != player.firstName ||
               lastName != player.lastName ||
               playerid != player.playerid ||
               dob != player.dob ||
               email != player.email ||
               phoneNumber != player.phoneNumber ||
               discord != player.discord ||
               includeDOB != (player.dob != nil)
    }

    var body: some View {
        Form {
            Section(header: Text("Edit Player Information")) {
                CustomTextField(placeholder: "First Name", text: $firstName)
                CustomTextField(placeholder: "Last Name", text: $lastName)
                
                
                YearPicker(selection: $dob)

//                YearPicker(selection: Binding(
////                    get: { dob ?? Date() },
//                    get: { dob },
//                    set: { dob = $0 }
//                ))
                
                //                CustomTextField(placeholder: "Player ID", text: $playerid)
                CustomTextField(placeholder: "Player ID", text: $playerid)
                    .keyboardType(.numberPad)
            }
                Button("Add to Group") {
                    isShowingGroupView = true
                }

                Button("Save") {
                    editAlert = true
                }
                .disabled(!hasChanges)
            Section(header: Text("Player Information")) {
                CustomTextField(placeholder: "Email", text: $email)
                CustomTextField(placeholder: "Discord", text: $discord)
                CustomTextField(placeholder: "Phone Number", text: $phoneNumber)
            }
            
          
        }
        .alert(isPresented: $editAlert, content: {
            Alert(
                title: Text("Confirm Save"),
                message: Text("Are you sure you want to apply these changes?"),
                primaryButton: .default(Text("Yes")) {
                    saveChanges()
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("No"))
            )
        })
        .sheet(isPresented: $isShowingGroupView) {
                GroupView(player: $player)
        }
        .navigationTitle("Edit Player")
    }

    func saveChanges() {
        player.firstName = firstName
        player.lastName = lastName
        player.playerid = playerid
        player.dob = dob
//        player.dob = includeDOB ? dob : nil
        player.email = email
        player.phoneNumber = phoneNumber
        player.discord = discord
    }
}
