import Foundation

/// Matches the `wardrobe_items` table in Supabase.
struct SupabaseWardrobeItem: Codable, Identifiable {
    let id: UUID
    let user_id: UUID
    let category: String
    let formality: Int?
    let season: [String]?
    let style_tags: [String]?
    let image_url: String?
    let created_at: Date?
    let updated_at: Date?
    
    // Custom mapping if you want to use it
    init(from clothingItem: ClothingItem, userId: UUID, imageUrl: String?) {
        self.id = clothingItem.id
        self.user_id = userId
        self.category = clothingItem.category.rawValue
        self.formality = 1 // Default
        self.season = []
        self.style_tags = []
        self.image_url = imageUrl
        self.created_at = Date()
        self.updated_at = Date()
    }
}
