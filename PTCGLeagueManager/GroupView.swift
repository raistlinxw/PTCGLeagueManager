// TO DO
// Show the player I am grouping on this page somewhere
// Add the ability to create a new group with ungrouped players
// BUG: If I add a player to a group, then select another player, it should add that selected player to the group I am already in

import SwiftUI

struct GroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var playerList: PlayerListModel
    @Binding var player: Player
    
    @State private var selectedPlayer = Player()
    @State private var showingWarning = false
    @State private var showConfirmation = false
    @State var warningTitle = ""
    @State var warningMessage = ""
    @State private var tempPlayer: Player
    @State private var previewGroupID: UUID? // To track the group ID where the player is previewed
    @State private var searchText = ""
    
    init(player: Binding<Player>) {
        self._player = player
        // Initialize the tempPlayer with the current player’s state
        self._tempPlayer = State(initialValue: player.wrappedValue)
        self._previewGroupID = State(initialValue: player.wrappedValue.groupID)
    }
    
    var body: some View {
        NavigationView {
            List {
                let filteredPlayers = filterPlayerList()
                let uniqueGroupIDs = getUniqueSortedGroupIDs(from: filteredPlayers)
                
                ForEach(Array(uniqueGroupIDs.enumerated()), id: \.element) { index, groupID in
                    Section(header: Text("Group \(index + 1)")) {
                        // Preview the player in this group
                        if previewGroupID == groupID {
                            Text("\(tempPlayer.fullName())")
                                .italic()
                                .foregroundColor(.blue)
                        }
                        ForEach(playersInGroup(groupID, from: filteredPlayers)) { listPlayer in
                            if previewGroupID != groupID || listPlayer.id != player.id {
                                Text("\(listPlayer.fullName())")
                            }
                        }
                    }
                    .onTapGesture {
                        handleGroupTap(groupID: groupID, index: index)
                    }
                }
                
                Section(header: Text("Ungrouped")) {
                    ForEach(filteredPlayers.filter { $0.groupID == ungroupedUUID }) { listPlayer in
                        if previewGroupID != ungroupedUUID || listPlayer.id != player.id {
                            Text("\(listPlayer.fullName())")
                            .onTapGesture {
                                handleUngroupedTap(listPlayer: listPlayer)
                            }
                        }
                    }
                    // Preview the player in the ungrouped section
                    if previewGroupID == ungroupedUUID {
                        Text("\(tempPlayer.fullName())")
                            .italic()
                            .foregroundColor(.blue)
                    }
                }
                
            }
            .navigationTitle("Player Groups")
            .searchable(text: $searchText, prompt: "Search Players")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        savePlayerChanges()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $showingWarning) {
                Alert(
                    title: Text(warningTitle),
                    message: Text(warningMessage),
                    dismissButton: .default(Text("OK")) {
                        addToGroup(tempPlayer: &tempPlayer, newGroupID: getGroupID(selectedPlayer: selectedPlayer))
                    }
                )
            }
        }
    }
    
    private func filterPlayerList() -> [Player] {
        return playerList.players.filter { player in
            searchText.isEmpty || player.firstName.localizedCaseInsensitiveContains(searchText) || player.lastName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func getUniqueSortedGroupIDs(from players: [Player]) -> [UUID] {
        let allGroupIDs = players.map { $0.groupID }
        let filteredGroupIDs = allGroupIDs.filter { $0 != ungroupedUUID }
        let uniqueGroupIDs = Array(Set(filteredGroupIDs))
        return uniqueGroupIDs.sorted { $0.uuidString < $1.uuidString }
    }

    private func playersInGroup(_ groupID: UUID, from players: [Player]) -> [Player] {
        return players.filter { $0.groupID == groupID }
    }
    
    private func handleGroupTap(groupID: UUID, index: Int) {
        print("Group \(index + 1) tapped")
        
        let filteredPlayers = filterPlayerList()  // Get the filtered list
        
        if let anyPlayerInGroup = playersInGroup(groupID, from: filteredPlayers).first {
            selectedPlayer = anyPlayerInGroup
            print("Selected Player is \(selectedPlayer.fullName()) in Group \(selectedPlayer.groupID)")
        } else {
            selectedPlayer = Player(firstName: "N/A", lastName: "N/A", groupID: groupID)
        }
        previewPlayerInGroup(groupID: groupID)
        displayWarning(title: "Adding \(player.fullName()) to Group \(index + 1)", message: "Press save to confirm")
    }
    
    private func handleUngroupedTap(listPlayer: Player) {
        print("Ungrouped Player Tapped")
        
        selectedPlayer = listPlayer
        previewPlayerInGroup(groupID: ungroupedUUID)
        if let playerIndex = playerList.players.firstIndex(where: { $0.id == listPlayer.id }) {
            playerList.players[playerIndex].groupID = UUID()
            tempPlayer.groupID = playerList.players[playerIndex].groupID
        }
        
        displayWarning(title: "Adding \(player.fullName()) and \(listPlayer.fullName()) to a group", message: "Press save to confirm")
    }
    
    private func previewPlayerInGroup(groupID: UUID) {
        previewGroupID = groupID
        tempPlayer.groupID = groupID
        print("Previewing \(tempPlayer.fullName()) in Group \(groupID)")
    }
    
    private func savePlayerChanges() {
        player.groupID = tempPlayer.groupID
        print("Real Player \(player.fullName()) is now in Group \(player.groupID)")
        presentationMode.wrappedValue.dismiss()
    }
    
    private func getGroupID(selectedPlayer: Player) -> UUID {
        if let playerIndex = playerList.players.firstIndex(where: { $0.id == selectedPlayer.id }) {
            print("getGroupID is returning \(playerList.players[playerIndex].groupID)")
            return playerList.players[playerIndex].groupID
        }
        return ungroupedUUID
    }
    
    private func addToGroup(tempPlayer: inout Player, newGroupID: UUID) {
        tempPlayer.groupID = newGroupID
        previewGroupID = newGroupID // Update the preview as well
        print("Temp Player \(tempPlayer.fullName()) is now in Group \(tempPlayer.groupID)")
    }
    
    func displayWarning(title: String, message: String) {
        warningTitle = title
        warningMessage = message
        showingWarning = true
    }
}
