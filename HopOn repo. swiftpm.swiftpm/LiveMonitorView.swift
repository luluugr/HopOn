import SwiftUI
import MapKit
import CoreLocation

//Acciones de emergencia
enum EmergencyAction {
    case fakeCall, shareLocation, panicAlert
}

// --- 1. MOTOR DEL GPS ---
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, @unchecked Sendable {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    
    // Centramos el mapa
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.0526, longitude: -98.2285),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }
}

enum TipoPin {
    case parada(nombre: String, tiempo: String)
    case camion
}

// El secreto para no parpadear: "coordinate" ahora es "var" para poder moverlo sin borrar el pin
struct PinMapa: Identifiable {
    let id: String
    var coordinate: CLLocationCoordinate2D
    let tipo: TipoPin
}

// --- 2. PANTALLA PRINCIPAL ---
struct LiveMonitorView: View {
    @Environment(\.dismiss) var dismiss
    let route: Route
    
    @StateObject private var locationManager = LocationManager()
    @AppStorage("hasSeenMonitorGuide") private var hasSeenMonitorGuide = false
    @AppStorage("trusted_contacts_json") private var contactsJSON: String = "[]"
    
    // Timer intermedio para que sea fluido y no trabe la app
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    // Estados de las pantallas
    @State private var showFakeCall = false
    @State private var showPanicScreen = false
    @State private var showLocationAlert = false
    @State private var showAR = false
    @State private var showConfirmation = false
    @State private var pendingAction: EmergencyAction?
    
    // Estados de Simulación por calles
    @State private var rutaCalles: [CLLocationCoordinate2D] = []
    @State private var currentRouteIndex: Int = 0
    @State private var isReturning: Bool = false
    
    // Lista fija de pines.
    @State private var pinesDelMapa: [PinMapa] = []
    
    let paradasReales = [
        PinMapa(id: "p1", coordinate: CLLocationCoordinate2D(latitude: 19.0660, longitude: -98.2010), tipo: .parada(nombre: "CAPU", tiempo: "0 min")),
        PinMapa(id: "p2", coordinate: CLLocationCoordinate2D(latitude: 19.0655, longitude: -98.2198), tipo: .parada(nombre: "San Pedro", tiempo: "10 min")),
        PinMapa(id: "p3", coordinate: CLLocationCoordinate2D(latitude: 19.0526, longitude: -98.2285), tipo: .parada(nombre: "La Paz", tiempo: "20 min")),
        PinMapa(id: "p4", coordinate: CLLocationCoordinate2D(latitude: 19.0560, longitude: -98.2831), tipo: .parada(nombre: "UDLAP", tiempo: "35 min")),
        PinMapa(id: "p5", coordinate: CLLocationCoordinate2D(latitude: 19.0605, longitude: -98.3060), tipo: .parada(nombre: "Cholula", tiempo: "45 min"))
    ]
    
