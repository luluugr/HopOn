import SwiftUI

struct ContentView: View {
    // Memory Key
    @AppStorage("onboarding_debug") var hasSeenOnboarding: Bool = false
    @State private var showSplashScreen: Bool = true
    
    var body: some View {
        ZStack {
            if hasSeenOnboarding {
                // --- MAIN APP ---
                ZStack {
                    RoutesView()
                    
                    
                    if showSplashScreen {
                        SplashView(isActive: $showSplashScreen)
                            .transition(.opacity)
                            .zIndex(1)
                    }
                }
            } else {
                // --- STORY (ONBOARDING) ---
                OnboardingView(showOnboarding: Binding(
                    get: { !hasSeenOnboarding },
                    set: { if !$0 { hasSeenOnboarding = true } }
                ))
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: hasSeenOnboarding)
        .animation(.easeInOut(duration: 0.5), value: showSplashScreen)
        
        
        .onAppear {
            
            hasSeenOnboarding = false
            showSplashScreen = true
        }
    }
}
