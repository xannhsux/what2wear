import SwiftUI

/// The "Profile" tab — shows the saved avatar full-width or an empty state prompt.
struct MyAvatarView: View {

    @StateObject private var viewModel = AvatarViewModel()
    @State private var showEditAvatar  = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Spacer()

                if let avatar = viewModel.generatedAvatarImage {
                    avatarDisplay(avatar)
                } else {
                    emptyState
                }

                Spacer()

                editAvatarButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
            }
            .navigationTitle("My Avatar")
            .sheet(isPresented: $showEditAvatar) {
                EditAvatarView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Subviews

    private func avatarDisplay(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .cornerRadius(20)
            .padding(.horizontal, 24)
            .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 6)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 160, height: 160)
                Image(systemName: "person.fill")
                    .font(.system(size: 72))
                    .foregroundColor(Color(.tertiaryLabel))
            }

            Text("No Avatar Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Upload a selfie to create your\npersonalised AI avatar")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var editAvatarButton: some View {
        Button {
            viewModel.clearError()
            showEditAvatar = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "pencil")
                Text("Edit Avatar")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(14)
        }
    }
}
