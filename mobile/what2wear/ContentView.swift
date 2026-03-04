import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DailyView()
                .tabItem { Label("Daily",   systemImage: "bolt.fill")   }

            ClosetView()
                .tabItem { Label("Closet",  systemImage: "tshirt.fill") }

            MyAvatarView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}

// MARK: - Placeholder screens (to be wired up in later phases)

struct DailyView: View {
    @StateObject private var viewModel = DailyViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Date header
                    VStack(spacing: 4) {
                        Text(viewModel.recommendationDate, style: .date)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Today's Recommendation")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                    }
                    .padding(.top, 24)
                    
                    if viewModel.isLoading {
                        loadingPlaceholder
                    } else if let outfit = viewModel.dailyOutfit {
                        outfitDisplay(outfit: outfit)
                    } else {
                        emptyRecommendation
                    }
                    
                    Spacer()
                    
                    // Generate / Refresh button
                    Button {
                        Task { await viewModel.fetchRecommendation() }
                    } label: {
                        Text("Rebuild Outfit")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 14)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarHidden(true)
            .onAppear {
                Task { await viewModel.fetchRecommendation() }
            }
        }
    }
    
    private var loadingPlaceholder: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("AI is curating your look...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var emptyRecommendation: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(Color(.tertiaryLabel))
            Text("No recommendation yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            Text("Try adding more items to your closet for better results.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
    }
    
    private func outfitDisplay(outfit: Outfit) -> some View {
         VStack(spacing: 16) {
             // Simple placeholder for item display
             Text("Wait till our AI is connected!")
                 .font(.caption)
                 .foregroundColor(.secondary)
         }
         .frame(maxHeight: .infinity)
    }
}

