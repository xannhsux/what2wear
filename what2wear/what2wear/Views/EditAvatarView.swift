import SwiftUI

/// Presented as a sheet from MyAvatarView.
/// Lets the user pick or shoot a selfie, preview it, then kick off avatar generation.
struct EditAvatarView: View {

    @ObservedObject var viewModel: AvatarViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showPhotoLibrary = false
    @State private var showCamera       = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {

                        // ── Selfie preview ─────────────────────────────────────
                        selfiePreview
                            .padding(.top, 40)

                        // ── Feature hint ───────────────────────────────────────
                        VStack(spacing: 4) {
                            Text("Your face & hair will be placed on your avatar")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Text("Works best with a clear front-facing photo")
                                .font(.caption)
                                .foregroundColor(Color(.tertiaryLabel))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 32)

                        // ── Upload buttons ─────────────────────────────────────
                        VStack(spacing: 12) {
                            takeSelfieButton
                            uploadPictureButton
                        }
                        .padding(.horizontal, 24)

                        // ── Generate (only visible once a selfie is selected) ──
                        if viewModel.selfieImage != nil {
                            generateButton
                                .padding(.horizontal, 24)
                        }

                        // ── Error banner ────────────────────────────────────────
                        if let error = viewModel.errorMessage {
                            errorBanner(message: error)
                                .padding(.horizontal, 24)
                        }

                        Spacer(minLength: 40)
                    }
                }

                // Loading overlay sits above everything while generating
                if viewModel.isGenerating {
                    LoadingOverlay()
                }
            }
            .navigationTitle("Create Your AI Headshot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.clearError()
                        dismiss()
                    }
                    .disabled(viewModel.isGenerating)
                }
            }
            .sheet(isPresented: $showPhotoLibrary) {
                PhotoPicker(image: $viewModel.selfieImage)
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker(image: $viewModel.selfieImage)
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - Selfie preview

    private var selfiePreview: some View {
        ZStack(alignment: .topTrailing) {

            // Circle image / placeholder
            Group {
                if let selfie = viewModel.selfieImage {
                    Image(uiImage: selfie)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 200, height: 200)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color(.tertiaryLabel))
                        )
                }
            }
            .overlay(Circle().stroke(Color(.separator), lineWidth: 1))

            // Dismiss-selfie button
            if viewModel.selfieImage != nil {
                Button {
                    viewModel.clearSelfie()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(.systemBackground), Color(.secondaryLabel))
                }
                .offset(x: 6, y: -6)
            }
        }
    }

    // MARK: - Buttons

    private var takeSelfieButton: some View {
        Button {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                showCamera = true
            } else {
                // Simulator fallback
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
    }

    private var uploadPictureButton: some View {
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

    private var generateButton: some View {
        Button {
            Task {
                await viewModel.generateAvatar()
                // Auto-dismiss only if generation succeeded
                if viewModel.errorMessage == nil,
                   viewModel.generatedAvatarImage != nil {
                    dismiss()
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "wand.and.stars")
                Text("Apply My Look")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isGenerating ? Color.black.opacity(0.45) : Color.black)
            .foregroundColor(.white)
            .cornerRadius(14)
        }
        .disabled(viewModel.isGenerating)
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
