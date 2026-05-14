import SwiftUI


enum Category: String, CaseIterable {
    case busStops = "Bus Stops"
    case safeZones = "Safe Zones"
    case report = "Report Incident"
    
    var color: Color {
        switch self {
        case .busStops: return .darkBlue
        case .safeZones: return .darkOrange
        case .report: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .busStops: return "bus.fill"
        case .safeZones: return "shield.fill"
        case .report: return "exclamationmark.bubble.fill"
        }
    }
}

struct CategorySelectionView: View {
    let categories = Category.allCases
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // HEADER
                    HStack {
                        Text("Select Mode")
                            .font(.largeTitle.bold())
                            .foregroundColor(.darkBlue)
                        Spacer()
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.largeTitle)
                            .foregroundColor(.darkBlue)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // BUTTONS
                    ForEach(categories, id: \.self) { cat in
                        NavigationLink(destination: destinationView(for: cat)) {
                            HStack {
                                Image(systemName: cat.icon).font(.title2)
                                Text(cat.rawValue).font(.title3.bold())
                                Spacer()
                                Image(systemName: "chevron.right").font(.headline).opacity(0.6)
                            }
                            .padding(25)
                            .background(cat.color)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(color: cat.color.opacity(0.4), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .background(Color.white)
        }
    }
    
    // DESTINATIONS
    @ViewBuilder
    private func destinationView(for category: Category) -> some View {
        if category == .safeZones {
            EvidenceView()
        } else if category == .busStops {
            RoutesView()
        } else {
            ARViewPlaceholder(category: category)
        }
    }
}

struct ARViewPlaceholder: View {
    var category: Category
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 80))
                .foregroundColor(category.color)
                .opacity(0.5)
            Text("Work in Progress")
                .font(.title)
                .bold()
                .foregroundColor(.gray)
        }
    }
}
