import Foundation
import UIKit

@MainActor
final class ClosetViewModel: ObservableObject {

    // MARK: - Published state

    @Published var items: [ClothingItem] = []
    @Published var selectedFilter: FilterOption = .all

    // Add-item flow
    @Published var capturedImage: UIImage?
    @Published var isClassifying = false
    @Published var detectedCategory: ClothingCategory = .other
    @Published var detectedColor: ClothingColor = ClothingColor.palette[0]
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let storage    = ClosetStorageService.shared
    private let classifier = ClothingClassifierService()

    // MARK: - Filter

    enum FilterOption: String, CaseIterable {
        case all      = "All"
        case tops     = "Tops"
        case bottoms  = "Bottoms"
        case fullBody = "Full Body"
    }

    var filteredItems: [ClothingItem] {
        switch selectedFilter {
        case .all:      return items
        case .tops:     return items.filter { ClothingCategory.tops.contains($0.category) }
        case .bottoms:  return items.filter { ClothingCategory.bottoms.contains($0.category) }
        case .fullBody: return items.filter { ClothingCategory.fullBody.contains($0.category) }
        }
    }

    // MARK: - Init

    init() {
        items = storage.loadItems()
    }

    // MARK: - Classification

    func classifyImage(_ image: UIImage) async {
        capturedImage = image
        isClassifying = true
        errorMessage = nil
        defer { isClassifying = false }

        async let categoryResult = classifier.classifyType(image: image)
        let colorResult = classifier.extractDominantColor(image: image)

        detectedCategory = await categoryResult
        detectedColor = colorResult
    }

    // MARK: - Save

    func saveItem(category: ClothingCategory, color: ClothingColor, notes: String?) async {
        guard let image = capturedImage else { return }

        let id = UUID()
        guard let path = storage.saveImage(image, id: id) else {
            errorMessage = "Failed to save image."
            return
        }

        let item = ClothingItem(
            category: category,
            colorName: color.name,
            colorHex: color.hex,
            imagePath: path,
            notes: notes?.isEmpty == true ? nil : notes
        )
        
        // 1. Save locally
        storage.addItem(item)
        items.insert(item, at: 0)
        
        // 2. Sync with Supabase (Background / Non-blocking)
        let userId = UUID() // Replace with real auth user id
        do {
            try await SupabaseService.shared.uploadWardrobeItem(item, image: image, userId: userId)
            print("[ClosetViewModel] Successfully synced with Supabase.")
        } catch {
            print("[ClosetViewModel] Supabase sync failed: \(error.localizedDescription)")
            // Optionally, show a toast or alert if needed
        }
        
        resetAddFlow()
    }

    // MARK: - Delete

    func deleteItem(id: UUID) {
        storage.removeItem(id: id)
        items.removeAll { $0.id == id }
    }

    // MARK: - Helpers

    func resetAddFlow() {
        capturedImage = nil
        detectedCategory = .other
        detectedColor = ClothingColor.palette[0]
        errorMessage = nil
    }

    func loadImage(for item: ClothingItem) -> UIImage? {
        storage.loadImage(relativePath: item.imagePath)
    }
}
