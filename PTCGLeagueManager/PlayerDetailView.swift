//
//  PlayerDetailView.swift
//  PTCGLeagueManager
//
//  Created by Michael Parker on 8/2/24.
//

import SwiftUI

struct PlayerDetailView: View {
    @Binding var player: Player
    @EnvironmentObject var playerList: PlayerListModel
    @State private var isShowingEditPlayerForm = false
    @Environment(\.presentationMode) var presentationMode
    @State private var deleteAlert = false

    var body: some View {
        VStack {
            detailRow(labelText: "First Name", value: player.firstName)
            detailRow(labelText: "Last Name", value: player.lastName)
            detailRow(labelText: "Date of Birth", value: player.dob != nil ? DateFormatter.year.string(from: player.dob!) : "Not Available")
            detailRow(labelText: "Player ID", value: player.playerid != "" ? player.playerid : "Not Available")
            detailRow(labelText: "Email", value: player.email != "" ? player.email : "Not Available")
            detailRow(labelText: "Phone Number", value: player.phoneNumber != "" ? player.phoneNumber : "Not Available")
            detailRow(labelText: "Discord", value: player.discord != "" ? player.discord : "Not Available")
            detailRow(labelText: "Attendance", value: player.attendance != 0 ? String(player.attendance) : "0")

        }
        .navigationTitle("Player Details")
        .toolbar {
            Button(action: {
                deleteAlert = true
            }) {
                Image(systemName: "trash")
            }
            
            Button(action: {
                isShowingEditPlayerForm = true
            }) {
                Image(systemName: "pencil")
            }
        }
        .alert(isPresented: $deleteAlert, content: {
            Alert(
                title: Text("Confirm Delete"),
                message: Text("Are you sure you want to delete this player?"),
                primaryButton: .destructive(Text("Yes")) {
                    deletePlayer(player: player)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("No"))
            )
        })
        .sheet(isPresented: $isShowingEditPlayerForm) {
            NavigationView {
                EditPlayerFormView(player: $player)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isShowingEditPlayerForm = false
                            }
                        }
                    }
            }
        }
    }
    
    func deletePlayer(player: Player) {
        if let playerIndex = playerList.players.firstIndex(where: { $0.id == player.id }) {
            playerList.players.remove(at: playerIndex)
        }
    }

    func detailRow(labelText: String, value: String) -> some View {
        HStack {
            Text("\(labelText): ")
            Spacer()
            Text(value)
        }
        .padding(.horizontal)
    }
}
