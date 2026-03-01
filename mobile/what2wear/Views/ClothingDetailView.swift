import SwiftUI

/// Detail card for editing a clothing item's category, color, material, and tags.
struct ClothingDetailView: View {

    @ObservedObject var viewModel: ClosetViewModel
    let item: ClothingItem
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategory: ClothingCategory
    @State private var selectedColor: ClothingColor
    @State private var material: String
    @State private var tags: [String]
    @State private var tagInput: String = ""
    @State private var itemImage: UIImage?

    init(viewModel: ClosetViewModel, item: ClothingItem) {
        self.viewModel = viewModel
        self.item = item
        _selectedCategory = State(initialValue: item.category)
        _selectedColor = State(initialValue:
            ClothingColor.palette.first { $0.name == item.colorName } ?? ClothingColor.palette[0]
        )
        _material = State(initialValue: item.material)
        _tags = State(initialValue: item.tags)
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Photo
                    if let image = itemImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxHeight: 320)
                            .clipped()
                            .cornerRadius(20)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemBackground))
                            .frame(height: 320)
                            .overlay(ProgressView())
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                    }

                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(ClothingCategory.allCases) { cat in
                                    Button {
                                        selectedCategory = cat
                                    } label: {
                                        Text(cat.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(selectedCategory == cat ? .semibold : .regular)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(selectedCategory == cat ? Color.black : Color(.secondarySystemBackground))
                                            .foregroundColor(selectedCategory == cat ? .white : .primary)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }

                    // Color
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(ClothingColor.palette) { color in
                                    Button {
                                        selectedColor = color
                                    } label: {
                                        VStack(spacing: 4) {
                                            Circle()
                                                .fill(color.color)
                                                .frame(width: 32, height: 32)
                                                .overlay(
                                                    Circle()
                                                        .stroke(selectedColor.name == color.name ? Color.black : Color.clear, lineWidth: 2)
                                                )
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color(.separator), lineWidth: 0.5)
                                                )
                                            Text(color.name)
                                                .font(.system(size: 9))
                                                .foregroundColor(selectedColor.name == color.name ? .primary : .secondary)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }

                    // Material
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Material")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        TextField("e.g. Cotton, Denim, Silk", text: $material)
                            .textFieldStyle(.roundedBorder)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 24)

                    // Tags
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        if !tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(tags, id: \.self) { tag in
                                        HStack(spacing: 4) {
                                            Text(tag)
                                                .font(.caption)
                                            Button {
                                                tags.removeAll { $0 == tag }
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 8, weight: .bold))
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color(.secondarySystemBackground))
                                        .foregroundColor(.primary)
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                        }

                        HStack(spacing: 8) {
                            TextField("Add tag", text: $tagInput)
                                .textFieldStyle(.roundedBorder)
                                .font(.subheadline)
                                .onSubmit { addTag() }
                            Button("Add") { addTag() }
                                .font(.subheadline.weight(.medium))
                                .disabled(tagInput.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Save button
                    Button {
                        var updated = item
                        updated.category = selectedCategory
                        updated.colorName = selectedColor.name
                        updated.colorHex = selectedColor.hex
                        updated.material = material
                        updated.tags = tags
                        Task {
                            await viewModel.updateItem(updated)
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark")
                            Text("Save Changes")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)

                    // Delete button
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteItem(id: item.id)
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "trash")
                            Text("Delete Item")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(.red)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle(item.category.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                itemImage = await viewModel.loadImage(for: item)
            }
        }
    }

    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        tags.append(trimmed)
        tagInput = ""
    }
}
