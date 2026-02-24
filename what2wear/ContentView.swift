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

// MARK: - Placeholder screens (phase 2+)

private struct DailyView: View {
    var body: some View {
        NavigationView {
            placeholderBody(icon: "bolt.fill", title: "Daily Outfits")
                .navigationTitle("Daily")
        }
    }
}

private struct ClosetView: View {
    var body: some View {
        NavigationView {
            placeholderBody(icon: "tshirt.fill", title: "My Closet")
                .navigationTitle("Closet")
        }
    }
}

private func placeholderBody(icon: String, title: String) -> some View {
    VStack(spacing: 16) {
        Spacer()
        Image(systemName: icon)
            .font(.system(size: 64, weight: .light))
            .foregroundColor(.secondary)
        Text(title)
            .font(.title2).fontWeight(.semibold)
        Text("Coming soon")
            .foregroundColor(.secondary)
        Spacer()
    }
    .frame(maxWidth: .infinity)
}
