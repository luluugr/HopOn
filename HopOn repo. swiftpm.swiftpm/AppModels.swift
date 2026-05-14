import SwiftUI
import CoreLocation

// Main Route Structure
public struct Route: Identifiable, Codable {
    public let id: String
    public let name: String
    public let destination: String
    public let arrivalTime: Int      
    public let occupancy: Int
    public let safetyDescription: String
    public let stops: [String]
    
    // Real-time intervals (cumulative minutes from start)
    public let timeIntervals: [Int]
    
    // Option A: Reviews & Rating
    public var rating: Double
    public var reviews: [Review]
    
    public init(id: String = UUID().uuidString, name: String, destination: String, arrivalTime: Int, occupancy: Int, safetyDescription: String, stops: [String], timeIntervals: [Int], rating: Double = 4.5, reviews: [Review] = []) {
        self.id = id
        self.name = name
        self.destination = destination
        self.arrivalTime = arrivalTime
        self.occupancy = occupancy
        self.safetyDescription = safetyDescription
        self.stops = stops
        self.timeIntervals = timeIntervals
        self.rating = rating
        self.reviews = reviews
    }
}

// Review Structure
public struct Review: Identifiable, Codable {
    public var id = UUID()
    public let username: String
    public let comment: String
    public let rating: Int
    public let date: String
}
