import Foundation

enum ClothingCategory: String, Codable, CaseIterable, Identifiable {
    case top       = "Top"
    case bottom    = "Bottom"
    case shoes     = "Shoes"
    case dress     = "Dress"
    case outerwear = "Outerwear"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .top:       return "tshirt.fill"
        case .bottom:    return "figure.walk"
        case .shoes:     return "shoe.fill"
        case .dress:     return "figure.dress.line.vertical.figure"
        case .outerwear: return "cloud.snow.fill"
        }
    }

    /// Categories that form a complete outfit on their own.
    static var fullBody: [ClothingCategory] { [.dress] }
}
