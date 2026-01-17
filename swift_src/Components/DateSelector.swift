import SwiftUI

struct DateSelector: View {
    var body: some View {
        VStack(spacing: 16) {
            // Date Pill
            Button(action: {
                // Action to change date
            }) {
                HStack {
                    Text("Friday")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.textInverse)
                        .tracking(-0.5)
                    
                    Spacer()
                    
                    Text("Jan 16")
                        .font(.system(size: 16))
                        .foregroundColor(Color.textInverse.opacity(0.8))
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 24)
                .background(Color.tint)
                .clipShape(Capsule())
                .frame(maxWidth: 380)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Event Label
            HStack(spacing: 8) {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.textPrimary)
                
                Text("Work Day – Office")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.textPrimary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.white)
            .overlay(
                Capsule()
                    .stroke(Color.borderSubtle, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .padding(.vertical, 20)
    }
}

// Helper for button press effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
