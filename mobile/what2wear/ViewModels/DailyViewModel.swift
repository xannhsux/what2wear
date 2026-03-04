import Foundation
import Combine

@MainActor
final class DailyViewModel: ObservableObject {
    
    @Published var dailyOutfit: Outfit?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var recommendationDate = Date()
    
    private let supabase = SupabaseService.shared
    
    func fetchRecommendation() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // Use a static test ID for simulation if no login exists
        let testUserId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        
        do {
            if let rec = try await supabase.fetchDailyRecommendation(userId: testUserId, date: recommendationDate) {
                // Here you would normally map the Supabase result to an Outfit model
                // For now, we simulate a recommendation if items exist.
                self.dailyOutfit = nil // Replace with real data mapping
                print("[DailyViewModel] Recommendation fetched.")
            } else {
                print("[DailyViewModel] No recommendation found for today.")
                self.dailyOutfit = nil
            }
        } catch {
            errorMessage = "Failed to load recommendation: \(error.localizedDescription)"
            print("[DailyViewModel] Fetch error: \(error)")
        }
    }
}
