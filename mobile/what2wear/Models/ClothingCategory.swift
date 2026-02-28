import Foundation

enum ClothingCategory: String, Codable, CaseIterable, Identifiable {
    // Tops
    case tshirt     = "T-Shirt"
    case blouse     = "Blouse"
    case shirt      = "Shirt"
    case sweater    = "Sweater"
    case hoodie     = "Hoodie"
    case jacket     = "Jacket"
    case coat       = "Coat"
    case cardigan   = "Cardigan"
    case tankTop    = "Tank Top"

    // Bottoms
    case jeans      = "Jeans"
    case shorts     = "Shorts"
    case skirt      = "Skirt"
    case sportPants = "Sport Pants"
    case trousers   = "Trousers"

    // Full body
    case dress      = "Dress"
    case jumpsuit   = "Jumpsuit"

    // Other
    case other      = "Other"

    var id: String { rawValue }

    static var tops: [ClothingCategory] {
        [.tshirt, .blouse, .shirt, .sweater, .hoodie, .jacket, .coat, .cardigan, .tankTop]
    }

    static var bottoms: [ClothingCategory] {
        [.jeans, .shorts, .skirt, .sportPants, .trousers]
    }

    static var fullBody: [ClothingCategory] {
        [.dress, .jumpsuit]
    }
}
