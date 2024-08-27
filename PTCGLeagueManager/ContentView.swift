//
//  ContentView.swift
//  PTCGLeagueManager
//
//  Created by Michael Parker on 7/15/24.
//

// TODO
//When I add a person to a group, it messes up the sort order of the names on the main list.    I don't see an obvious pattern/error to the sort order after adding a person to a group.    This probably is manifesting itself after a few days of data entry when the sort is factoring in last attendance date.
//
//-- Advanced Request:
//A way to filter/tab/switch views between unmarked people  and marked people, or a way to quickly change the sort order from 'default :unmarked, most recent, alphabetical' to 'marked, most recent, alphabetical'  .    I found myself wanting to verify people marked, to make sure I entered them, and having to scroll to the bottom was tedious.


import SwiftUI

struct ContentView: View {
    
    @StateObject private var formDataManager = FormDataManager()
    @EnvironmentObject var playerList: PlayerListModel
    
    @State private var timer: Timer?
    @State private var searchText: String = ""
    @State private var activeSheet: ActiveSheet?
    @State private var toggledPlayerID: UUID?
    @State private var selectedGroup: UUID?
    
    @State var monthlyreportAlert = false
    @State private var showingResetAlert = false
    @State private var useShortTitle = false
    
// Possible fix for a filter button in Nav Title
//    HStack {
//        Text("Today")
//            .font(.largeTitle.bold())
//        
//        Spacer()
//        
//        Image(systemName: "person.crop.circle")
//    }
//    .padding()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(sortPlayerList()) { player in
                        VStack(alignment: .leading) {
                            Toggle(isOn: Binding(
                                get: { player.isChecked },
                                set: { newValue in
                                    toggleCheck(for: player)
                                }
                            )) {
                                Text(player.fullName())
                                    .swipeActions(allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            print("Deleting player")
                                        } label: {
                                            Label("Delete", systemImage: "trash.fill")
                                        }
                                        Button {
                                            print("Viewing Details of Player")
                                            activeSheet = .playerDetail(player)
                                        } label: {
                                            Label("Edit", systemImage: "info.circle")
                                        }
                                        .tint(.indigo)
                                    }
                                    .font(.headline)
                                    .strikethrough(player.isChecked, color: .primary)
                                    .foregroundColor(player.isChecked ? .gray : .primary)
                            }
                        }
                    }
                    //                Button(action: {
                    //                    UserDefaults.standard.resetDefaults()
                    //                    resetPlayerListTest()
                    //                }) {
                    //                    Text("Reset To Test List")
                    //                        .foregroundColor(.red)
                    //                        .frame(maxWidth: .infinity, alignment: .center)
                    //                }
                    Button(action: {
                        print("reset button pressed")
                        showingResetAlert = true
                    }) {
                        Text("Reset List")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .alert(isPresented: $showingResetAlert) {
                        Alert(
                            title: Text("Are you sure?"),
                            message: Text("This will reset the entire player list. This action cannot be undone."),
                            primaryButton: .destructive(Text("Yes")) {
                                UserDefaults.standard.resetDefaults()
                                resetPlayerList()
                            },
                            secondaryButton: .cancel(Text("No"))
                        )
                    }
                }
                //END OF LIST
//                .padding(.top, -40)
            }
            // END OF VSTACK
