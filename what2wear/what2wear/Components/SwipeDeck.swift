import SwiftUI

struct SwipeDeck: View {
    @State private var offset = CGSize.zero
    
    var body: some View {
        ZStack {
            // Background Card (Tomorrow)
            OutfitCard(styleName: "Smart Casual")
                .scaleEffect(0.95)
                .offset(y: 20)
                .opacity(0.6)
                .zIndex(0)
            
            // Foreground Card (Today)
            OutfitCard(styleName: "Business Professional")
                .offset(x: offset.width, y: offset.height * 0.4)
                .rotationEffect(.degrees(Double(offset.width / 20)))
                .zIndex(1)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = gesture.translation
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                offset = .zero // Reset for demo
                            }
                        }
                )
        }
        .frame(maxWidth: 360, maxHeight: 480)
    }
}
