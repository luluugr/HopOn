import SwiftUI
import UIKit
import Combine

// MARK: - Tutorial Manager
@MainActor
class TutorialManager: ObservableObject {
    @Published var isActive = false
    @Published var currentStepIndex = 0
    @Published var frames: [String: CGRect] = [:]
    
    let steps: [TutorialStep]
    let tutorialKey: String
    
    init(steps: [TutorialStep], tutorialKey: String) {
        self.steps = steps
        self.tutorialKey = tutorialKey
    }
    
    var currentStep: TutorialStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }
    
    var progress: String {
        "\(currentStepIndex + 1) / \(steps.count)"
    }
    
    var isLastStep: Bool {
        currentStepIndex == steps.count - 1
    }
    
    func next() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
        } else {
            finish()
        }
    }
    
    func previous() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        if currentStepIndex > 0 {
            currentStepIndex -= 1
        }
    }
    
    func skip() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        finish()
    }
    
    func start() {
        currentStepIndex = 0
        isActive = true
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    func finish() {
        isActive = false
        UserDefaults.standard.set(true, forKey: "hasSeenTutorial_\(tutorialKey)")
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }
    
    func hasSeenTutorial() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasSeenTutorial_\(tutorialKey)")
    }
    
    func resetTutorial() {
        UserDefaults.standard.set(false, forKey: "hasSeenTutorial_\(tutorialKey)")
    }
}