//            .navigationBarHidden(true)
            .navigationTitle(useShortTitle ? "\(Date.now, formatter: DateFormatter.slashes)" : "\(Date.now, formatter: DateFormatter.monthDayYear)")
            .alert(isPresented: $monthlyreportAlert) {
                Alert(
                    title: Text("Important message"),
                    message: Text("Monthly Report Generated"),
                    dismissButton: .default(Text("OK")) {
                        monthlyreportAlert = false
                    }
                )
            }
            .sheet(item: $activeSheet) { item in
                switch item {
                case .addPlayerForm:
                    NavigationView {
                        AddPlayerFormView()
                            .environmentObject(playerList)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Cancel") {
                                        activeSheet = nil
                                    }
                                }
                            }
                    }
                case .attendanceForm:
                    NavigationView {
                        AttendanceReportView(formDataManager: formDataManager)
                            .environmentObject(playerList)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Close") {
                                        activeSheet = nil
                                    }
                                }
                            }
                    }
                case .fileImport:
                    NavigationView {
                        FileImporterView()
                            .environmentObject(playerList)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Close") {
                                        activeSheet = nil
                                    }
                                }
                            }
                    }
                case .playerDetail(let player):
                    NavigationView {
                        if let playerIndex = playerList.players.firstIndex(where: { $0.id == player.id }) {
                            PlayerDetailView(player: $playerList.players[playerIndex])
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button("Close") {
                                            activeSheet = nil
                                        }
                                    }
                                }
                        }
                    }
                }
                
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Players")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        activeSheet = .fileImport
                    }) {
                        Image(systemName: "tray.and.arrow.down")                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        activeSheet = .attendanceForm
                    }) {
                        Image(systemName: "folder")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        activeSheet = .addPlayerForm
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        formDataManager.generateForm(from: playerList.players, filename: "AttendanceReport_\(DateFormatter.underscores.string(from: Date.now)).txt")
                        monthlyreportAlert = true
                    }) {
                        Text("Create Report")
                    }
                }
            }
            .onAppear {
                checkForDailyReset(&playerList.players)
                checkForMonthlyReset(&playerList.players)
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
        }
        // END OF NAV VIEW
        
