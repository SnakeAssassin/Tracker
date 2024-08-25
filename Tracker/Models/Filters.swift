import Foundation

enum Filters: String, CaseIterable {
    case allTrackers = "allTrackers"
    case todayTrackers = "todayTrackers"
    case completedTrackers = "completedTrackers"
    case unCompletedTrackers = "unCompletedTrackers"
    
    var localized: String {
        return String.localized(self.rawValue)
    }
}
