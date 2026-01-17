import SwiftUI

struct OutfitCard: View {
    let styleName: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Today's Recommendation")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 24)
                .padding(.horizontal, 24)
            
            Spacer()
            
            // Illustration Placeholder
            VStack {
                // Minimal Line Art Illustration using Shapes
                ZStack {
                    // Body
                    Rectangle()
                        .stroke(Color.black, lineWidth: 1.5)
                        .frame(width: 60, height: 90)
                    // Head
                    Circle()
                        .stroke(Color.black, lineWidth: 1.5)
                        .frame(width: 30, height: 30)
                        .offset(y: -60)
                    // Limbs (Simple lines)
                    Path { path in
                        path.move(to: CGPoint(x: 30, y: 0))
                        path.addLine(to: CGPoint(x: 10, y: 25)) // Left Arm
                        path.move(to: CGPoint(x: 90, y: 0))
                        path.addLine(to: CGPoint(x: 110, y: 25)) // Right Arm
                        path.move(to: CGPoint(x: 40, y: 90))
                        path.addLine(to: CGPoint(x: 30, y: 170)) // Left Leg
                        path.move(to: CGPoint(x: 80, y: 90))
                        path.addLine(to: CGPoint(x: 90, y: 170)) // Right Leg
                    }
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 120, height: 180)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
            
            // Footer
            VStack(spacing: 16) {
                Text(styleName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.textSecondary)
                
                Button(action: {
                    // View details
                }) {
                    Text("View Details")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.tint)
                        .clipShape(Capsule())
                }
            }
            .padding(24)
        }
        .background(Color.cardBackground)
        .cornerRadius(32)
        .shadow(color: Color.black.opacity(0.1), radius: 24, x: 0, y: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.black.opacity(0.02), lineWidth: 1)
        )
    }
}
