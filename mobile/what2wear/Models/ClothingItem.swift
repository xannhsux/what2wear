import Foundation

struct ClothingItem: Codable, Identifiable {
    let id: UUID
    let category: ClothingCategory
    let colorName: String
    let colorHex: String
    let imagePath: String   // relative path within Documents/closet/
    let dateAdded: Date
    var notes: String?

    init(
        category: ClothingCategory,
        colorName: String,
        colorHex: String,
        imagePath: String,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.category = category
        self.colorName = colorName
        self.colorHex = colorHex
        self.imagePath = imagePath
        self.dateAdded = Date()
        self.notes = notes
    }
}
