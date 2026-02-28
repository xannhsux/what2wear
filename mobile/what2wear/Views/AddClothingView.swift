import SwiftUI

/// Sheet for adding a clothing item: capture photo → auto-classify → confirm/edit → save.
struct AddClothingView: View {

    @ObservedObject var viewModel: ClosetViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showPhotoLibrary = false
    @State private var showCamera       = false

    // Editable classification (initialized from auto-detection)
    @State private var selectedCategory: ClothingCategory = .other
    @State private var selectedColor: ClothingColor = ClothingColor.palette[0]
    @State private var notes: String = ""

    @State private var showCategoryPicker = false
    @State private var showColorPicker    = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {

                        if let image = viewModel.capturedImage {
                            // ── Classification results ───────────────
                            classificationView(image: image)
                        } else {
                            // ── Capture buttons ──────────────────────
                            captureSection
                        }

                        // ── Error banner ─────────────────────────
                        if let error = viewModel.errorMessage {
                            errorBanner(message: error)
                                .padding(.horizontal, 24)
                        }

                        Spacer(minLength: 40)
                    }
                }

                if viewModel.isClassifying {
                    LoadingOverlay()
                }
            }
            .navigationTitle("Add Clothing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.resetAddFlow()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showPhotoLibrary) {
                PhotoPicker(image: Binding(
                    get: { viewModel.capturedImage },
                    set: { img in
                        guard let img = img else { return }
                        Task { await viewModel.classifyImage(img) }
                    }
                ))
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker(image: Binding(
                    get: { viewModel.capturedImage },
                    set: { img in
                        guard let img = img else { return }
                        Task { await viewModel.classifyImage(img) }
                    }
                ))
                .ignoresSafeArea()
            }
            .onChange(of: viewModel.detectedCategory) { newValue in
                selectedCategory = newValue
            }
            .onChange(of: viewModel.detectedColor.name) { _ in
                selectedColor = viewModel.detectedColor
            }
        }
    }

    // MARK: - Capture section

    private var captureSection: some View {
        VStack(spacing: 32) {
            // Placeholder
            VStack(spacing: 12) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(Color(.tertiaryLabel))
                Text("Take a photo of your clothing item")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Use a plain background for best color detection")
                    .font(.caption)
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(.top, 60)

            // Buttons
            VStack(spacing: 12) {
                Button {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        showCamera = true
                    } else {
                        showPhotoLibrary = true
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                        Text("Take a Photo")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }

                Button {
                    showPhotoLibrary = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "photo.fill")
                        Text("Upload a Photo")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(14)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Classification view

    private func classificationView(image: UIImage) -> some View {
        VStack(spacing: 24) {
            // Photo preview
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 280)
                .clipped()
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .overlay(alignment: .topTrailing) {
                    Button {
                        viewModel.resetAddFlow()
                        notes = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color(.systemBackground), Color(.secondaryLabel))
                    }
                    .padding(.top, 22)
                    .padding(.trailing, 30)
                }

            // Category picker
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

            // Color picker
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

            // Notes
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes (optional)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                TextField("e.g. Summer favorite, work outfit", text: $notes)
                    .textFieldStyle(.roundedBorder)
                    .font(.subheadline)
            }
            .padding(.horizontal, 24)

            // Save button
            Button {
                viewModel.saveItem(category: selectedCategory, color: selectedColor, notes: notes)
                dismiss()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark")
                    Text("Save to Closet")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(14)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Error banner

    private func errorBanner(message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .padding(.top, 1)
            Text(message)
                .font(.footnote)
                .foregroundColor(.red)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.08))
        .cornerRadius(10)
    }
}
