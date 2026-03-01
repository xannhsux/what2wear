import SwiftUI

/// Main Daily tab — pure Tinder-style card stack for outfit recommendations.
struct DailyView: View {

    @StateObject private var viewModel = DailyViewModel()
    @State private var showOutfitDetail = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if viewModel.isLoadingOutfits {
                    loadingView
                } else if !viewModel.hasAvatar {
                    noAvatarState
                } else if !viewModel.hasEnoughItems {
                    notEnoughItemsState
                } else if viewModel.isAllViewed {
                    allViewedState
                } else if viewModel.outfits.isEmpty {
                    noOutfitsState
                } else {
                    // Main card stack
                    cardStackView
                }
            }
            .navigationTitle("Daily")
            .onAppear {
                if viewModel.outfits.isEmpty && !viewModel.isLoadingOutfits {
                    Task { await viewModel.loadDaily() }
                }
            }
            .sheet(isPresented: $showOutfitDetail) {
                if let outfit = viewModel.currentOutfit {
                    OutfitDetailView(viewModel: viewModel, outfit: outfit)
                }
            }
        }
    }

    // MARK: - Card stack

    private var cardStackView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Outfit description text
            if let outfit = viewModel.currentOutfit {
                Text(outfit.description(items: viewModel.closetItems))
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // Swipe deck
            SwipeDeck(
                outfits: viewModel.outfits,
                currentIndex: viewModel.currentOutfitIndex,
                outfitImage: viewModel.outfitImage,
                isGenerating: viewModel.isGeneratingImage,
                allItems: viewModel.closetItems,
                onSwipeRight: { outfit in Task { await viewModel.swipeRight(outfit) } },
                onSwipeLeft: { outfit in Task { await viewModel.swipeLeft(outfit) } },
                onTap: { showOutfitDetail = true }
            )
            .padding(.horizontal, 16)

            // Progress indicator
            HStack(spacing: 6) {
                ForEach(0..<viewModel.outfits.count, id: \.self) { index in
                    Circle()
                        .fill(index == viewModel.currentOutfitIndex ? Color.textPrimary : Color(.systemGray4))
                        .frame(width: 8, height: 8)
                }
            }

            // Swipe hints
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.left")
                        .font(.caption2)
                    Text("Skip")
                        .font(.caption)
                }
                .foregroundColor(.textSecondary)

                Spacer()

                HStack(spacing: 4) {
                    Text("Like")
                        .font(.caption)
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                }
                .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.textSecondary)

            Text("Preparing your outfits...")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
    }

    // MARK: - Empty states

    private var noAvatarState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color(.tertiaryLabel))

            Text("Create your avatar first")
                .font(.headline)
                .foregroundColor(.textPrimary)

            Text("Go to Profile tab to generate your avatar")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var notEnoughItemsState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tshirt.fill")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color(.tertiaryLabel))

            Text("Add more clothes")
                .font(.headline)
                .foregroundColor(.textPrimary)

            Text("You need at least \(Constants.Recommendation.minClosetItems) items in your closet to get recommendations")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var noOutfitsState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color(.tertiaryLabel))

            Text("No outfits available")
                .font(.headline)
                .foregroundColor(.textPrimary)

            Text("Try adding more variety to your closet")
                .font(.subheadline)
                .foregroundColor(.textSecondary)

            Button {
                Task { await viewModel.loadDaily() }
            } label: {
                Text("Try Again")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var allViewedState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.textSecondary)

            Text("All recommendations viewed")
                .font(.headline)
                .foregroundColor(.textPrimary)

            Text("Come back tomorrow for new outfit ideas!")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await viewModel.loadDaily() }
            } label: {
                Text("Refresh")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.top, 8)
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Pulse animation modifier

private struct PulseModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? 0.6 : 1.0)
            .animation(
                .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}
