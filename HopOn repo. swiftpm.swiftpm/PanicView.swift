import SwiftUI

struct PanicView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var isFlashing = false
    @State private var timer: Timer?
    let generator = UINotificationFeedbackGenerator()
    
    // State to show the Emergency Call Screen
    @State private var showEmergencyCall = false
    
    var body: some View {
        ZStack {
            (isFlashing ? Color.red : Color("Salmon"))
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .opacity(isFlashing ? 1.0 : 0.5)
                
                Text("HELP!")
                    .font(.system(size: 50, weight: .black))
                    .foregroundColor(.white)
                
                Text("Calling emergency services...")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Black Call 911 Button
                Button(action: {
                    showEmergencyCall = true
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call 911")
                    }
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                
                Button(action: {
                    timer?.invalidate()
                    dismiss()
                }) {
                    Text("False Alarm - Cancel")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 30)
            }
            .padding(.top, 50)
        }
        .onAppear {
            generator.prepare()
            
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                DispatchQueue.main.async {
                    withAnimation {
                        self.isFlashing.toggle()
                    }
                    self.generator.notificationOccurred(.error)
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .fullScreenCover(isPresented: $showEmergencyCall) {
            EmergencyCallView()
        }
    }
}
