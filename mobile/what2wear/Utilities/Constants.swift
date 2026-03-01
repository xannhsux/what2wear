import Foundation

enum Constants {

    // MARK: - WaveSpeed AI API
    static let waveSpeedAPIKey  = Secrets.waveSpeedAPIKey
    static let waveSpeedBaseURL = "https://api.wavespeed.ai/api/v3"

    // MARK: - Firebase paths
    enum Firebase {
        static let usersCollection = "users"
        static let closetSubcollection = "closet"
        static let outfitsSubcollection = "outfits"
        static let avatarField = "avatar"
    }

    // MARK: - Image settings
    enum Image {
        static let maxUploadDimension: CGFloat = 1024
        static let compressionQuality: CGFloat = 0.8
    }

    // MARK: - Polling
    enum Polling {
        static let intervalNanoseconds: UInt64 = 3_000_000_000  // 3 s
        static let maxAttempts = 120                             // ~6 min max
    }

    // MARK: - Outfit recommendation
    enum Recommendation {
        static let maxOutfits = 5
        static let minClosetItems = 6
        static let maxNonNeutralColors = 3
    }
}
