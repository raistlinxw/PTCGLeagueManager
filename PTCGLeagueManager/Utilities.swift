//
//  Utilities.swift
//  PTCGLeagueManager
//
//  Created by Michael Parker on 8/5/24.
//

import SwiftUI

let ungroupedUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
let testUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000011")!


struct Player: Identifiable, Codable, Equatable {
    var id = UUID()
    var firstName: String = ""
    var lastName: String = ""
    var playerid: String = ""
    var dob: Date?
    var email: String = ""
    var phoneNumber: String = ""
    var discord: String = ""
    var groupID: UUID = ungroupedUUID
    var isChecked: Bool = false
    var attendance: Int = 0
    var lastDateChecked: Date?

    // Method to return the full name
    func fullName() -> String {
        return "\(firstName) \(lastName)"
    }
}

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .autocorrectionDisabled(true) // Disable autocorrect
    }
}


// Abstracted playerList to simplify runtime
class PlayerListModel: ObservableObject {
    @Published var players: [Player] {
        didSet {
            saveToUserDefaults()
        }
    }

    init(players: [Player] = UserDefaults.standard.loadPlayerList() ?? [
    ]) {
        self.players = players
    }
        
    func saveToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(players) {
            UserDefaults.standard.set(encoded, forKey: "playerList")
        }
    }
}

// Saves playerlist data for each user
extension UserDefaults {
    private enum Keys {
        static let playerList = "playerList"
        static let formsData = "formsData"
    }

    var playerList: [Player]? {
        get {
            guard let data = data(forKey: Keys.playerList) else { return nil }
            return try? JSONDecoder().decode([Player].self, from: data)
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            set(data, forKey: Keys.playerList)
        }
    }
    
    func loadPlayerList() -> [Player]? {
            if let data = self.data(forKey: "playerList"),
               let decoded = try? JSONDecoder().decode([Player].self, from: data) {
                return decoded
            }
            return nil
        }
    
    func resetDefaults() {
        guard let appDomain = Bundle.main.bundleIdentifier else { return }
        self.removePersistentDomain(forName: appDomain)
    }
    
    // Method to load form data from UserDefaults
    func loadFormData() -> [FormData]? {
        if let data = self.data(forKey: Keys.formsData),
           let decoded = try? JSONDecoder().decode([FormData].self, from: data) {
            return decoded
        }
        return nil
    }

    // Method to reset form data (optional)
    func resetFormDefaults() {
        removeObject(forKey: Keys.formsData)
    }
}

// Date Formatter for Detail View
extension DateFormatter {
    static let monthDayYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
    
    static let underscores: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M_d_yyyy"
        return formatter
    }()
    
    static let year: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    static let monthyear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM_yyyy"
        return formatter
    }()
    
    static let slashes: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        return formatter
    }()

}

// Tool to simplify what sheet is active
enum ActiveSheet: Identifiable {
    case addPlayerForm
    case attendanceForm
    case playerDetail(Player)
    case fileImport
    case editPlayer(Player)
    
    var id: Int {
        switch self {
        case .addPlayerForm:
            return 0
        case .attendanceForm:
            return 1
        case .fileImport:
            return 2
        case .playerDetail(let player):
            return player.id.hashValue
        case .editPlayer(let player):
            return player.id.hashValue
        }
    }
}
    
    
    // Global class to handle generating forms on ContentView and the AttendanceFormView
    class FormDataManager: ObservableObject {
        @Published var forms: [FormData] {
            didSet {
                saveToUserDefaults()
            }
        }
        
        init(forms: [FormData] = UserDefaults.standard.loadFormData() ?? []) {
            self.forms = forms
        }
        
        // Method to generate and save a form
        func generateForm(from playerList: [Player], filename: String) {
            var formText = ""
            
            let dateFormatter = DateFormatter.year
            
            for player in playerList where player.attendance > 0 && player.playerid != "" && player.dob != nil {
                formText.append("\(player.playerid) \(player.fullName()) \(dateFormatter.string(from: player.dob ?? Date())) \n")
            }
            
            let date = Date()
            if let fileURL = saveToTextFile(content: formText, fileName: filename) {
                let newForm = FormData(date: date, fileURL: fileURL)
                forms.append(newForm)
            }
        }
        
        // Method to save forms to UserDefaults
        private func saveToUserDefaults() {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(forms) {
                UserDefaults.standard.set(encoded, forKey: "formsData")
            }
        }
        
        // Method to save content to a text file and return the file URL
        private func saveToTextFile(content: String, fileName: String) -> URL? {
            let fileManager = FileManager.default
            do {
                let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURL = documentsURL.appendingPathComponent(fileName)
                try content.write(to: fileURL, atomically: true, encoding: .utf8)
                return fileURL
            } catch {
                print("Error saving file: \(error)")
                return nil
            }
        }
    }

