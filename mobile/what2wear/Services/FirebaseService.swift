import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

/// Singleton managing Firebase Anonymous Auth, Firestore CRUD, and Storage uploads.
@MainActor
final class FirebaseService: ObservableObject {
    static let shared = FirebaseService()

    @Published private(set) var userId: String?
    @Published private(set) var isAuthenticated = false

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let imageCache = NSCache<NSString, UIImage>()

    private var closetListener: ListenerRegistration?
    private var outfitsListener: ListenerRegistration?

    private init() {
        imageCache.countLimit = 100
    }

    // MARK: - Auth

    /// Signs in anonymously. Firebase persists UID in Keychain, so this is a no-op
    /// if the user is already signed in.
    func ensureAuthenticated() async throws {
        if let user = Auth.auth().currentUser {
            userId = user.uid
            isAuthenticated = true
            return
        }

        let result = try await Auth.auth().signInAnonymously()
        userId = result.user.uid
        isAuthenticated = true
    }

    private func requireUserId() throws -> String {
        guard let uid = userId else { throw APIError.notAuthenticated }
        return uid
    }

    // MARK: - Avatar

    func saveAvatar(_ avatar: Avatar) async throws {
        let uid = try requireUserId()
        try db.collection("users").document(uid).setData(from: ["avatar": avatar], merge: true)
    }

    func loadAvatar() async throws -> Avatar? {
        let uid = try requireUserId()
        let doc = try await db.collection("users").document(uid).getDocument()
        guard let data = doc.data(),
              let avatarData = data["avatar"] as? [String: Any] else { return nil }
        let jsonData = try JSONSerialization.data(withJSONObject: avatarData)
        return try JSONDecoder.firestore.decode(Avatar.self, from: jsonData)
    }

    /// Uploads avatar image to Firebase Storage and returns the download URL.
    func uploadAvatarImage(_ image: UIImage, name: String) async throws -> String {
        let uid = try requireUserId()
        let ref = storage.reference().child("users/\(uid)/avatar/\(name)")

        guard let data = image.pngData() else { throw APIError.imageConversionFailed }

        let metadata = StorageMetadata()
        metadata.contentType = "image/png"

        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    // MARK: - Closet

    private func closetCollection() throws -> CollectionReference {
        let uid = try requireUserId()
        return db.collection("users").document(uid).collection("closet")
    }

    func saveClothingItem(_ item: ClothingItem) async throws {
        let collection = try closetCollection()
        try collection.document(item.id).setData(from: item)
    }

    func updateClothingItem(_ item: ClothingItem) async throws {
        let collection = try closetCollection()
        try collection.document(item.id).setData(from: item, merge: true)
    }

    func deleteClothingItem(id: String) async throws {
        let collection = try closetCollection()
        try await collection.document(id).delete()
        // Delete image from storage
        let uid = try requireUserId()
        let ref = storage.reference().child("users/\(uid)/closet/\(id).jpg")
        try? await ref.delete()
    }

    func fetchClosetItems() async throws -> [ClothingItem] {
        let collection = try closetCollection()
        let snapshot = try await collection.order(by: "addedAt", descending: true).getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: ClothingItem.self)
        }
    }

    /// Starts a real-time listener for closet items. Returns a closure that can be called to stop listening.
    func listenToCloset(onChange: @escaping ([ClothingItem]) -> Void) -> ListenerRegistration? {
        guard let uid = userId else { return nil }
        let collection = db.collection("users").document(uid).collection("closet")
        return collection.order(by: "addedAt", descending: true).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            let items = snapshot.documents.compactMap { doc in
                try? doc.data(as: ClothingItem.self)
            }
            onChange(items)
        }
    }

    /// Uploads a clothing item image to Firebase Storage and returns the download URL.
    func uploadClothingImage(_ image: UIImage, itemId: String) async throws -> String {
        let uid = try requireUserId()
        let ref = storage.reference().child("users/\(uid)/closet/\(itemId).jpg")

        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.imageConversionFailed
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    // MARK: - Outfits

    private func outfitsCollection() throws -> CollectionReference {
        let uid = try requireUserId()
        return db.collection("users").document(uid).collection("outfits")
    }

    func saveOutfit(_ outfit: Outfit) async throws {
        let collection = try outfitsCollection()
        try collection.document(outfit.id).setData(from: outfit)
    }

    func updateOutfit(_ outfit: Outfit) async throws {
        let collection = try outfitsCollection()
        try collection.document(outfit.id).setData(from: outfit, merge: true)
    }

    func fetchOutfits() async throws -> [Outfit] {
        let collection = try outfitsCollection()
        let snapshot = try await collection.order(by: "createdAt", descending: true).getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Outfit.self)
        }
    }

    func fetchLikedOutfits() async throws -> [Outfit] {
        let collection = try outfitsCollection()
        let snapshot = try await collection
            .whereField("liked", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Outfit.self)
        }
    }

    /// Uploads a VTON outfit image to Firebase Storage and returns the download URL.
    func uploadOutfitImage(_ image: UIImage, outfitId: String) async throws -> String {
        let uid = try requireUserId()
        let ref = storage.reference().child("users/\(uid)/outfits/\(outfitId).png")

        guard let data = image.pngData() else { throw APIError.imageConversionFailed }

        let metadata = StorageMetadata()
        metadata.contentType = "image/png"

        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    // MARK: - Image caching

    /// Downloads and caches an image from a URL string.
    func loadImage(from urlString: String) async -> UIImage? {
        let key = urlString as NSString

        // Check cache
        if let cached = imageCache.object(forKey: key) {
            return cached
        }

        // Download
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            imageCache.setObject(image, forKey: key)
            return image
        } catch {
            print("[FirebaseService] Image download failed: \(error.localizedDescription)")
            return nil
        }
    }

    /// Clears the image cache.
    func clearImageCache() {
        imageCache.removeAllObjects()
    }
}

// MARK: - Firestore JSONDecoder

private extension JSONDecoder {
    static let firestore: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
