import Foundation

/// The user's generated avatar stored in Firebase.
struct Avatar: Codable {
    var transparentUrl: String     // Firebase Storage URL — PNG with transparent background
    var whiteUrl: String           // Firebase Storage URL — PNG with white background (for VTON)
    let createdAt: Date

    init(transparentUrl: String, whiteUrl: String, createdAt: Date = Date()) {
        self.transparentUrl = transparentUrl
        self.whiteUrl = whiteUrl
        self.createdAt = createdAt
    }
}
