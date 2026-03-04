import Foundation

enum SupabaseConstants {
    // Note: In a real app, these should be from a configuration or .env file
    static let url = URL(string: "https://nimthuaksipcvvohbfgk.supabase.co")!
    static let anonKey = "sb_publishable_EouKenD9tGAvv_DWz6ss-g_VdK2us7T"
    
    enum Buckets {
        static let wardrobe = "wardrobe"
    }
    
    enum Tables {
        static let wardrobeItems = "wardrobe_items"
        static let outfits = "outfits"
        static let dailyRecommendations = "daily_recommendations"
    }
}
