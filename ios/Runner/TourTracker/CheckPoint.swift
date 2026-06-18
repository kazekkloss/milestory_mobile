import Foundation

private struct TrackedArea {
    let id: String
    let coordinates: [(lat: Double, lng: Double)]
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
                let coords = coordsRaw.compactMap { c -> (lat: Double, lng: Double)? in
                    guard let lat = c["latitude"], let lng = c["longitude"] else { return nil }
                    return (lat, lng)
                }
                return TrackedArea(id: areaId, coordinates: coords)
            }
            return TrackedTourPoint(id: id, areas: areas)
        }
        currentAreaId = nil
        let totalAreas = tourPoints.reduce(0) { $0 + $1.areas.count }
        print("[TourTracker] CheckPoint: loaded \(tourPoints.count) tour points, \(totalAreas) areas total")
    }

    // Returns (tourPointId, areaId) if the user entered a new area, nil otherwise.
    func check(lat: Double, lng: Double) -> (tourPointId: String, areaId: String)? {
        for tp in tourPoints {
            for area in tp.areas {
                if pointInPolygon(lat: lat, lng: lng, polygon: area.coordinates) {
                    guard area.id != currentAreaId else { return nil }
                    currentAreaId = area.id
                    return (tp.id, area.id)
                }
            }
        }
        currentAreaId = nil
        return nil
    }

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
