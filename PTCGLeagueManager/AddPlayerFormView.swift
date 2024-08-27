import SwiftUI

struct AddPlayerFormView: View {
    @EnvironmentObject var playerList: PlayerListModel
    @Environment(\.presentationMode) var presentationMode

    @State var newPlayer = Player()
    @State private var includeDOB = false
    @FocusState private var isFocused: Bool

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var isShowingGroupView = false
    @State private var dob: Date = Date()

    var body: some View {
        Form {
            Section(header: Text("Player Information")) {
                CustomTextField(placeholder: "First Name", text: $newPlayer.firstName)
                    .focused($isFocused)
                
                CustomTextField(placeholder: "Last Name", text: $newPlayer.lastName)
                
//                Toggle("Include Date of Birth", isOn: $includeDOB)
//                if includeDOB {
                    YearPicker(selection: $dob)
//                }

                CustomTextField(placeholder: "Player ID", text: $newPlayer.playerid)
                    .keyboardType(.numberPad)
                CustomTextField(placeholder: "Email", text: $newPlayer.email)
                CustomTextField(placeholder: "Discord", text: $newPlayer.discord)
                CustomTextField(placeholder: "Phone Number", text: $newPlayer.phoneNumber)
                    .keyboardType(.numberPad)
            }
            
            Button("Add to Group") {
                isShowingGroupView = true
            }

            Button("Save") {
                addPlayer(newPlayer: newPlayer)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = true
            }
        }
        .onChange(of: dob) {
            newPlayer.dob = dob
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
        } else {
            self.newPlayer.dob = dob
        }
        
        self.newPlayer.isChecked = true
        self.newPlayer.attendance = 1

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
