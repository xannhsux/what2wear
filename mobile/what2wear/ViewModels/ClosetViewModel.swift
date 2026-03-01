import Foundation
import UIKit
import FirebaseFirestore

@MainActor
final class ClosetViewModel: ObservableObject {

    // MARK: - Published state

    @Published var items: [ClothingItem] = []
    @Published var selectedFilter: FilterOption = .all

    // Add-item flow
    @Published var capturedImage: UIImage?
    @Published var isClassifying = false
    @Published var isSaving = false
    @Published var detectedCategory: ClothingCategory = .top
    @Published var detectedColor: ClothingColor = ClothingColor.palette[0]
    @Published var detectedMaterial: String = ""
    @Published var detectedTags: [String] = []
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let firebase   = FirebaseService.shared
    private let classifier = ClothingClassifierService()
    private var listener: ListenerRegistration?

    // MARK: - Filter

    enum FilterOption: String, CaseIterable {
        case all       = "All"
        case top       = "Top"
        case bottom    = "Bottom"
        case shoes     = "Shoes"
        case dress     = "Dress"
        case outerwear = "Outerwear"

        var category: ClothingCategory? {
            switch self {
            case .all:       return nil
            case .top:       return .top
            case .bottom:    return .bottom
            case .shoes:     return .shoes
            case .dress:     return .dress
            case .outerwear: return .outerwear
            }
        }
    }

    var filteredItems: [ClothingItem] {
        guard let cat = selectedFilter.category else { return items }
        return items.filter { $0.category == cat }
    }

    // MARK: - Init

    init() {
        Task { await startListening() }
    }

    deinit {
        listener?.remove()
    }

    private func startListening() async {
        do {
            try await firebase.ensureAuthenticated()
            listener = firebase.listenToCloset { [weak self] items in
                Task { @MainActor in
                    self?.items = items
                }
            }
        } catch {
            // Fallback: fetch once
            items = (try? await firebase.fetchClosetItems()) ?? []
        }
    }

    // MARK: - Classification

    func classifyImage(_ image: UIImage) async {
        isClassifying = true
        errorMessage = nil
        defer { isClassifying = false }

        async let cleanedImage = classifier.removeBackground(image: image)
        async let categoryResult = classifier.classifyType(image: image)
        async let colorResult = classifier.extractClothingRegionColor(image: image)
        async let tagsResult = classifier.generateTags(image: image)
        async let materialResult = classifier.detectMaterial(image: image)

        capturedImage = await cleanedImage
        detectedCategory = await categoryResult
        detectedColor = await colorResult
        detectedTags = await tagsResult
        detectedMaterial = await materialResult
    }

    // MARK: - Save

    func saveItem(category: ClothingCategory, color: ClothingColor, material: String, tags: [String]) async {
        guard let image = capturedImage else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            try await firebase.ensureAuthenticated()

            let itemId = UUID().uuidString

            // Upload image to Firebase Storage
            let imageUrl = try await firebase.uploadClothingImage(image, itemId: itemId)

            let item = ClothingItem(
                id: itemId,
                category: category,
                colorName: color.name,
                colorHex: color.hex,
                imageUrl: imageUrl,
                material: material,
                tags: tags
            )

            try await firebase.saveClothingItem(item)
            resetAddFlow()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Update

    func updateItem(_ updated: ClothingItem) async {
        do {
            try await firebase.updateClothingItem(updated)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete

    func deleteItem(id: String) async {
        do {
            try await firebase.deleteClothingItem(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Helpers

    func resetAddFlow() {
        capturedImage = nil
        detectedCategory = .top
        detectedColor = ClothingColor.palette[0]
        detectedMaterial = ""
        detectedTags = []
        errorMessage = nil
    }

    /// Loads an image from Firebase URL with caching.
    func loadImage(for item: ClothingItem) async -> UIImage? {
        guard !item.imageUrl.isEmpty else { return nil }
        return await firebase.loadImage(from: item.imageUrl)
    }
}
