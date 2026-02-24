import Foundation
import UIKit

@MainActor
final class AvatarViewModel: ObservableObject {

    @Published var generatedAvatarImage: UIImage?
    @Published var selfieImage: UIImage?
    @Published var isGenerating = false
    @Published var errorMessage: String?

    private let replicateService = ReplicateService()
    private let storageService   = StorageService.shared

    init() {
        generatedAvatarImage = storageService.loadAvatar()
    }

    func generateAvatar() async {
        guard let selfie = selfieImage else { return }
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            let image = try await replicateService.generateAvatar(selfieImage: selfie)
            storageService.save(image)
            generatedAvatarImage = image
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError()  { errorMessage = nil }
    func clearSelfie() { selfieImage = nil; errorMessage = nil }
}
