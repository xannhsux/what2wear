import Foundation
import UIKit

@MainActor
final class AvatarViewModel: ObservableObject {

    @Published var generatedAvatarImage: UIImage?   // White-bg version for display & VTON
    @Published var transparentAvatarImage: UIImage?  // Transparent-bg version for preview
    @Published var selfieImage: UIImage?
    @Published var isGenerating = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var showPreview = false                // Navigate to AvatarPreviewView

    private let waveSpeedService = WaveSpeedService()
    private let backgroundRemoval = BackgroundRemovalService()
    private let firebase = FirebaseService.shared

    init() {
        Task { await loadFromFirebase() }
    }

    // MARK: - Load from Firebase

    private func loadFromFirebase() async {
        do {
            try await firebase.ensureAuthenticated()
            guard let avatar = try await firebase.loadAvatar() else { return }

            // Load transparent image for display
            if !avatar.whiteUrl.isEmpty {
                generatedAvatarImage = await firebase.loadImage(from: avatar.whiteUrl)
            }
        } catch {
            print("[AvatarVM] Load failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Generate

    func generateAvatar() async {
        guard let selfie = selfieImage else { return }
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            // 1. Generate full-body avatar via WaveSpeed
            let whiteImage = try await waveSpeedService.generateAvatar(selfieImage: selfie)

            // 2. Create transparent version
            let transparent = await backgroundRemoval.makeTransparent(image: whiteImage)

            // 3. Store both for preview
            generatedAvatarImage = whiteImage
            transparentAvatarImage = transparent
            showPreview = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Save to Firebase

    func saveToFirebase() async {
        guard let transparent = transparentAvatarImage,
              let white = generatedAvatarImage else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            try await firebase.ensureAuthenticated()

            // Upload both versions
            let transparentUrl = try await firebase.uploadAvatarImage(transparent, name: "transparent.png")

            let whiteForUpload = backgroundRemoval.addWhiteBackground(image: transparent) ?? white
            let whiteUrl = try await firebase.uploadAvatarImage(whiteForUpload, name: "white.png")

            // Save metadata to Firestore
            let avatar = Avatar(transparentUrl: transparentUrl, whiteUrl: whiteUrl)
            try await firebase.saveAvatar(avatar)

            generatedAvatarImage = whiteForUpload
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Regenerate

    func regenerate() async {
        showPreview = false
        transparentAvatarImage = nil
        await generateAvatar()
    }

    func clearError()  { errorMessage = nil }
    func clearSelfie() { selfieImage = nil; errorMessage = nil }
}
