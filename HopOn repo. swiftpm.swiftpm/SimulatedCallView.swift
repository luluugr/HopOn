import SwiftUI
import AVFoundation
import UIKit //

struct SimulatedCallView: View {
    @Environment(\.dismiss) var dismiss
    
    // --- STATE VARIABLES ---
    @State private var callStatus = "Connecting..."
    @State private var showControls = false
    @State private var timerString = "00:00"
    @State private var secondsElapsed = 0
    
    // 1. TIMER
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Audio States
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isSpeakerOn = false
    @State private var isMuted = false
    
    var body: some View {
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [Color(white: 0.2), Color.black]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                // --- TOP INFO ---
                VStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.gray)
                        .padding(.top, 60)
                    
                    Text("Dad")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(showControls ? timerString : "calling mobile...")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // --- BUTTONS GRID ---
                if showControls {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 30) {
                        
                        CallButton(icon: isMuted ? "mic.slash.fill" : "mic.fill", label: "Mute", isActive: isMuted) { isMuted.toggle() }
                        CallButton(icon: "circle.grid.3x3.fill", label: "Keypad", isActive: false) {}
                        CallButton(icon: "speaker.wave.3.fill", label: "Speaker", isActive: isSpeakerOn) { toggleSpeaker() }
                        CallButton(icon: "plus", label: "Add call", isActive: false) {}
                        CallButton(icon: "video.fill", label: "FaceTime", isActive: false) {}
                        CallButton(icon: "person.crop.circle", label: "Contacts", isActive: false) {}
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
                
                // --- BOTTOM BUTTONS (END / ANSWER) ---
                if showControls {
                    // End Call Button
                    Button(action: { endCall() }) {
                        Image(systemName: "phone.down.fill")
                            .font(.largeTitle)
                            .frame(width: 80, height: 80)
                            .background(Color.red)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 50)
                } else {
                    // Incoming Call Buttons
                    HStack(spacing: 80) {
                        // Decline
                        VStack(spacing: 8) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "phone.down.fill")
                                    .font(.title).frame(width: 75, height: 75)
                                    .background(Color.red).clipShape(Circle()).foregroundColor(.white)
                            }
                            Text("Decline").foregroundColor(.white)
                        }
                        // Accept
                        VStack(spacing: 8) {
                            Button(action: { answerCall() }) {
                                Image(systemName: "phone.fill")
                                    .font(.title).frame(width: 75, height: 75)
                                    .background(Color.green).clipShape(Circle()).foregroundColor(.white)
                            }
                            Text("Accept").foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            setupAudioSession()
        }
        // 2. TIMER LOGIC
        .onReceive(timer) { _ in
            if showControls {
                secondsElapsed += 1
                let minutes = secondsElapsed / 60
                let seconds = secondsElapsed % 60
                timerString = String(format: "%02d:%02d", minutes, seconds)
            }
        }
    }
    
    // --- HELPER VIEW  ---
    struct CallButton: View {
        let icon: String; let label: String; let isActive: Bool; let action: () -> Void
        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.title).frame(width: 65, height: 65)
                        .background(isActive ? Color.white : Color(white: 0.25))
                        .clipShape(Circle())
                        .foregroundColor(isActive ? .black : .white)
                    Text(label).font(.caption).foregroundColor(.white)
                }
            }
        }
    }
    
    // --- FUNCTIONS ---
    
    func setupAudioSession() {
        do {
          
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            print(" Audio Configured: MAX VOLUME FORCE")
        } catch {
            print("Audio Configuration Failed: \(error)")
        }
    }
    
    func answerCall() {
        showControls = true
        secondsElapsed = 0
        
       
        isSpeakerOn = true
        
        
        playSound(fileName: "SimulatedCall")
    }
    
    func endCall() {
        audioPlayer?.stop()
        dismiss()
    }
    
    func toggleSpeaker() {
        
        isSpeakerOn.toggle()
    }
    
    func playSound(fileName: String) {
        print("📂 Searching in Assets for: '\(fileName)'...")
        
        
        guard let soundAsset = NSDataAsset(name: fileName) else {
            print("ERROR: Could not find '\(fileName)' in Assets.")
            print("Tip: Open 'Assets', drag your audio there, and check the name.")
            return
        }
        
        do {
            
            audioPlayer = try AVAudioPlayer(data: soundAsset.data)
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("SUCCESS: Playing... (Turn up volume!)")
        } catch {
            print("Technical Error: \(error.localizedDescription)")
        }
    }
}
