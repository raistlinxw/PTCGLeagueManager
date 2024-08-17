import SwiftUI
import QuickLook

struct FormData: Identifiable, Codable {
    let id: UUID
    let date: Date
    let fileURL: URL
    
    // Custom initializer to handle default values
    init(id: UUID = UUID(), date: Date, fileURL: URL) {
        self.id = id
        self.date = date
        self.fileURL = fileURL
    }
    
    // Coding keys to handle the URL encoding and decoding
    enum CodingKeys: String, CodingKey {
        case id, date, fileURL
    }
    
    // Custom decoding to handle the URL
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        let urlString = try container.decode(String.self, forKey: .fileURL)
        guard let url = URL(string: urlString) else {
            throw DecodingError.dataCorruptedError(forKey: .fileURL,
                                                   in: container,
                                                   debugDescription: "Invalid URL string.")
        }
        fileURL = url
    }
    
    // Custom encoding to handle the URL
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(fileURL.absoluteString, forKey: .fileURL)
    }
}


struct AttendanceReportView: View {
    @EnvironmentObject var playerList: PlayerListModel
    @ObservedObject var formDataManager: FormDataManager
    @State private var showShareSheet = false
    @State private var fileToShare: URL?
    @State private var selectedFileURL: IdentifiableURL?

    var body: some View {
        List(sortedForms) { form in
            HStack {
                Text("\(form.fileURL.lastPathComponent)")
                    .onTapGesture {
                        selectedFileURL = IdentifiableURL(url: form.fileURL)
                    }
                Spacer()
                ShareLink(item: form.fileURL, preview: SharePreview(form.fileURL.lastPathComponent, image: Image(systemName: "doc.text"))) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Generated Reports")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    formDataManager.generateForm(from: playerList.players, filename: "AttendanceReport_\(DateFormatter.underscores.string(from: Date.now)).txt")
                }) {
                    Text("Generate Report")
                }
            }
        }
        .sheet(item: $selectedFileURL) { identifiableURL in
            QuickLookPreview(url: identifiableURL.url)
        }
    }

    // Sorted forms with the most recent at the top
    private var sortedForms: [FormData] {
        formDataManager.forms.sorted(by: { $0.date > $1.date })
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    
    struct IdentifiableURL: Identifiable {
        var id = UUID()
        var url: URL
    }

    struct QuickLookPreview: UIViewControllerRepresentable {
        let url: URL
        @Environment(\.presentationMode) var presentationMode

        func makeUIViewController(context: Context) -> QLPreviewController {
            let controller = QLPreviewController()
            controller.dataSource = context.coordinator

            // Adding a button to the controller's view
            let closeButton = UIButton(type: .system)
            closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            closeButton.tintColor = .white
            closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            closeButton.layer.cornerRadius = 15
            closeButton.addTarget(context.coordinator, action: #selector(Coordinator.dismiss), for: .touchUpInside)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            controller.view.addSubview(closeButton)

            NSLayoutConstraint.activate([
                closeButton.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor, constant: 10),
                closeButton.topAnchor.constraint(equalTo: controller.view.topAnchor, constant: 10),
                closeButton.widthAnchor.constraint(equalToConstant: 30),
                closeButton.heightAnchor.constraint(equalToConstant: 30)
            ])

            return controller
        }

        func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
            // No need to implement for this example
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, QLPreviewControllerDataSource {
            let parent: QuickLookPreview
            
            init(_ parent: QuickLookPreview) {
                self.parent = parent
            }
            
            func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
                return 1
            }
            
            func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
                return parent.url as QLPreviewItem
            }
            
            @objc func dismiss() {
                parent.presentationMode.wrappedValue.dismiss()
            }
            
            func add(to view: UIView, controller: QLPreviewController) {
                controller.willMove(toParent: nil)
                view.addSubview(controller.view)
                controller.view.frame = view.bounds
                controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
        }
    }
}
