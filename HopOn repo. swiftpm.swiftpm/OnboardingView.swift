import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    
    var body: some View {
        ZStack {
            
            Color.white.ignoresSafeArea()
            
            
            Color.orange.opacity(0.15).ignoresSafeArea()
            
            TabView {
                // --- FIRST VIEW---
                OnboardingPage(
                    systemImage: "mappin.and.ellipse",
                    assetImage: nil,
                    title: "In Puebla, 88% Feel Unsafe",
                    description: "According to ENSU surveys, nearly 9 out of 10 women in Puebla feel insecure on public transport. It is not just a statistic; it is our daily reality.",
                    iconColor: .red,
                    isLastPage: false,
                    action: {}
                )
                
                // --- SECOND VIEW ---
                OnboardingPage(
                    systemImage: nil,
                    assetImage: "mission_shield",
                    title: "Mobility is a Right, Not a Risk",
                    description: "HopOn was born with one clear mission: to make women feel safer navigating our city. We replace uncertainty with data to give you back your peace of mind.",
                    iconColor: .darkBlue,
                    isLastPage: false,
                    action: {}
                )
                
                // --- 3RD VIEW---
                OnboardingPage(
                    systemImage: "person.3.fill",
                    assetImage: nil,
                    title: "You Are Not Alone",
                    description: "Join the community traveling smarter in Puebla. Real-time tracking, discreet safety tools, and a network that looks out for you. Let's get home safe.",
                    iconColor: .darkOrange,
                    isLastPage: true,
                    action: {
                        withAnimation {
                            showOnboarding = false
                        }
                    }
                )
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

// ---  ---
struct OnboardingPage: View {
    
    let systemImage: String?
    let assetImage: String?
    let title: String
    let description: String
    let iconColor: Color
    let isLastPage: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            // IMAGE
            ZStack {
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 240, height: 240)
                    .shadow(color: iconColor.opacity(0.15), radius: 20, x: 0, y: 10)
                
               
                if let customName = assetImage {
                    
                    Image(customName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                } else if let sysName = systemImage {
                   
                    Image(systemName: sysName)
                        .font(.system(size: 100))
                        .foregroundColor(iconColor)
                }
            }
            .padding(.bottom, 20)
            
            // TEXT
            VStack(spacing: 15) {
                Text(title)
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.darkBlue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(description)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .lineSpacing(6)
            }
            
            Spacer()
            
            // BUTTON
            
            if isLastPage {
                Button(action: action) {
                    Text("Start Journey")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.darkOrange, .orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                .transition(.opacity)
            } else {
                Spacer().frame(height: 110) 
            }
        }
    }
}
