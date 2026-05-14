import SwiftUI

extension View {
    func reverseMask<Mask: View>(
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask(
            ZStack {
                Rectangle()
                mask().blendMode(.destinationOut)
            }
            .compositingGroup()
        )
    }
}

// --- BUBBLE VIEW ---
struct CoachMarkBubble: View {
    let text: String
    let buttonText: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
         
            Image(systemName: "triangle.fill")
                .foregroundColor(.white)
                .font(.title2)
                .padding(.bottom, -5)
            
       
            VStack(alignment: .leading, spacing: 15) {
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Spacer()
                    Button(action: action) {
                        Text(buttonText)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(15)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 40)
    }
}
