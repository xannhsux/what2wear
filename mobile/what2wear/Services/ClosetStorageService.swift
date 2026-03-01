import UIKit

/// Persists clothing items: images as JPEGs in Documents/closet/,
/// metadata as a single JSON file (closet_items.json).
final class ClosetStorageService {

    static let shared = ClosetStorageService()
    private init() { ensureDirectory() }

    private let folderName = "closet"
    private let metadataFilename = "closet_items.json"

    // MARK: - Directories

    private var closetDirectory: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(folderName)
    }

    private var metadataURL: URL? {
        closetDirectory?.appendingPathComponent(metadataFilename)
    }

    private func ensureDirectory() {
        guard let dir = closetDirectory else { return }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    // MARK: - Image persistence

    /// Saves a clothing image and returns the relative path (e.g. "closet/UUID.jpg").
    func saveImage(_ image: UIImage, id: UUID) -> String? {
        guard let dir = closetDirectory else { return nil }

        let resized = resize(image, maxDimension: Constants.Image.maxUploadDimension)
        guard let data = resized.jpegData(compressionQuality: 0.8) else { return nil }

        let filename = "\(id.uuidString).jpg"
        let fileURL = dir.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL, options: .atomicWrite)
            return "\(folderName)/\(filename)"
        } catch {
            print("[ClosetStorage] Write failed: \(error)")
            return nil
        }
    }

    func loadImage(relativePath: String) -> UIImage? {
        guard let docs = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let url = docs.appendingPathComponent(relativePath)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func deleteImage(relativePath: String) {
        guard let docs = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let url = docs.appendingPathComponent(relativePath)
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Item metadata

    func loadItems() -> [ClothingItem] {
        guard let url = metadataURL,
              let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([ClothingItem].self, from: data)) ?? []
    }

    func saveItems(_ items: [ClothingItem]) {
        guard let url = metadataURL else { return }
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: url, options: .atomicWrite)
        } catch {
            print("[ClosetStorage] Save items failed: \(error)")
        }
    }

    func addItem(_ item: ClothingItem) {
        var items = loadItems()
        items.insert(item, at: 0)
        saveItems(items)
    }

    func removeItem(id: UUID) {
        var items = loadItems()
        if let index = items.firstIndex(where: { $0.id == id }) {
            let item = items[index]
            deleteImage(relativePath: item.imagePath)
            items.remove(at: index)
            saveItems(items)
        }
    }

    // MARK: - Helpers

    private func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        if ratio >= 1 { return image }
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
    }
}
