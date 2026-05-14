import SwiftUI
import CoreLocation
import UIKit

struct EvidenceView: View {
    @Environment(\.dismiss) var dismiss
    
    // GPS Manager
    @StateObject private var locationManager = EvidenceLocationManager()
    
    // Camera States
    @State private var showCamera = false
    @State private var inputImage: UIImage?
    @State private var showShareSheet = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // --- HEADER ---
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Secure Evidence")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    // GPS
                    Image(systemName: locationManager.hasLocation ? "location.fill" : "location.slash")
                        .foregroundColor(locationManager.hasLocation ? .green : .red)
                }
                .padding()
                
                Spacer()
                
                // --- IMAGE PREVIEW ---
                if let image = inputImage {
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .frame(maxHeight: 400)
                        .overlay(
                            
                            VStack {
                                Spacer()
                                HStack {
                                    Image(systemName: "location.fill")
                                    Text(locationManager.locationString)
                                        .font(.caption)
                                        .bold()
                                }
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(10)
                            }
                        )
                        .padding()
                } else {
                    
                    VStack(spacing: 15) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        Text("Take a photo of your surroundings.")
                            .foregroundColor(.gray)
                        Text("It will be sent with your GPS location.")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // --- ACTION BUTTONS ---
                if inputImage == nil {
                    
                    //TAKE PHOTO BUTON
                    Button(action: {
                        showCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Take Evidence Photo")
                        }
                        .font(.title3.bold())
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                } else {
                    // ALERT BUTTON
                    Button(action: {
                        showShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("SEND ALERT NOW")
                        }
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                   //RETAKE BUTTON
                    Button("Retake Photo") {
                        inputImage = nil
                    }
                    .foregroundColor(.gray)
                    .padding(.top, 5)
                }
            }
        }
        .onAppear {
            locationManager.checkPermission()
        }
        // OPEN CAMERA
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $inputImage)
        }
        // SHARE
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [
                "URGENT! Here is my location and a photo of my surroundings: \n\(locationManager.mapLink)",
                inputImage as Any
            ])
        }
    }
}

// --- IMAGE PICKER ---
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}

// ---  SHARE SHEET (To send to contacts) ---
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// --- LOCATION MANAGER  ---
class EvidenceLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var locationString = "Locating..."
    @Published var mapLink = ""
    @Published var hasLocation = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        hasLocation = true
        
        locationString = "\(String(format: "%.4f", loc.coordinate.latitude)), \(String(format: "%.4f", loc.coordinate.longitude))"
        
        mapLink = "http://maps.google.com/?q=\(loc.coordinate.latitude),\(loc.coordinate.longitude)"
    }
}
