import Foundation

enum Constants {

    // MARK: - WaveSpeed AI API
    // Get your key at: https://wavespeed.ai/accesskey
    // WARNING: Don't commit Secrets.swift with a real key — it's gitignored
    static let waveSpeedAPIKey  = Secrets.waveSpeedAPIKey
    static let waveSpeedBaseURL = "https://api.wavespeed.ai/api/v3"

    // MARK: - Persistence keys
    enum Storage {
        static let avatarURL = "userAvatarURL"
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
}
