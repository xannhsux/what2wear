import SwiftUI

struct BottomNavBar: View {
    var body: some View {
        HStack {
            NavItem(icon: "house")
            NavItem(icon: "rectangle.grid.2x2") // Wardrobe
            
            // Plus Button
            ZStack {
                Circle()
                    .fill(Color.tint)
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 8)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
            }
            .offset(y: -24)
            .onTapGesture {
                // Add action
            }
            
            NavItem(icon: "magnifyingglass")
            NavItem(icon: "person")
        }
        .frame(height: 60)
        .padding(.top, 20) // Top padding to accommodate the offset button visually in container
        .padding(.bottom, 0) // Safe area handled by parent/device
        .background(
            Color.white.opacity(0.95)
                .background(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.bottom)
        )
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.borderSubtle),
            alignment: .top
        )
    }
}

struct NavItem: View {
    let icon: String
    var isSelected: Bool = false
    
    var body: some View {
        Frame {
            Image(systemName: isSelected ? icon + ".fill" : icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? Color.textPrimary : Color.textSecondary)
        }
    }
}

struct Frame<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content.frame(maxWidth: .infinity)
    }
}
