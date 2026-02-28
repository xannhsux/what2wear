import SwiftUI

/// Grid cell showing a clothing item's image, color dot, and category label.
struct ClothingItemCard: View {

    let image: UIImage?
    let category: ClothingCategory
    let colorHex: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Clothing photo
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()
                    .cornerRadius(20)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "tshirt.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color(.tertiaryLabel))
                    )
            }

            // Category + color dot
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: colorHex))
                    .frame(width: 10, height: 10)

                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
        .background(Color.cardBackground)
    }
}
