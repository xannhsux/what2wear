import Foundation

enum Constants {

    // MARK: - Replicate API
    // Get your token at: https://replicate.com/account/api-tokens
    // WARNING: Don't commit this file with a real key — move to Keychain or build config for production
    static let replicateAPIKey  = "YOUR_REPLICATE_API_KEY_HERE"
    static let replicateBaseURL = "https://api.replicate.com/v1"

    // MARK: - PhotoMaker model
    // Model page: https://replicate.com/tencentarc/photomaker
    // This version is the standard PhotoMaker (face-preserving image generation)
    static let photoMakerVersion = "ddfc2b08d209f9fa8c1eca692712918bd449f695dabb4a958da31802a9570fe4"

    /// Prompt that describes the desired avatar output.
    /// Keep consistent with the style of avatar.png (neutral pose, white bg, same outfit).
    static let avatarPrompt = "a person img in neutral pose, full body, plain white background, wearing white tank top and beige shorts, studio lighting, photorealistic, clean background"

    static let avatarNegativePrompt = "distorted, blurry, low quality, bad anatomy, extra limbs, watermark, text"

    // MARK: - Persistence keys
    enum Storage {
        /// Key used to save the generated avatar's local file URL.
        static let avatarURL = "userAvatarURL"
    }

    // MARK: - Image settings
    enum Image {
        static let maxUploadDimension: CGFloat = 1024
        /// Match the user's spec: 0.7 quality for a good size/quality tradeoff
        static let compressionQuality: CGFloat = 0.7
    }

    // MARK: - Polling
    enum Polling {
        static let intervalNanoseconds: UInt64 = 1_000_000_000   // 1 second
        static let maxAttempts: Int            = 90               // 90 seconds max
    }
}
