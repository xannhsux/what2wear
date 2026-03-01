import Foundation

struct ClothingItem: Codable, Identifiable {
    let id: String
    var category: ClothingCategory
    var colorName: String
    var colorHex: String
    var imageUrl: String          // Firebase Storage download URL
    var material: String
    var tags: [String]
    let addedAt: Date

    init(
        id: String = UUID().uuidString,
        category: ClothingCategory,
        colorName: String,
        colorHex: String,
        imageUrl: String = "",
        material: String = "",
        tags: [String] = [],
        addedAt: Date = Date()
    ) {
        self.id = id
        self.category = category
        self.colorName = colorName
        self.colorHex = colorHex
        self.imageUrl = imageUrl
        self.material = material
        self.tags = tags
        self.addedAt = addedAt
    }
}
