import Foundation

private struct TrackedArea {
    let id: String
    let coordinates: [(lat: Double, lng: Double)]
    let direction: Double? // required heading to enter the area to trigger audio, degrees [0, 360)
}

private struct TrackedTourPoint {
    let id: String
    let areas: [TrackedArea]
}

final class CheckPoint {
    private var tourPoints: [TrackedTourPoint] = []
    private var currentAreaId: String?

    func setTourPoints(_ raw: [[String: Any]]) {
        tourPoints = raw.compactMap { tp in
            guard let id = tp["id"] as? String,
                  let areasRaw = tp["areas"] as? [[String: Any]] else { return nil }
            let areas = areasRaw.compactMap { area -> TrackedArea? in
                guard let areaId = area["id"] as? String,
                      let coordsRaw = area["coordinates"] as? [[String: Double]] else { return nil }
                let direction = area["direction"] as? Double
                let coords = coordsRaw.compactMap { c -> (lat: Double, lng: Double)? in
                    guard let lat = c["latitude"], let lng = c["longitude"] else { return nil }
                    return (lat, lng)
                }
                return TrackedArea(id: areaId, coordinates: coords, direction: direction)
            }
            return TrackedTourPoint(id: id, areas: areas)
        }
        currentAreaId = nil
        let totalAreas = tourPoints.reduce(0) { $0 + $1.areas.count }
        print("[TourTracker] CheckPoint: loaded \(tourPoints.count) tour points, \(totalAreas) areas total")
    }

    // Returns (tourPointId, areaId) if the user entered a new area facing the
    // direction required by that area (if any), nil otherwise. If the area
    // requires a direction that hasn't matched yet, the area is not marked as
    // handled so it keeps being re-evaluated on subsequent fixes until the user
    // either matches the direction or leaves the area.
    func check(lat: Double, lng: Double, bearing: Double?) -> (tourPointId: String, areaId: String)? {
        for tp in tourPoints {
            for area in tp.areas {
                if pointInPolygon(lat: lat, lng: lng, polygon: area.coordinates) {
                    guard area.id != currentAreaId else { return nil }
                    if let direction = area.direction {
                        guard let bearing = bearing else { return nil }
                        guard angularDifference(bearing, direction) <= Self.directionToleranceDegrees else { return nil }
                    }
                    currentAreaId = area.id
                    return (tp.id, area.id)
                }
            }
        }
        currentAreaId = nil
        return nil
    }

    // Smallest difference between two compass bearings, in degrees [0, 180].
    private func angularDifference(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b).truncatingRemainder(dividingBy: 360.0)
        return diff > 180.0 ? 360.0 - diff : diff
    }

    private static let directionToleranceDegrees: Double = 45.0

    // Ray-Casting algorithm: counts edge crossings to determine point-in-polygon.
    private func pointInPolygon(lat: Double, lng: Double, polygon: [(lat: Double, lng: Double)]) -> Bool {
        let n = polygon.count
        guard n >= 3 else { return false }
        var inside = false
        var j = n - 1
        for i in 0..<n {
            let xi = polygon[i].lng, yi = polygon[i].lat
            let xj = polygon[j].lng, yj = polygon[j].lat
            if ((yi > lat) != (yj > lat)) && (lng < (xj - xi) * (lat - yi) / (yj - yi) + xi) {
                inside = !inside
            }
            j = i
        }
        return inside
    }
}
