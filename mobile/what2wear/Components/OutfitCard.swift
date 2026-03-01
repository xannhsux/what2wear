import SwiftUI

/// Card displaying an outfit — full-bleed VTON image or item thumbnails fallback.
struct OutfitCard: View {
    let outfit: Outfit
    let outfitImage: UIImage?
    let isGenerating: Bool
    let allItems: [ClothingItem]

    var body: some View {
        VStack(spacing: 0) {
            if isGenerating {
                // Shimmer loading state
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemGray5))
                    .overlay(
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(.gray)
                            Text("Generating...")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    )
            } else if let image = outfitImage {
                // Full VTON image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            } else {
                // Fallback: item thumbnails
                VStack(spacing: 16) {
                    Spacer()

                    let resolvedItems = outfit.itemIds.compactMap { id in allItems.first { $0.id == id } }
                    HStack(spacing: 12) {
                        ForEach(resolvedItems) { item in
                            thumbnailView(item)
                        }
                    }

                    // Description
                    Text(outfit.description(items: allItems))
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 460)
        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.02), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func thumbnailView(_ item: ClothingItem) -> some View {
        VStack(spacing: 6) {
            if !item.imageUrl.isEmpty, let url = URL(string: item.imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 100)
                            .clipped()
                            .cornerRadius(12)
                    default:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                            .frame(width: 80, height: 100)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 100)
            }
            Text(item.category.rawValue)
                .font(.system(size: 11))
                .foregroundColor(.textSecondary)
        }
    }
}
