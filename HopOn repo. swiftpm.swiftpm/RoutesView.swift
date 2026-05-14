import SwiftUI


struct RoutesView: View {
    @State private var allRoutes: [Route] = []
    @State private var searchText = ""
    @State private var selectedFilter = 0
    @State private var showSettings = false
    @State private var showAR = false
    
    @AppStorage("myFavoriteRoutes") private var favoritesData: Data = Data()
    @State private var favoriteIDs: Set<String> = []
    
    // Tutorials Manager
    @StateObject private var tutorialManager = TutorialManager(
        steps: routesTutorialSteps,
        tutorialKey: "routes"
    )
    
    // Filter Logic
    var filteredRoutes: [Route] {
        let routesByCategory: [Route]
        switch selectedFilter {
        case 1: routesByCategory = allRoutes.filter { $0.occupancy <= 3 || $0.safetyDescription.contains("Safe") }
        case 2: routesByCategory = allRoutes.filter { favoriteIDs.contains($0.id) }
        default: routesByCategory = allRoutes
        }
        
        if searchText.isEmpty { return routesByCategory }
        else {
            return routesByCategory.filter { route in
                route.name.localizedCaseInsensitiveContains(searchText) ||
                route.destination.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.lightBackground.ignoresSafeArea()
                
                VStack(spacing: 15) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Hello, Traveler!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Where are we going?")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.darkBlue)
                        }
                        Spacer()
                        Button(action: { showSettings = true }) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.largeTitle)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.green, Color.darkBlue)
                        }
                        .captureFrame(key: "contactIcon")
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Filter
                    Picker("Filters", selection: $selectedFilter) {
                        Text("All").tag(0)
                        Text("Safest").tag(1)
                        Text("Favorites").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .captureFrame(key: "filters")
                    
                    // List
                    if filteredRoutes.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            Image(systemName: selectedFilter == 2 ? "heart.slash" : "bus.doubledecker")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            Text(selectedFilter == 2 ? "No favorites yet" : "Route not found")
                                .font(.headline).foregroundColor(.gray)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredRoutes) { route in
                                    NavigationLink(destination: LiveMonitorView(route: route)) {
                                        RouteCard(
                                            route: route,
                                            isFavorite: favoriteIDs.contains(route.id),
                                            toggleFavorite: { toggleFavorite(routeID: route.id) }
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .background {
                                        if route.id == filteredRoutes.first?.id {
                                            Color.clear.captureFrame(key: "routesList")
                                        }
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
                // --- VIEW ---
                .coordinateSpace(name: "tutorialSpace")
                .scrollDisabled(tutorialManager.isActive)
                .withTutorial(manager: tutorialManager)
                .onAppear {
                    loadRealData()
                    loadFavorites()
                    
                    tutorialManager.resetTutorial()
                    
                    if !tutorialManager.hasSeenTutorial() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            tutorialManager.start()
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search route (e.g. Cholula)")
                .toolbar(.hidden, for: .navigationBar)
                .sheet(isPresented: $showSettings) { TrustedContactsView() }
            }
        }
    }
    
    // --- DATA ---
    func loadRealData() {
        let pueblaRoutes = [
            Route(name: "Route 10", destination: "CAPU - University City", arrivalTime: 12, occupancy: 5, safetyDescription: "Very crowded. Watch belongings.", stops: ["CAPU", "China Poblana", "Paseo Bravo", "Plaza Dorada", "University City"], timeIntervals: [0, 15, 30, 45, 60]),
            Route(name: "Azteca Route", destination: "Angelopolis - Center", arrivalTime: 8, occupancy: 4, safetyDescription: "Commercial area traffic.", stops: ["Angelopolis", "Noria", "Santiago", "Paseo Bravo", "Rivera Anaya"], timeIntervals: [0, 10, 25, 35, 50]),
            Route(name: "CREE - Madero", destination: "CREE - Madero", arrivalTime: 15, occupancy: 3, safetyDescription: "Quiet route, passes hospitals.", stops: ["CREE", "5 de Mayo", "Center", "Paseo Bravo", "Col. Madero"], timeIntervals: [0, 15, 25, 35, 45]),
            Route(name: "Route 72", destination: "Univ. City - Serdan", arrivalTime: 10, occupancy: 5, safetyDescription: "Crosses the entire city.", stops: ["Univ. City", "14 Sur", "Dorada", "Loreto", "Galerias Serdan"], timeIntervals: [0, 15, 30, 55, 75]),
            Route(name: "Route JBS", destination: "Fuertes - Cholula", arrivalTime: 6, occupancy: 4, safetyDescription: "Known for driving fast.", stops: ["Los Fuertes", "Xonaca", "Center", "Reforma", "Cholula"], timeIntervals: [0, 10, 20, 30, 50]),
            Route(name: "Bicentenario A", destination: "Univ. City - Finsa", arrivalTime: 18, occupancy: 4, safetyDescription: "Safe by day, lonely by VW at night.", stops: ["Univ. City", "Plaza Crystal", "Noria", "Reforma", "Finsa"], timeIntervals: [0, 20, 35, 50, 70]),
            Route(name: "Loma Bella", destination: "Loma Bella - Center", arrivalTime: 14, occupancy: 3, safetyDescription: "Quiet in the south.", stops: ["Loma Bella", "16 de Septiembre", "Carmen", "Center"], timeIntervals: [0, 15, 30, 45]),
            Route(name: "Route 33", destination: "Heroes - Center", arrivalTime: 9, occupancy: 5, safetyDescription: "Very full leaving Heroes.", stops: ["Los Heroes", "14 Sur", "El Gallito", "Paseo Bravo"], timeIntervals: [0, 20, 35, 45]),
            Route(name: "Route 68", destination: "North - Center", arrivalTime: 12, occupancy: 3, safetyDescription: "Neighborhood route.", stops: ["Morelos Market", "Xonaca", "San Francisco", "Center"], timeIntervals: [0, 10, 25, 40]),
            Route(name: "Route 44", destination: "CAPU - Carmen", arrivalTime: 11, occupancy: 3, safetyDescription: "School zones.", stops: ["CAPU", "Blvd Norte", "Reforma", "El Carmen"], timeIntervals: [0, 15, 30, 45]),
            Route(name: "Cholula Direct", destination: "Puebla - UDLAP", arrivalTime: 20, occupancy: 2, safetyDescription: "Safe tourist zone.", stops: ["Terminal", "La Paz", "Recta", "UDLAP", "Cholula"], timeIntervals: [0, 15, 20, 30, 45]),
            Route(name: "Galgos del Sur", destination: "Agua Santa - Center", arrivalTime: 13, occupancy: 4, safetyDescription: "Busy on 11 Sur.", stops: ["Agua Santa", "Mayorazgo", "Paseo Bravo", "Center"], timeIntervals: [0, 20, 35, 50]),
            Route(name: "Route 2000", destination: "Loma Bella - Xilotzingo", arrivalTime: 16, occupancy: 3, safetyDescription: "Long loop route.", stops: ["Loma Bella", "La Noria", "Plaza Cristal", "Xilotzingo"], timeIntervals: [0, 20, 35, 55]),
            Route(name: "Route 3 Estrellas", destination: "CAPU - Zaragoza", arrivalTime: 10, occupancy: 3, safetyDescription: "Passes markets.", stops: ["CAPU", "Hidalgo Market", "China Poblana", "Zaragoza"], timeIntervals: [0, 15, 25, 40]),
            Route(name: "Route 2A", destination: "Bosques - Center", arrivalTime: 14, occupancy: 3, safetyDescription: "Residential route.", stops: ["Bosques", "Rivera", "Center"], timeIntervals: [0, 15, 45])
        ]
        self.allRoutes = pueblaRoutes
    }
    
    func loadFavorites() {
        if let decoded = try? JSONDecoder().decode(Set<String>.self, from: favoritesData) {
            favoriteIDs = decoded
        }
    }
    func toggleFavorite(routeID: String) {
        if favoriteIDs.contains(routeID) { favoriteIDs.remove(routeID) }
        else { favoriteIDs.insert(routeID) }
        if let encoded = try? JSONEncoder().encode(favoriteIDs) { favoritesData = encoded }
        let generator = UIImpactFeedbackGenerator(style: .medium); generator.impactOccurred()
    }
    
    // --- CARD ---
    struct RouteCard: View {
        let route: Route
        var isFavorite: Bool
        var toggleFavorite: () -> Void
        
        var body: some View {
            HStack(spacing: 15) {
                ZStack {
                    Circle().fill(Color.mediumBlue.opacity(0.15)).frame(width: 55, height: 55)
                    Image(systemName: "bus.fill").foregroundColor(.mediumBlue).font(.title3)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(route.name).font(.headline).foregroundColor(.darkBlue)
                    Text(route.destination).font(.caption).foregroundColor(.gray).lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(route.arrivalTime) min")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.darkOrange)
                }
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(isFavorite ? .darkOrange : .gray.opacity(0.5))
                        .scaleEffect(isFavorite ? 1.1 : 1.0)
                        .animation(.spring(), value: isFavorite)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 8)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color.darkBlue.opacity(0.08), radius: 8, x: 0, y: 4)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Route \(route.name) towards \(route.destination). Arrives in \(route.arrivalTime) minutes.")
            .accessibilityHint("Double tap to open live monitor and safety tools.")
            .padding(.horizontal)
        }
    }
}
