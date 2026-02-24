import Foundation
import UIKit

/// Central state owner for all avatar-related screens.
/// Marked @MainActor so every @Published mutation is automatically on the main thread,
/// which is required for SwiftUI view updates.
@MainActor
final class AvatarViewModel: ObservableObject {

    // MARK: - State

    /// The final generated avatar shown in MyAvatarView.
    @Published var generatedAvatarImage: UIImage?

    /// The selfie the user selected — previewed in EditAvatarView before generation.
    @Published var selfieImage: UIImage?

    /// True while the Replicate API call + polling is running.
    @Published var isGenerating = false

    /// Non-nil when an error should be shown to the user.
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let replicateService = ReplicateService()
    private let storageService   = StorageService.shared

    // MARK: - Init

    init() {
        generatedAvatarImage = storageService.loadAvatar()
    }

    // MARK: - Actions

    /// Calls the PhotoMaker API with the current selfie and updates the avatar on success.
    func generateAvatar() async {
        guard let selfie = selfieImage else { return }

        isGenerating = true
        errorMessage = nil

        defer { isGenerating = false }

        do {
            // 1. Call Replicate — returns the remote image URL when generation succeeds
            let remoteURL = try await replicateService.generateAvatar(selfieImage: selfie)

            // 2. Download the image and persist it locally
            guard let downloaded = await storageService.downloadAndSave(remoteURL: remoteURL) else {
                throw APIError.invalidResponse("Generated image could not be downloaded.")
            }

            // 3. Surface to the UI
            generatedAvatarImage = downloaded

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Utility

    func clearError()  { errorMessage = nil }
    func clearSelfie() { selfieImage = nil; errorMessage = nil }
}
