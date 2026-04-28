import UIKit

extension Notification.Name {
    static let designSaveFailed = Notification.Name("com.bratify.designSaveFailed")
}

class DesignManager {
    
    static let shared = DesignManager()
    
    private let designsFileName = "designs.json"
    private var designs: [Design] = []
    
    init() {
        self.designs = loadDesigns()
    }
    
    func addDesign(_ design: Design) {
        // Check if a design with the same ID already exists
        if let index = designs.firstIndex(where: { $0.id == design.id }) {
            designs[index] = design
        } else if !design.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            designs.append(design)
        }
        saveDesigns(designs)
    }
    
    func deleteDesign(_ design: Design) {
        if let index = designs.firstIndex(where: { $0.id == design.id }) {
            designs.remove(at: index)
            saveDesigns(designs)
        }
    }
    
    func getAllDesigns() -> [Design] {
        return designs
    }
    
    private func saveDesigns(_ designs: [Design]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(designs)
            let url = getDocumentsDirectory().appendingPathComponent(designsFileName)
            try data.write(to: url)
        } catch {
            print("Failed to save designs: \(error.localizedDescription)")
            NotificationCenter.default.post(name: .designSaveFailed, object: nil)
        }
    }
    
    func loadDesigns() -> [Design] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let url = getDocumentsDirectory().appendingPathComponent(designsFileName)
        do {
            let data = try Data(contentsOf: url)
            let designs = try decoder.decode([Design].self, from: data)
            if designs.isEmpty {
                return generateRandomDesigns(count: .random(in: 4...5))
            }
            return designs
        } catch {
            print("Failed to load designs: \(error.localizedDescription)")
            return generateRandomDesigns(count: .random(in: 4...5))
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func generateRandomDesigns(count: Int) -> [Design] {
        let texts = [
            NSLocalizedString("you", comment: "The first word in the five word phrase \"you can figure it out\""),
            NSLocalizedString("can", comment: "The second word in the five word phrase \"you can figure it out\""),
            NSLocalizedString("do", comment: "the verb \"to do\""),
            NSLocalizedString("it", comment: "The third word in the five word phrase \"you can figure it out\""),
            NSLocalizedString("figure", comment: "The fourth word in the five word phrase \"you can figure it out\""),
            NSLocalizedString("out", comment: "The fifth word in the five word phrase \"you can figure it out\""),
            NSLocalizedString("k", comment: "short for \"okay\"")
        ]
        var designs: [Design] = []
        
        for i in 0..<count {
            let text = texts[i % texts.count]
            let backgroundColor = UIColor(
                red: CGFloat.random(in: 0.7...1.0),
                green: CGFloat.random(in: 0.7...1.0),
                blue: CGFloat.random(in: 0.7...1.0),
                alpha: 1.0
            )
            let fontSize = CGFloat.random(in: 40...180)
            let pixelationScale = CGFloat.random(in: 5...12)
            let creationDate = Date()

            let design = Design(
                text: text,
                backgroundColor: backgroundColor,
                creationDate: creationDate,
                fontName: "Arial",
                fontSize: fontSize,
                pixelationScale: pixelationScale,
                stretch: 0.2,
                blur: .random(in: 0...0.001),
                id: UUID()
            )
            
            designs.append(design)
        }
        
        return designs
    }
}
