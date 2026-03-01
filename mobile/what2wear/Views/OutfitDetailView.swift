import SwiftUI

/// Detail sheet showing the full outfit breakdown and actions.
struct OutfitDetailView: View {

    @ObservedObject var viewModel: DailyViewModel
    let outfit: Outfit
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Generated outfit image
                    if let image = viewModel.outfitImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 400)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                    }

                    // Outfit items breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Items")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)

                        let resolvedItems = outfit.itemIds.compactMap { id in
                            viewModel.closetItems.first { $0.id == id }
                        }
                        ForEach(resolvedItems) { item in
                            itemRow(item)
                        }
                    }

                    // Like button
                    Button {
                        Task { await viewModel.toggleFavorite() }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: outfit.liked ? "heart.fill" : "heart")
                                .foregroundColor(outfit.liked ? .red : .white)
                            Text(outfit.liked ? "Liked" : "Like this Outfit")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)

                    // Regenerate button
                    Button {
                        Task { await viewModel.regenerateImage() }
                        dismiss()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.clockwise")
                            Text("Regenerate Look")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(.textPrimary)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Outfit Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Item row

    private func itemRow(_ item: ClothingItem) -> some View {
        HStack(spacing: 14) {
            if !item.imageUrl.isEmpty, let url = URL(string: item.imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(12)
                    default:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                            .frame(width: 60, height: 60)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: item.colorHex))
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(Color(.separator), lineWidth: 0.5))

                    Text(item.colorName)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
