import SwiftUI

/// Grid cell showing a clothing item's image, color dot, and category label.
/// Loads image from Firebase URL using AsyncImage.
struct ClothingItemCard: View {

    let item: ClothingItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Clothing photo from Firebase URL
            if !item.imageUrl.isEmpty, let url = URL(string: item.imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(20)
                    case .failure:
                        placeholder
                    case .empty:
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemBackground))
                            .frame(height: 180)
                            .overlay(ProgressView())
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }

            // Category + color dot
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: item.colorHex))
                    .frame(width: 10, height: 10)

                Text(item.category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
        .background(Color.cardBackground)
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.secondarySystemBackground))
            .frame(height: 180)
            .overlay(
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(.tertiaryLabel))
            )
    }
}
