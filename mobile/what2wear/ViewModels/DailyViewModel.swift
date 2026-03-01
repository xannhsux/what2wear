import Foundation
import UIKit

@MainActor
final class DailyViewModel: ObservableObject {

    // MARK: - Published state

    @Published var outfits: [Outfit] = []
    @Published var currentOutfitIndex: Int = 0
    @Published var outfitImage: UIImage?
    @Published var closetItems: [ClothingItem] = []
    @Published var isLoadingOutfits = false
    @Published var isGeneratingImage = false
    @Published var isAllViewed = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let recommendationService = OutfitRecommendationService()
    private let tryOnService = VirtualTryOnService()
    private let firebase = FirebaseService.shared

    // MARK: - Computed

    var currentOutfit: Outfit? {
        guard outfits.indices.contains(currentOutfitIndex) else { return nil }
        return outfits[currentOutfitIndex]
    }

    var hasEnoughItems: Bool {
        closetItems.count >= Constants.Recommendation.minClosetItems
    }

    var hasAvatar: Bool {
        avatarImage != nil
    }

    private var avatarImage: UIImage?

    // MARK: - Load daily

    func loadDaily() async {
        isLoadingOutfits = true
        isAllViewed = false
        errorMessage = nil

        do {
            try await firebase.ensureAuthenticated()

            // Load avatar
            if let avatar = try await firebase.loadAvatar(), !avatar.whiteUrl.isEmpty {
                avatarImage = await firebase.loadImage(from: avatar.whiteUrl)
            }

            // Load closet items
            closetItems = try await firebase.fetchClosetItems()

            // Generate recommendations
            let recommended = recommendationService.recommend(items: closetItems)
            outfits = recommended
            currentOutfitIndex = 0
            isLoadingOutfits = false

            // Generate VTON for first outfit
            if !outfits.isEmpty {
                await generateImageForCurrentOutfit()
            }
        } catch {
            isLoadingOutfits = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Swipe actions

    func swipeRight(_ outfit: Outfit) async {
        // Like: save to Firestore
        var liked = outfit
        liked.liked = true
        try? await firebase.saveOutfit(liked)

        advanceToNext()
        if !isAllViewed {
            await generateImageForCurrentOutfit()
        }
    }

    func swipeLeft(_ outfit: Outfit) async {
        // Skip: just advance
        advanceToNext()
        if !isAllViewed {
            await generateImageForCurrentOutfit()
        }
    }

    private func advanceToNext() {
        if currentOutfitIndex < outfits.count - 1 {
            currentOutfitIndex += 1
            outfitImage = nil
        } else {
            isAllViewed = true
            outfitImage = nil
        }
    }

    // MARK: - Actions

    func regenerateImage() async {
        outfitImage = nil
        await generateImageForCurrentOutfit()
    }

    func toggleFavorite() async {
        guard outfits.indices.contains(currentOutfitIndex) else { return }
        outfits[currentOutfitIndex].liked.toggle()
        let outfit = outfits[currentOutfitIndex]
        try? await firebase.saveOutfit(outfit)
    }

    // MARK: - VTON generation

    private func generateImageForCurrentOutfit() async {
        guard let outfit = currentOutfit,
              let avatar = avatarImage else { return }

        isGeneratingImage = true
        errorMessage = nil

        do {
            let image = try await tryOnService.generateTryOn(
                avatarImage: avatar,
                outfit: outfit,
                allItems: closetItems
            )
            outfitImage = image
        } catch {
            print("[DailyVM] VTON failed: \(error.localizedDescription)")
            errorMessage = "Couldn't generate outfit preview"
        }

        isGeneratingImage = false
    }
}
