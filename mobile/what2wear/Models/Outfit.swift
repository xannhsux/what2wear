import Foundation

/// A recommended outfit combining closet items.
struct Outfit: Identifiable, Codable {
    let id: String
    var itemIds: [String]              // IDs of ClothingItems in this outfit
    var generatedImageUrl: String?     // Firebase Storage URL for VTON result
    var liked: Bool
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        itemIds: [String],
        generatedImageUrl: String? = nil,
        liked: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.itemIds = itemIds
        self.generatedImageUrl = generatedImageUrl
        self.liked = liked
        self.createdAt = createdAt
    }

    /// Human-readable outfit description built from resolved items.
    func description(items: [ClothingItem]) -> String {
        let resolved = itemIds.compactMap { itemId in items.first { $0.id == itemId } }
        return resolved.map { "\($0.colorName) \($0.category.rawValue)" }.joined(separator: " + ")
    }

    /// Prompt fragment for VTON generation from resolved items.
    func tryOnPrompt(items: [ClothingItem]) -> String {
        let resolved = itemIds.compactMap { itemId in items.first { $0.id == itemId } }
        return resolved.map { "\($0.colorName.lowercased()) \($0.category.rawValue.lowercased())" }.joined(separator: ", ")
    }
}
