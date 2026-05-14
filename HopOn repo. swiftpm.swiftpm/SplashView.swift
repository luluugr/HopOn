import SwiftUI

struct SplashView: View {
    
    @Binding var isActive: Bool
    
 
    @State private var busOffset: CGFloat = -300
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background
            Color.lightBackground.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Animated Bus
                Image(systemName: "bus.doubledecker.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.darkOrange)
                    .offset(x: busOffset)
                    .opacity(opacity)
                
                // Quote
                Text("\"Safety is not a destination,\nit's the journey.\"")
                    .font(.title3)
                    .fontWeight(.bold)
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.darkBlue)
                    .padding()
                    .opacity(opacity)
                
                Spacer()
                
                // --- BUTTON ---
                Button(action: {
                    withAnimation {
                        isActive = false
                    }
                }) {
                    HStack {
                        Text("Let's Go")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color.darkBlue)
                    .cornerRadius(30)
                    .shadow(radius: 5)
                }
                .padding(.bottom, 50)
                .opacity(opacity)
            }
        }
        .onAppear {
            // Animation
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
                busOffset = 0
                opacity = 1.0
            }
        }
    }
}
