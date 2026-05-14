import SwiftUI

// MARK: - Tutorial Step Model
struct TutorialStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let targetKey: String
    let position: TutorialPosition
}

// MARK: - Tutorial Position
enum TutorialPosition {
    case top
    case bottom
    case center
}

// MARK: - HopOn Tutorial Steps
let routesTutorialSteps = [
    TutorialStep(
        title: "Welcome Traveler!",
        description: "Tap the icon on the right to manage your Trusted Contacts. These are the people to whom your location will be sent when you feel unsafe.",
        targetKey: "contactIcon",
        position: .bottom
    ),
    TutorialStep(
        title: "Smart Filters",
        description: "Quickly sort the routes to find the safest ones or access your personal favorites.",
        targetKey: "filters",
        position: .bottom
    ),
    TutorialStep(
        title: "Live Tracking",
        description: "Tap any route card to see the bus moving in real-time and access your emergency tools.",
        targetKey: "routesList",
        position: .center
    )
]
