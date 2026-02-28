import Foundation

/// Represents one generated avatar.
struct Avatar: Codable {
    let id: UUID
    /// The remote Replicate output URL (expires after ~24 h — kept for reference only).
    let remoteURL: String
    /// Absolute path to the JPEG saved in the app's Documents directory.
    let localPath: String
    let createdAt: Date

    init(remoteURL: String, localPath: String) {
        self.id        = UUID()
        self.remoteURL = remoteURL
        self.localPath = localPath
        self.createdAt = Date()
    }

    var localFileURL: URL {
        URL(fileURLWithPath: localPath)
    }
}