// Another possible fix for nav title filter button
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                HStack {
////                        Image(systemName: "sun.min.fill")
//                    Text("\(Date.now, formatter: DateFormatter.slashes)").font(.headline)
//                }
//            }
//        }
        
    }
    
    private func filterPlayerList() -> [Player] {
        return playerList.players.filter { player in
            searchText.isEmpty || player.firstName.localizedCaseInsensitiveContains(searchText) || player.lastName.localizedCaseInsensitiveContains(searchText)
        }
    }
        
    private func sortPlayerList() -> [Player] {
        return filterPlayerList().sorted { (firstPlayer, secondPlayer) -> Bool in
            // Ensure unchecked players are always at the top
            if firstPlayer.isChecked != secondPlayer.isChecked {
                return !firstPlayer.isChecked && secondPlayer.isChecked
            }
            
            // Bring selected group to the top
            if firstPlayer.groupID == selectedGroup && secondPlayer.groupID != selectedGroup && selectedGroup != ungroupedUUID  {
                return true
            } else if firstPlayer.groupID != selectedGroup && secondPlayer.groupID == selectedGroup {
                return false
            }
            
            // If both players have the same checked status, sort by last date checked
            if firstPlayer.lastDateChecked != secondPlayer.lastDateChecked {
                // Sort by the most recent date first (descending order)
                return firstPlayer.lastDateChecked ?? Date.distantPast > secondPlayer.lastDateChecked ?? Date.distantPast
            }
            
            // If both players have the same checked status and last date checked, sort by attendance in descending order
            if firstPlayer.attendance != secondPlayer.attendance {
                return firstPlayer.attendance > secondPlayer.attendance
            }
            
            // If all the above are the same, sort alphabetically by full name
            return firstPlayer.fullName() < secondPlayer.fullName()
        }
    }
    
    private func toggleCheck(for player: Player) {
        if let index = playerList.players.firstIndex(where: { $0.id == player.id }) {
            // Immediately toggle the player's check status with a short animation
            withAnimation(.easeInOut(duration: 0.4)) {
                playerList.players[index].isChecked.toggle()
                playerList.players[index].attendance += playerList.players[index].isChecked ? 1 : -1
                playerList.players[index].lastDateChecked = Date.now
                
                // Set the selected group to the group of the toggled player
                selectedGroup = playerList.players[index].groupID
                toggledPlayerID = player.id
            }

            toggledPlayerID = nil
        }
    }
    
    // Timer functions
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 43200, repeats: true) { _ in
            checkForDailyReset(&playerList.players)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // Reset functions
    private func checkForDailyReset(_ playerList: inout [Player]) {
        let now = Date()
        let calendar = Calendar.current

        if let nextResetDate = UserDefaults.standard.object(forKey: "nextResetDate") as? Date {
            if now >= nextResetDate {
                resetVariable(&playerList)
                let newResetDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
                UserDefaults.standard.set(newResetDate, forKey: "nextResetDate")
            }
        } else {
            resetVariable(&playerList)
            let newResetDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
            UserDefaults.standard.set(newResetDate, forKey: "nextResetDate")
        }
    }

    private func checkForMonthlyReset(_ playerList: inout [Player]) {
        let now = Date()
        if isNewMonth(lastCheckedDate: now) {
            formDataManager.generateForm(from: playerList, filename: "\(DateFormatter.monthyear.string(from: Date.now))MonthlyReport")
            for index in playerList.indices where playerList[index].attendance > 0 {
                playerList[index].attendance = 0
            }
        }
    }

    private func isNewMonth(lastCheckedDate: Date?) -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()
        guard let lastDate = lastCheckedDate else {
            return isStartOfMonth()
        }
        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
        let lastComponents = calendar.dateComponents([.year, .month], from: lastDate)
        return currentComponents != lastComponents
    }

    private func isStartOfMonth() -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()
        let dayComponent = calendar.component(.day, from: currentDate)
        return dayComponent == 1
    }

    private func resetVariable(_ playerList: inout [Player]) {
        for index in playerList.indices where playerList[index].isChecked {
            playerList[index].isChecked = false
//            playerList[index].attendance += 1
        }
    }
    
    private func resetPlayerList() {
        playerList.players = []
        playerList.saveToUserDefaults()
    }
    
    private func resetPlayerListTest() {
        let group1ID = UUID()
        let group2ID = UUID()
        let group3ID = UUID()
        let group4ID = UUID()
        let group5ID = UUID()
        let group6ID = UUID()
        let group7ID = UUID()
        let group8ID = UUID()
        let group9ID = UUID()

        
        // Create a list of players
        playerList.players = [
            // Group 1 (5 players)
            Player(firstName: "Alice", lastName: "Smith", playerid: "1000001", dob: DateComponents(calendar: .current, year: 1990, month: 1, day: 15).date!, groupID: group1ID),
            Player(firstName: "Bob", lastName: "Smith", playerid: "1000002", dob: DateComponents(calendar: .current, year: 1988, month: 3, day: 22).date!, groupID: group1ID),
            Player(firstName: "Charlie", lastName: "Smith", playerid: "1000003", dob: DateComponents(calendar: .current, year: 1992, month: 5, day: 10).date!, groupID: group1ID),
            Player(firstName: "Diane", lastName: "Smith", playerid: "1000004", dob: DateComponents(calendar: .current, year: 1994, month: 7, day: 30).date!, groupID: group1ID),
            Player(firstName: "Ethan", lastName: "Smith", playerid: "1000005", dob: DateComponents(calendar: .current, year: 1996, month: 9, day: 25).date!, groupID: group1ID),

            // Group 2 (4 players)
            Player(firstName: "David", lastName: "Johnson", playerid: "1000006", dob: DateComponents(calendar: .current, year: 1987, month: 12, day: 4).date!, groupID: group2ID),
            Player(firstName: "Eve", lastName: "Johnson", playerid: "1000007", dob: DateComponents(calendar: .current, year: 1991, month: 2, day: 14).date!, groupID: group2ID),
            Player(firstName: "Frank", lastName: "Johnson", playerid: "1000008", dob: DateComponents(calendar: .current, year: 1993, month: 4, day: 8).date!, groupID: group2ID),
            Player(firstName: "Grace", lastName: "Johnson", playerid: "1000009", dob: DateComponents(calendar: .current, year: 1995, month: 6, day: 18).date!, groupID: group2ID),

            // Group 3 (5 players)
            Player(firstName: "George", lastName: "Williams", playerid: "1000010", dob: DateComponents(calendar: .current, year: 1989, month: 1, day: 5).date!, groupID: group3ID),
            Player(firstName: "Hannah", lastName: "Williams", playerid: "1000011", dob: DateComponents(calendar: .current, year: 1990, month: 10, day: 10).date!, groupID: group3ID),
            Player(firstName: "Ian", lastName: "Williams", playerid: "1000012", dob: DateComponents(calendar: .current, year: 1992, month: 3, day: 15).date!, groupID: group3ID),
            Player(firstName: "Jack", lastName: "Williams", playerid: "1000013", dob: DateComponents(calendar: .current, year: 1994, month: 5, day: 22).date!, groupID: group3ID),
            Player(firstName: "Kara", lastName: "Williams", playerid: "1000014", dob: DateComponents(calendar: .current, year: 1996, month: 7, day: 30).date!, groupID: group3ID),

            // Group 4 (3 players)
            Player(firstName: "Jack", lastName: "Brown", playerid: "1000015", dob: DateComponents(calendar: .current, year: 1985, month: 4, day: 20).date!, groupID: group4ID),
            Player(firstName: "Karen", lastName: "Brown", playerid: "1000016", dob: DateComponents(calendar: .current, year: 1989, month: 8, day: 14).date!, groupID: group4ID),
            Player(firstName: "Liam", lastName: "Brown", playerid: "1000017", dob: DateComponents(calendar: .current, year: 1992, month: 11, day: 5).date!, groupID: group4ID),

            // Group 5 (2 players)
            Player(firstName: "Leo", lastName: "Jones", playerid: "1000018", dob: DateComponents(calendar: .current, year: 1986, month: 2, day: 14).date!, groupID: group5ID),
            Player(firstName: "Mia", lastName: "Jones", playerid: "1000019", dob: DateComponents(calendar: .current, year: 1988, month: 3, day: 20).date!, groupID: group5ID),

            // Group 6 (4 players)
            Player(firstName: "Nina", lastName: "Garcia", playerid: "1000020", dob: DateComponents(calendar: .current, year: 1985, month: 6, day: 12).date!, groupID: group6ID),
            Player(firstName: "Oscar", lastName: "Garcia", playerid: "1000021", dob: DateComponents(calendar: .current, year: 1989, month: 9, day: 25).date!, groupID: group6ID),
            Player(firstName: "Pablo", lastName: "Garcia", playerid: "1000022", dob: DateComponents(calendar: .current, year: 1991, month: 11, day: 5).date!, groupID: group6ID),
            Player(firstName: "Quinn", lastName: "Garcia", playerid: "1000023", dob: DateComponents(calendar: .current, year: 1994, month: 12, day: 14).date!, groupID: group6ID),

            // Group 7 (2 players)
            Player(firstName: "Paul", lastName: "Miller", playerid: "1000024", dob: DateComponents(calendar: .current, year: 1987, month: 4, day: 18).date!, groupID: group7ID),
            Player(firstName: "Quinn", lastName: "Miller", playerid: "1000025", dob: DateComponents(calendar: .current, year: 1990, month: 7, day: 8).date!, groupID: group7ID),

            // Group 8 (5 players)
            Player(firstName: "Rita", lastName: "Miller", playerid: "1000026", dob: DateComponents(calendar: .current, year: 1991, month: 8, day: 24).date!, groupID: group8ID),
            Player(firstName: "Sam", lastName: "Miller", playerid: "1000027", dob: DateComponents(calendar: .current, year: 1993, month: 9, day: 11).date!, groupID: group8ID),
            Player(firstName: "Tina", lastName: "Miller", playerid: "1000028", dob: DateComponents(calendar: .current, year: 1995, month: 10, day: 2).date!, groupID: group8ID),
            Player(firstName: "Uma", lastName: "Miller", playerid: "1000029", dob: DateComponents(calendar: .current, year: 1997, month: 11, day: 17).date!, groupID: group8ID),
            Player(firstName: "Victor", lastName: "Miller", playerid: "1000030", dob: DateComponents(calendar: .current, year: 1999, month: 12, day: 6).date!, groupID: group8ID),

            // Group 9 (3 players)
            Player(firstName: "Wendy", lastName: "Smith", playerid: "1000031", dob: DateComponents(calendar: .current, year: 1987, month: 5, day: 9).date!, groupID: group9ID),
            Player(firstName: "Xander", lastName: "Smith", playerid: "1000032", dob: DateComponents(calendar: .current, year: 1990, month: 1, day: 21).date!, groupID: group9ID),
            Player(firstName: "Yara", lastName: "Smith", playerid: "1000033", dob: DateComponents(calendar: .current, year: 1992, month: 6, day: 19).date!, groupID: group9ID),

            // Ungrouped (7 players)
            Player(firstName: "Zane", lastName: "Ungrouped", playerid: "1000034", dob: DateComponents(calendar: .current, year: 1988, month: 4, day: 3).date!, groupID: ungroupedUUID),
            Player(firstName: "Abby", lastName: "Ungrouped", playerid: "1000035", dob: DateComponents(calendar: .current, year: 1990, month: 2, day: 13).date!, groupID: ungroupedUUID),
            Player(firstName: "Beatrice", lastName: "Ungrouped", playerid: "1000036", dob: DateComponents(calendar: .current, year: 1989, month: 11, day: 17).date!, groupID: ungroupedUUID),
            Player(firstName: "Caleb", lastName: "Ungrouped", playerid: "1000037", dob: DateComponents(calendar: .current, year: 1992, month: 2, day: 25).date!, groupID: ungroupedUUID),
            Player(firstName: "Daisy", lastName: "Ungrouped", playerid: "1000038", dob: DateComponents(calendar: .current, year: 1994, month: 3, day: 14).date!, groupID: ungroupedUUID),
            Player(firstName: "Edward", lastName: "Ungrouped", playerid: "1000039", dob: DateComponents(calendar: .current, year: 1996, month: 7, day: 28).date!, groupID: ungroupedUUID),
            Player(firstName: "Fiona", lastName: "Ungrouped", playerid: "1000040", dob: DateComponents(calendar: .current, year: 1998, month: 9, day: 12).date!, groupID: ungroupedUUID)
        ]


        
        playerList.saveToUserDefaults()
        print("All UserDefaults have been reset and player list reset to default.")
    }
    
