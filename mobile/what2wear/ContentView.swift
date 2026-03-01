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

