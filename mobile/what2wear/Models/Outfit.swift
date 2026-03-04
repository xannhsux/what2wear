import Foundation

struct Outfit: Codable, Identifiable {
    let id: UUID
    let name: String?
    let items: [ClothingItem]
    let dateCreated: Date
    
    init(id: UUID = UUID(), name: String? = nil, items: [ClothingItem]) {
        self.id = id
        self.name = name
        self.items = items
        self.dateCreated = Date()
    }
}
