import CoreLocation

final class LocationManager: NSObject {

    var onLocationUpdate: ((CLLocation, Double?) -> Void)?
    var onError: ((Error) -> Void)?

    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?

    private static let minSpeedForCourseMps: Double = 0.5
    private static let minDistanceForBearingMeters: Double = 3.0

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }

    func requestPermission() {
        manager.requestAlwaysAuthorization()
    }

    func start() {
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopUpdatingLocation()
        lastLocation = nil
    }

    // Prefers Core Location's course (reliable above walking speed), falls back to
    // computing the bearing between the last two fixes once the user has moved
    // far enough for that calculation to be meaningful.
    private func resolveBearing(for location: CLLocation) -> Double? {
        if location.course >= 0, location.speed >= Self.minSpeedForCourseMps {
            return location.course
        }
        guard let previous = lastLocation else { return nil }
        guard location.distance(from: previous) >= Self.minDistanceForBearingMeters else { return nil }
        return Self.computeBearing(from: previous.coordinate, to: location.coordinate)
    }

    // Initial bearing (great-circle) from point 1 to point 2, in degrees [0, 360).
    private static func computeBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let phi1 = from.latitude * .pi / 180
        let phi2 = to.latitude * .pi / 180
        let deltaLambda = (to.longitude - from.longitude) * .pi / 180
        let y = sin(deltaLambda) * cos(phi2)
        let x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda)
        let theta = atan2(y, x) * 180 / .pi
        return (theta + 360).truncatingRemainder(dividingBy: 360)
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("[LocationManager] didUpdateLocations: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        let bearing = resolveBearing(for: location)
        onLocationUpdate?(location, bearing)
        lastLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationManager] didFailWithError: \(error.localizedDescription)")
        onError?(error)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        print("[LocationManager] authorizationStatus changed: \(status.rawValue)")
    }
}
