import UIKit

/// Persists the generated avatar image to the Documents directory.
/// The file path is stored in UserDefaults under `Constants.Storage.avatarURL`
/// so it survives app restarts.
final class StorageService {

    static let shared = StorageService()
    private init() {}

    private let filename = "what2wear_avatar.jpg"

    // MARK: - File URL

    private var fileURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(filename)
    }

    // MARK: - Save

    /// Downloads the image from `remoteURL`, saves it locally, and persists the path.
    @discardableResult
    func downloadAndSave(remoteURL: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: remoteURL)
            guard let image = UIImage(data: data) else { return nil }
            save(image)
            // Also store the remote URL string for reference
            UserDefaults.standard.set(remoteURL.absoluteString, forKey: Constants.Storage.avatarURL)
            return image
        } catch {
            print("[StorageService] Download failed: \(error)")
            return nil
        }
    }

    func save(_ image: UIImage) {
        guard
            let url  = fileURL,
            let data = image.jpegData(compressionQuality: 0.9)
        else { return }

        do {
            try data.write(to: url, options: .atomicWrite)
        } catch {
            print("[StorageService] Write failed: \(error)")
        }
    }

    // MARK: - Load

    /// Loads the locally cached avatar. Returns nil if none has been saved yet.
    func loadAvatar() -> UIImage? {
        guard
            let url  = fileURL,
            let data = try? Data(contentsOf: url)
        else { return nil }
        return UIImage(data: data)
    }

    // MARK: - Delete

    func deleteAvatar() {
        if let url = fileURL {
            try? FileManager.default.removeItem(at: url)
        }
        UserDefaults.standard.removeObject(forKey: Constants.Storage.avatarURL)
    }
}