//    private func cleanRows(file:String) -> String {
//        var cleanFile = file
//        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
//        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
//        return cleanFile
//
//    }
//
//    private func readCSV(filename: NSString) -> [Player] {
//        var csvToPlayerList = [Player]()
//        
//        let pathExtention = filename.pathExtension
//        let pathPrefix = filename.deletingPathExtension
//        
//        guard let filePath = Bundle.main.path(forResource: pathPrefix, ofType: pathExtention) else {
//            print("Erorr: file not found")
//            return []
//        }
//        
//        var data = ""
//        do {
//            data = try String(contentsOfFile: filePath)
//        } catch {
//            print(error)
//            return []
//        }
//        
//        data = cleanRows(file: data)
//        
//        var rows = data.components(separatedBy: "\n")
//        rows.removeFirst()
//
//        // Create Date Formatter
//        let dateFormatter = DateFormatter()
//        for row in rows {
//            let csvColumns = row.components(separatedBy: ",")
//            if csvColumns.count == rows.first?.components(separatedBy: ",").count {
//                let lineStruct = Player(firstName: csvColumns[0], lastName: csvColumns[1], playerid: csvColumns[2], dob: dateFormatter.date(from: csvColumns[3]), email: csvColumns[4], phoneNumber: csvColumns[5], discord: csvColumns[6])
//                csvToPlayerList.append(lineStruct)
//            }
//        }
//        
//        
//        return csvToPlayerList
//    }

}

#Preview {
    ContentView()
        .environmentObject(PlayerListModel())
}
