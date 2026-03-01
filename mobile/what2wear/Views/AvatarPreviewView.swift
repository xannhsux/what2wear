import SwiftUI

/// Preview screen showing the transparent avatar on a black background.
/// User can Regenerate or Save to Firebase.
struct AvatarPreviewView: View {

    @ObservedObject var viewModel: AvatarViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // Transparent avatar on black background
                    if let image = viewModel.transparentAvatarImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 32)
                    }

                    Spacer()

                    // Action buttons
                    VStack(spacing: 14) {
                        // Save button
                        Button {
                            Task {
                                await viewModel.saveToFirebase()
                                if viewModel.errorMessage == nil {
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack(spacing: 10) {
                                if viewModel.isSaving {
                                    ProgressView()
                                        .tint(.black)
                                } else {
                                    Image(systemName: "checkmark")
                                }
                                Text(viewModel.isSaving ? "Saving..." : "Save Avatar")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(14)
                        }
                        .disabled(viewModel.isSaving)

                        // Regenerate button
                        Button {
                            Task {
                                dismiss()
                                await viewModel.regenerate()
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.clockwise")
                                Text("Regenerate")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.15))
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(viewModel.isSaving)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                    // Error
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 12)
                    }
                }
            }
            .navigationTitle("Avatar Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}
