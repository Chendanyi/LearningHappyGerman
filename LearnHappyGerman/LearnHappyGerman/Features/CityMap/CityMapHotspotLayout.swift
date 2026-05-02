import CoreGraphics
import Foundation

/// Normalized tap centers for `CityWalkMap` (0…1, origin top-left). Single source for layout + scenarios.
enum CityMapHotspotLayout {
    enum Building: String, CaseIterable, Hashable {
        case trainStation = "Train Station"
        case bakery = "Bakery"
        case restaurant = "Restaurant"
        case coffeeShop = "Coffee Shop"
        case hospital = "Hospital"
        case centralHotel = "Central Hotel"
        case supermarket = "Supermarket"
        case shoppingCenter = "Shopping Center"
        case postOffice = "Post Office"
        case cinema = "Cinema"
        case school = "School"
        case townHall = "Town Hall"

        var normalizedCenter: (x: CGFloat, y: CGFloat) {
            switch self {
            case .trainStation: return (0.30, 0.10)
            case .bakery: return (0.53, 0.15)
            case .restaurant: return (0.80, 0.10)
            case .coffeeShop: return (0.40, 0.32)
            case .hospital: return (0.78, 0.35)
            case .centralHotel: return (0.30, 0.53)
            case .supermarket: return (0.70, 0.57)
            case .shoppingCenter: return (0.32, 0.73)
            case .postOffice: return (0.70, 0.74)
            case .cinema: return (0.23, 0.90)
            case .school: return (0.50, 0.90)
            case .townHall: return (0.78, 0.90)
            }
        }
    }
}
