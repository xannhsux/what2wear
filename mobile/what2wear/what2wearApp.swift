import SwiftUI
import FirebaseCore

@main
struct What2WearApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
