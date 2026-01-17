import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                DateSelector() // Top Bar
                
                Spacer()
                
                SwipeDeck() // Main Content
                
                Spacer()
                
                // Spacer for Bottom Nav height
                Color.clear.frame(height: 80)
            }
            
            BottomNavBar() // Overlay
        }
    }
}
