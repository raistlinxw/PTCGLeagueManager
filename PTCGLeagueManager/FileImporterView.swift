import SwiftUI
import UniformTypeIdentifiers

struct FileImporterView: View {
    @State private var importing = false
    @EnvironmentObject var playerList: PlayerListModel
    @Environment(\.presentationMode) var presentationMode
    @State private var successAlert = false
    @State private var yesnoAlert = false
    @State private var selectedFileURL: URL?


    var body: some View {
            VStack {
                Text("Please provide a .csv file with your players you would like to import.\n\n")
                Text("The format of this file must be First Name, Last Name, Player ID, Date of Birth, Email, Phone Number, Discord\n")
                Text("Dates must be in the format MM/DD/YYYY\nEX: 06/22/1995\n\n\n")
                Button("Import CSV") {
                    importing = true
                }
                .foregroundColor(.white) // Text color
                        .padding() // Add padding around the text
                        .frame(width: UIScreen.main.bounds.width / 2) // Make the button take up the full width if needed
                        .background(Color.blue) // Background color
                        .cornerRadius(10) // Rounded corners
                .fileImporter(
                    isPresented: $importing,
                    allowedContentTypes: [.commaSeparatedText]
                ) { result in
                    switch result {
                    case .success(let fileURL):
                        selectedFileURL = fileURL // Store the selected file URL
                        yesnoAlert = true // Show the confirmation alert after file is selected
                    case .failure(let error):
                        print("Error importing file: \(error.localizedDescription)")
                    }
                }
                Spacer()
            }
            .alert(isPresented: $successAlert) {
                Alert(
                    title: Text("CSV Successfully Imported"),
                    message: Text("New players were added to your list"),
                    dismissButton: .default(Text("OK")) {
                        print("Alert Shown")
                        successAlert = false
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            .alert(isPresented: $yesnoAlert, content: {
                Alert(
                    title: Text("Confirm Import"),
                    message: Text("Are you sure you want to import this CSV?"),
                    primaryButton: .default(Text("Yes")) {
                        if let fileURL = selectedFileURL {
                            importCSV(from: fileURL)
                        }
                    },
                    secondaryButton: .cancel(Text("No"))
                )
            })
            .navigationTitle("Add Players from CSV")
    }
    
    private func importCSV(from fileURL: URL) {
        do {
            let _ = fileURL.startAccessingSecurityScopedResource()
            defer { fileURL.stopAccessingSecurityScopedResource() }
            
            let csvContent = try String(contentsOf: fileURL)
            playerList.players.append(contentsOf: readCSV(content: csvContent))
            
            print("Players imported successfully, showing success alert.")
            
            DispatchQueue.main.async {
                print("showing alert RN")
                successAlert = true
            }
            
        } catch {
            print("Error reading CSV file: \(error.localizedDescription)")
        }
    }
    
    private func readCSV(content: String) -> [Player] {
        var csvToPlayerList = [Player]()
        
        let cleanedContent = cleanRows(file: content)
        let rows = cleanedContent.components(separatedBy: "\n")
        
        guard rows.count > 1 else {
            print("CSV content is empty or does not have enough rows")
            return []
        }
        
        // Create Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        
        for row in rows.dropFirst() {
            let csvColumns = row.components(separatedBy: ",")
            if csvColumns.count == 7 {
                let player = Player(
                    firstName: csvColumns[0],
                    lastName: csvColumns[1],
                    playerid: csvColumns[2],
                    dob: dateFormatter.date(from: csvColumns[3]),
                    email: csvColumns[4],
                    phoneNumber: csvColumns[5],
                    discord: csvColumns[6]
                )

                csvToPlayerList.append(player)
            }
        }
        
        return csvToPlayerList
    }

    private func cleanRows(file: String) -> String {
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
}
