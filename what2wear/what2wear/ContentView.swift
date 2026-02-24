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

private struct DailyView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "bolt.fill")
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(.secondary)
                Text("Daily Outfits")
                    .font(.title2).fontWeight(.semibold)
                Text("Coming soon")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Daily")
        }
    }
}

private struct ClosetView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(.secondary)
                Text("My Closet")
                    .font(.title2).fontWeight(.semibold)
                Text("Coming soon")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Closet")
        }
    }
}
