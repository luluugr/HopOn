import SwiftUI
import AVFoundation
import UIKit

struct EmergencyCallView: View {
    @Environment(\.dismiss) var dismiss
    
    // --- CALL STATES ---
    @State private var timeElapsed = 0
    @State private var timer: Timer?
    @State private var callStatus = "Calling..."
    @State private var isCallActive = false
    
    // --- AUDIO PLAYER ---
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // --- CALLER INFO ---
                VStack(spacing: 15) {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color("Salmon"))
                    
                    Text("911")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(isCallActive ? timeString(time: timeElapsed) : callStatus)
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // --- CALL CONTROLS ---
                HStack(spacing: 40) {
                    CallButton(icon: "mic.slash.fill", title: "Mute")
                    CallButton(icon: "dialpad.fill", title: "Keypad")
                    CallButton(icon: "speaker.wave.2.fill", title: "Speaker")
                }
                
                Spacer()
                
                // --- END CALL BUTTON ---
                Button(action: {
                    endCall()
                }) {
                    Image(systemName: "phone.down.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 80, height: 80)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startCallSimulation()
        }
        .onDisappear {
            audioPlayer?.stop()
            timer?.invalidate()
        }
    }
    
    
    // MARK: - FUNCTIONS
    
    
    func startCallSimulation() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                self.isCallActive = true
                self.callStatus = "Connected"
            }
            startTimer()
            playEmergencyAudio() 
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.timeElapsed += 1
            }
        }
    }
    
    func endCall() {
        timer?.invalidate()
        audioPlayer?.stop()
        dismiss()
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // --- AUDIO ---
    func playEmergencyAudio() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            print("🔊 Audio Configured: MAX VOLUME FORCE")
        } catch {
            print("Audio Session error: \(error.localizedDescription)")
        }
        
        let fileName = "EmergencyCall"
        print("Searching in Assets for: '\(fileName)'...")
        
       
        guard let soundAsset = NSDataAsset(name: fileName) else {
            print(" ERROR: Could not find '\(fileName)' in Assets.")
            return
        }
        
        
        do {
            audioPlayer = try AVAudioPlayer(data: soundAsset.data)
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("SUCCESS: Playing 911 audio now!")
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
}

// --- SUBVIEW FOR THE SMALL BUTTONS ---
struct CallButton: View {
    var icon: String
    var title: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}
