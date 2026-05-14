import SwiftUI
import UIKit

// MARK: - Frame Capture Logic
struct FramePreferenceKey: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { current, _ in current }
    }
}

extension View {
    func captureFrame(key: String) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: FramePreferenceKey.self, value: [key: geo.frame(in: .named("tutorialSpace"))])
            }
        )
    }
    
    func withTutorial(manager: TutorialManager) -> some View {
        self
            .onPreferenceChange(FramePreferenceKey.self) { frames in
                manager.frames = frames
            }
            .overlay {
                if manager.isActive, let step = manager.currentStep, let frame = manager.frames[step.targetKey] {
                    TutorialOverlay(
                        step: step,
                        highlightFrame: frame,
                        progress: manager.progress,
                        isLastStep: manager.isLastStep,
                        canGoBack: manager.currentStepIndex > 0,
                        onNext: { manager.next() },
                        onPrevious: { manager.previous() },
                        onSkip: { manager.skip() }
                    )
                    .zIndex(100)
                }
            }
    }
}

// MARK: - Tutorial Overlay UI
struct TutorialOverlay: View {
    let step: TutorialStep
    let highlightFrame: CGRect
    let progress: String
    let isLastStep: Bool
    let canGoBack: Bool
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onSkip: () -> Void
    
    private var topInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 0
    }
    
    private var adjustedFrame: CGRect {
        CGRect(
            x: highlightFrame.minX,
            y: highlightFrame.minY + topInset,
            width: highlightFrame.width,
            height: highlightFrame.height
        )
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Darkened background with cutout
                SpotlightShape(rect: adjustedFrame)
                    .fill(Color.black.opacity(0.85), style: FillStyle(eoFill: true))
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
                
                // Bright border around the highlighted element (Using app color)
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("DarkPurple"), lineWidth: 3)
                    .frame(width: adjustedFrame.width + 20, height: adjustedFrame.height + 20)
                    .position(x: adjustedFrame.midX, y: adjustedFrame.midY)
                    .shadow(color: Color("DarkPurple").opacity(0.5), radius: 10)
                    .allowsHitTesting(false)
                
                // Explanation Card
                VStack(spacing: 20) {
                    HStack {
                        Text(progress).font(.caption.bold()).foregroundColor(.white.opacity(0.6))
                        Spacer()
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Text(step.title).font(.title2.bold()).foregroundColor(.white)
                        Text(step.description).font(.body).foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    // Buttons Row
                    HStack(spacing: 12) {
                        // Skip Button (Salmon color)
                        Button(action: onSkip) {
                            Text("Skip").font(.subheadline.bold())
                                .foregroundColor(Color("Salmon"))
                                .padding(.horizontal, 20).padding(.vertical, 10)
                                .background(Color("Salmon").opacity(0.2)).cornerRadius(12)
                        }
                        Spacer()
                        if canGoBack {
                            Button(action: onPrevious) {
                                Image(systemName: "chevron.left").font(.subheadline.bold())
                                    .foregroundColor(.white).frame(width: 44, height: 44)
                                    .background(Color.white.opacity(0.15)).cornerRadius(12)
                            }
                        }
                        // Next/Done Button (App Gradient)
                        Button(action: onNext) {
                            HStack(spacing: 6) {
                                Text(isLastStep ? "Done" : "Next").font(.subheadline.bold())
                                if !isLastStep { Image(systemName: "chevron.right").font(.caption.bold()) }
                            }
                            .foregroundColor(.white).padding(.horizontal, 24).padding(.vertical, 12)
                            .background(
                                LinearGradient(colors: [Color("DarkPurple"), Color("MediumPurple")], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(24)
                // Card Background styling
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color("DarkPurple").opacity(0.95))
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 20)
                .position(x: geo.size.width / 2, y: calculateCardPosition(for: step.position, highlight: adjustedFrame))
            }
        }
        .ignoresSafeArea()
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: highlightFrame)
    }
    
    private func calculateCardPosition(for position: TutorialPosition, highlight: CGRect) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let margin: CGFloat = 40
        switch position {
        case .top: return highlight.minY - 140
        case .bottom: return highlight.maxY + margin + 120
        case .center: return screenHeight * 0.5
        }
    }
}

struct SpotlightShape: Shape {
    let rect: CGRect
    func path(in bounds: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(origin: .zero, size: bounds.size))
        let spotlightRect = rect.insetBy(dx: -10, dy: -10)
        path.addPath(RoundedRectangle(cornerRadius: 20).path(in: spotlightRect))
        return path
    }
}
