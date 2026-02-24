import Foundation

enum Constants {

    // MARK: - Replicate API
    // Get your token at: https://replicate.com/account/api-tokens
    // WARNING: Don't commit this file with a real key — move to Keychain or build config for production
    static let replicateAPIKey  = Secrets.replicateAPIKey
    static let replicateBaseURL = "https://api.replicate.com/v1"

    // Face swap — blends user's face onto avatar.png using AI
    // Model page: https://replicate.com/yan-ops/face_swap
    static let faceSwapVersion = "d5900f9ebed33e7ae08a07f17e0d98b4ebc68ab9528a70462afc3899cfe23bab"

    // MARK: - Persistence keys
    enum Storage {
        static let avatarURL             = "userAvatarURL"
        static let avatarReplicateURL    = "avatarReplicateFileURL"    // cached Replicate upload URL
        static let avatarReplicateExpiry = "avatarReplicateFileExpiry" // expiry timestamp (files live 24 h)
    }

    // MARK: - Image settings
    enum Image {
        static let maxUploadDimension: CGFloat = 1024
        /// Match the user's spec: 0.7 quality for a good size/quality tradeoff
        static let compressionQuality: CGFloat = 0.7
    }

    // MARK: - Polling
    enum Polling {
        static let intervalNanoseconds: UInt64 = 3_000_000_000  // 3 s
        static let maxAttempts = 100                             // 5 min max
    }
}
