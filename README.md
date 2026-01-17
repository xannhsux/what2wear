# what2wear (Native iOS)

**what2wear** is an AI-powered outfit recommendation app for iOS, built with **Swift** and **SwiftUI**.

## 🚀 Getting Started

This project contains the source code for the native iOS application. The files are located in the `swift_src` directory.

### Prerequisites
- Xcode 15+
- iOS 17+ SDK

### Installation

1.  **Create a new Xcode Project**:
    - Open Xcode.
    - Select **Create New Project** > **iOS** > **App**.
    - Product Name: `what2wear`.
    - Interface: **SwiftUI**.
    - Language: **Swift**.

2.  **Import Source Files**:
    Delete the default `ContentView.swift` and `what2wearApp.swift` in your new project. Drag and drop the contents of the `swift_src` folder into your Xcode project navigator:
    
    - `what2wearApp.swift` (Entry point)
    - `ContentView.swift` (Main Dashboard)
    - `DesignSystem/` (Colors and Theme)
    - `Components/` (UI Components)

3.  **Run the App**:
    - Select an iOS Simulator (e.g., iPhone 15/16 Pro).
    - Press **Cmd + R** to build and run.

## 📱 Features & UI

- **Premium Light Theme**: Custom `Color` palette in `DesignSystem/Colors.swift`.
- **Dashboard**:
    - **DateSelector**: Top bar with date and event context.
    - **SwipeDeck**: Interactive "Tinder-style" card stack for outfit recommendations.
    - **BottomNavBar**: Custom navigation bar with a floating "Add" action button.

## 📂 Project Structure

```
what2wear/
├── swift_src/
│   ├── what2wearApp.swift       # App Entry
│   ├── ContentView.swift        # Dashboard Screen
│   ├── DesignSystem/
│   │   └── Colors.swift         # Color Theme Definitions
│   └── Components/
│       ├── DateSelector.swift   # Top Date/Event Pill
│       ├── SwipeDeck.swift      # Card Stack Logic
│       ├── OutfitCard.swift     # Individual Card View
│       └── BottomNavBar.swift   # Custom Tab Bar
└── ... (Backup files)
```

## 🛠 Tech Stack
- **Language**: Swift 5.10+
- **Framework**: SwiftUI
- **Target**: iOS 17.0+