    var body: some View {
        ZStack {
            Color.lightBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // --- HEADER ---
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3).bold().foregroundColor(.darkBlue)
                            .padding(10).background(Color.white).clipShape(Circle()).shadow(radius: 2)
                    }
                    Spacer()
                    Text(route.name).font(.headline).foregroundColor(.darkBlue)
                    Spacer()
                    HStack(spacing: 4) {
                        Circle().fill(Color.green).frame(width: 8, height: 8)
                        Text("EN RUTA").font(.caption).bold().foregroundColor(.green)
                    }
                    .padding(6).background(Color.white).cornerRadius(8).shadow(radius: 1)
                }
                .padding()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {
                        
                        // --- PANEL DE ESTIMACIONES ---
                        HStack {
                            Image(systemName: "clock.fill").foregroundColor(.orange)
                            Text("Rastreo Inteligente:").font(.subheadline).foregroundColor(.darkBlue)
                            Spacer()
                            Text(rutaCalles.isEmpty ? "Calculando calles..." : (isReturning ? "Regresando a CAPU" : "Hacia UDLAP/Cholula"))
                                .font(.subheadline).bold().foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.softOrange)
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                        
                        // --- MAPA ---
                        ZStack(alignment: .bottomTrailing) {
                            Map(coordinateRegion: $locationManager.region, showsUserLocation: true, annotationItems: pinesDelMapa) { pin in
                                MapAnnotation(coordinate: pin.coordinate) {
                                    switch pin.tipo {
                                    case .parada(let nombre, _):
                                        VStack(spacing: 2) {
                                            Text(nombre).font(.system(size: 9, weight: .bold)).padding(3).background(Color.white).cornerRadius(4).shadow(radius: 1)
                                            Circle().strokeBorder(Color.darkOrange, lineWidth: 2).background(Circle().fill(Color.white)).frame(width: 14, height: 14)
                                        }
                                    case .camion:
                                        Image(systemName: "bus.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .background(Color.darkBlue)
                                            .clipShape(Circle())
                                            .shadow(radius: 3)
                                    }
                                }
                            }
                            .frame(height: 280)
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            // BOTONES DE ZOOM
                            VStack(spacing: 10) {
                                Button(action: {
                                    withAnimation {
                                        locationManager.region.span.latitudeDelta *= 0.6
                                        locationManager.region.span.longitudeDelta *= 0.6
                                    }
                                }) {
                                    Image(systemName: "plus.magnifyingglass").font(.title3).foregroundColor(.darkBlue).padding(10).background(Color.white).clipShape(Circle()).shadow(radius: 3)
                                }
                                
                                Button(action: {
                                    withAnimation {
                                        locationManager.region.span.latitudeDelta *= 1.4
                                        locationManager.region.span.longitudeDelta *= 1.4
                                    }
                                }) {
                                    Image(systemName: "minus.magnifyingglass").font(.title3).foregroundColor(.darkBlue).padding(10).background(Color.white).clipShape(Circle()).shadow(radius: 3)
                                }
                            }
                            .padding()
                        }
                        .padding(.horizontal, 20)
                        
                        // --- BOTONES DE EMERGENCIA ---
                        VStack(spacing: 15) {
                            Text("SAFETY & EMERGENCY TOOLS")
                                .font(.caption).foregroundColor(.gray).textCase(.uppercase)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                Button(action: { pendingAction = .fakeCall; showConfirmation = true }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "phone.badge.waveform.fill").font(.title)
                                        Text("Simulated Call").font(.headline).bold()
                                    }
                                    .foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 110)
                                    .background(Color.buttonGreen).cornerRadius(15).shadow(radius: 3)
                                }
                                
                                Button(action: { showAR = true }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "camera.viewfinder").font(.title)
                                        Text("Evidence Cam").font(.headline).bold()
                                    }
                                    .foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 110)
                                    .background(Color.darkOrange).cornerRadius(15).shadow(radius: 3)
                                }
                                
                                Button(action: { enviarMensajeSOS() }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "location.fill").font(.title)
                                        Text("Share Location").font(.headline).bold()
                                    }
                                    .foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 110)
                                    .background(Color.yellow).cornerRadius(15).shadow(radius: 3)
                                }
                                
                                Button(action: { pendingAction = .panicAlert; showConfirmation = true }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "exclamationmark.shield.fill").font(.title)
                                        Text("Alert 911").font(.headline).bold()
                                    }
                                    .foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 110)
                                    .background(Color.red).cornerRadius(15).shadow(radius: 3)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    }
                }
            }
            
            // --- TUTORIAL ---
            if !hasSeenMonitorGuide {
                ZStack {
                    Color.black.opacity(0.8).ignoresSafeArea()
                    VStack(spacing: 25) {
                        Text("What will you find in the app?").font(.title2).fontWeight(.black).foregroundColor(Color("DarkPurple"))
                        Text("At the bottom of this screen, you have quick access to safety and emergency tools:").font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 12) {
                                Image(systemName: "phone.circle.fill").font(.title2).foregroundColor(Color("SoftPink"))
                                VStack(alignment: .leading) {
                                    Text("Simulated Call").fontWeight(.bold).foregroundColor(Color("DarkPurple"))
                                    Text("Simulate receiving a call...").font(.caption).foregroundColor(.gray)
                                }
                            }
                            HStack(spacing: 12) {
                                Image(systemName: "camera.circle.fill").font(.title2).foregroundColor(Color("MediumPurple"))
                                VStack(alignment: .leading) {
                                    Text("Evidence Cam").fontWeight(.bold).foregroundColor(Color("DarkPurple"))
                                    Text("Capture a photo and location...").font(.caption).foregroundColor(.gray)
                                }
                            }
                            HStack(spacing: 12) {
                                Image(systemName: "location.circle.fill").font(.title2).foregroundColor(Color("SoftPink"))
                                VStack(alignment: .leading) {
                                    Text("Share Location").fontWeight(.bold).foregroundColor(Color("DarkPurple"))
                                    Text("Send live GPS...").font(.caption).foregroundColor(.gray)
                                }
                            }
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.circle.fill").font(.title2).foregroundColor(Color("Salmon"))
                                VStack(alignment: .leading) {
                                    Text("Alert 911").fontWeight(.bold).foregroundColor(Color("DarkPurple"))
                                    Text("Instant emergency dialer.").font(.caption).foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Button(action: { withAnimation { hasSeenMonitorGuide = true } }) {
                            Text("Got it, let's go!").font(.headline).foregroundColor(.white).padding().frame(maxWidth: .infinity).background(LinearGradient(colors: [Color("DarkPurple"), Color("MediumPurple")], startPoint: .leading, endPoint: .trailing)).cornerRadius(15)
                        }
                        .padding(.top, 10)
                    }
                    .padding(25).background(Color.white).cornerRadius(25).shadow(radius: 20).padding(30)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .onAppear {
            hasSeenMonitorGuide = false
            
            // Llenamos la lista fija de pines al abrir la pantalla
            pinesDelMapa = paradasReales
            pinesDelMapa.append(PinMapa(id: "camion", coordinate: CLLocationCoordinate2D(latitude: 19.0660, longitude: -98.2010), tipo: .camion))
            
            calcularRutaPorCalles() // Pide las calles a Apple Maps
        }
        // --- NAVEGACIÓN SOBRE LAS CALLES ---
        .onReceive(timer) { _ in
            guard !rutaCalles.isEmpty else { return }
            guard pinesDelMapa.count > 0 else { return }
            
            if !isReturning {
                if currentRouteIndex < rutaCalles.count - 1 {
                    currentRouteIndex += 1
                } else {
                    isReturning = true // Llegó al final, da la vuelta
                }
            } else {
                if currentRouteIndex > 0 {
                    currentRouteIndex -= 1
                } else {
                    isReturning = false // Regresó al inicio, vuelve a ir
                }
            }
            
            // Movemos SUAVEMENTE solo la coordenada del camión (que es el último elemento de la lista)
            withAnimation(.linear(duration: 0.1)) {
                pinesDelMapa[pinesDelMapa.count - 1].coordinate = rutaCalles[currentRouteIndex]
            }
        }
        .fullScreenCover(isPresented: $showFakeCall) { SimulatedCallView() }
        .fullScreenCover(isPresented: $showPanicScreen) { PanicView() }
        .fullScreenCover(isPresented: $showAR) { EvidenceView() }
        .alert(isPresented: $showLocationAlert) { Alert(title: Text("Location Sent"), dismissButton: .default(Text("OK"))) }
        .confirmationDialog("Confirm Action", isPresented: $showConfirmation, titleVisibility: .visible) {
            Button(pendingAction == .panicAlert ? " Activate Alarm" : "Confirm", role: pendingAction == .panicAlert ? .destructive : .none) { executeAction() }
            Button("Cancel", role: .cancel) {}
        } message: { Text("Are you sure?") }
        .onShake { showFakeCall = true }
        .navigationBarBackButtonHidden(true)
    }
    
    // --- MAGIA DE APPLE MAPS ---
    func calcularRutaPorCalles() {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: paradasReales.first!.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: paradasReales.last!.coordinate))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {
                print("Error al calcular la ruta: \(String(describing: error))")
                return
            }
            
            let polyline = route.polyline
            var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: polyline.pointCount)
            polyline.getCoordinates(&coords, range: NSRange(location: 0, length: polyline.pointCount))
            
            DispatchQueue.main.async {
                self.rutaCalles = coords
            }
        }
    }
    
    func executeAction() {
        switch pendingAction {
        case .fakeCall: showFakeCall = true
        case .shareLocation: showLocationAlert = true
        case .panicAlert: showPanicScreen = true
        case .none: break
        }
    }
    
    func enviarMensajeSOS() {
        guard let data = contactsJSON.data(using: .utf8),
              let contacts = try? JSONDecoder().decode([TrustedContact].self, from: data),
              let contactoPrincipal = contacts.first,
              !contactoPrincipal.phone.isEmpty else { return }

        let lat = locationManager.userLocation?.latitude ?? 19.0560
        let lon = locationManager.userLocation?.longitude ?? -98.2831
        
        let mensaje = "¡AYUDA! Me siento insegura en el \(route.name). Sigue mi ubicación exacta en tiempo real aquí: https://maps.google.com/?q=\(lat),\(lon)"
        let urlString = "whatsapp://send?phone=\(contactoPrincipal.phone)&text=\(mensaje)"
        
        if let urlEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: urlEncoded), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}
