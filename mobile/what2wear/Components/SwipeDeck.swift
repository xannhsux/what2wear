import SwiftUI

/// Full-screen Tinder-style swipe deck for outfit recommendations.
struct SwipeDeck: View {
    let outfits: [Outfit]
    let currentIndex: Int
    let outfitImage: UIImage?
    let isGenerating: Bool
    let allItems: [ClothingItem]
    let onSwipeRight: (Outfit) -> Void
    let onSwipeLeft: (Outfit) -> Void
    let onTap: () -> Void

    @State private var offset = CGSize.zero

    private let swipeThreshold: CGFloat = 100

    var body: some View {
        ZStack {
            // Background card (next outfit)
            if currentIndex + 1 < outfits.count {
                OutfitCard(
                    outfit: outfits[currentIndex + 1],
                    outfitImage: nil,
                    isGenerating: false,
                    allItems: allItems
                )
                .scaleEffect(0.95)
                .offset(y: 16)
                .opacity(0.5)
                .zIndex(0)
            }

            // Foreground card (current outfit)
            if currentIndex < outfits.count {
                let outfit = outfits[currentIndex]
                OutfitCard(
                    outfit: outfit,
                    outfitImage: outfitImage,
                    isGenerating: isGenerating,
                    allItems: allItems
                )
                .offset(x: offset.width, y: offset.height * 0.4)
                .rotationEffect(.degrees(Double(offset.width / 20)))
                .overlay(swipeOverlay)
                .zIndex(1)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = gesture.translation
                        }
                        .onEnded { _ in
                            handleSwipeEnd(outfit: outfit)
                        }
                )
                .onTapGesture { onTap() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 480)
    }

    // MARK: - Swipe overlay (green/red tint)

    private var swipeOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.green.opacity(Double(max(0, offset.width)) / 200.0 * 0.3))

            RoundedRectangle(cornerRadius: 24)
                .fill(Color.red.opacity(Double(max(0, -offset.width)) / 200.0 * 0.3))

            // Like / Skip label
            if offset.width > 40 {
                Text("LIKE")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.green)
                    .rotationEffect(.degrees(-15))
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            if offset.width < -40 {
                Text("SKIP")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.red)
                    .rotationEffect(.degrees(15))
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Handle swipe

    private func handleSwipeEnd(outfit: Outfit) {
        if offset.width > swipeThreshold {
            withAnimation(.easeOut(duration: 0.3)) {
                offset = CGSize(width: 500, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                offset = .zero
                onSwipeRight(outfit)
            }
        } else if offset.width < -swipeThreshold {
            withAnimation(.easeOut(duration: 0.3)) {
                offset = CGSize(width: -500, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                offset = .zero
                onSwipeLeft(outfit)
            }
        } else {
            withAnimation(.spring()) {
                offset = .zero
            }
        }
    }
}
