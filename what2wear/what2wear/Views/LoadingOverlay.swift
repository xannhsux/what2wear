import SwiftUI

/// Full-screen overlay shown while the AI face swap is running on Replicate.
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            // Card
            VStack(spacing: 24) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.6)
                    .tint(.white)

                VStack(spacing: 8) {
                    Text("Creating your avatar…")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("AI is applying your face — this takes about 30 seconds")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 44)
            .padding(.vertical, 36)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.black.opacity(0.82))
            )
        }
    }
}
