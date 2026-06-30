import Flutter

final class TourTrackerChannel: NSObject {
    private let locationManager = LocationManager()
    private let checkpoint = CheckPoint()
    private var locationSink: FlutterEventSink?
    private var checkpointSink: FlutterEventSink?
    private var locationStreamHandler: EventSinkHandler?
    private var checkpointStreamHandler: EventSinkHandler?

    func register(with messenger: FlutterBinaryMessenger) {
        let methodChannel = FlutterMethodChannel(
            name: "milestory/tour_tracker",
            binaryMessenger: messenger
        )
        methodChannel.setMethodCallHandler(handleMethodCall)

        locationStreamHandler = EventSinkHandler(
            onListen: { [weak self] sink in
                print("[TourTracker] locationStream: onListen")
                self?.locationSink = sink
            },
            onCancel: { [weak self] in
                print("[TourTracker] locationStream: onCancel")
                self?.locationSink = nil
            }
        )
        let locationEventChannel = FlutterEventChannel(
            name: "milestory/tour_tracker/location",
            binaryMessenger: messenger
        )
        locationEventChannel.setStreamHandler(locationStreamHandler)

        checkpointStreamHandler = EventSinkHandler(
            onListen: { [weak self] sink in
                print("[TourTracker] checkpointStream: onListen")
                self?.checkpointSink = sink
            },
            onCancel: { [weak self] in
                print("[TourTracker] checkpointStream: onCancel")
                self?.checkpointSink = nil
            }
        )
        let checkpointEventChannel = FlutterEventChannel(
            name: "milestory/tour_tracker/checkpoint",
            binaryMessenger: messenger
        )
        checkpointEventChannel.setStreamHandler(checkpointStreamHandler)

        locationManager.onLocationUpdate = { [weak self] location, bearing in
            guard let self else { return }
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            print("[TourTracker] location update: \(lat), \(lng), bearing: \(String(describing: bearing))")
            locationSink?(["latitude": lat, "longitude": lng])
            if let hit = checkpoint.check(lat: lat, lng: lng, bearing: bearing) {
                print("[TourTracker] CHECKPOINT HIT — tourPoint: \(hit.tourPointId), area: \(hit.areaId)")
                checkpointSink?(["tourPointId": hit.tourPointId, "areaId": hit.areaId])
            }
        }

        locationManager.onError = { [weak self] error in
            print("[TourTracker] location error: \(error.localizedDescription)")
            self?.locationSink?(FlutterError(
                code: "LOCATION_ERROR",
                message: error.localizedDescription,
                details: nil
            ))
        }
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("[TourTracker] method: \(call.method)")
        switch call.method {
        case "requestPermission":
            locationManager.requestPermission()
            result(nil)
        case "startTracking":
            locationManager.start()
            result(nil)
        case "stopTracking":
            locationManager.stop()
            result(nil)
        case "setTourPoints":
            guard let points = call.arguments as? [[String: Any]] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected List<Map>", details: nil))
                return
            }
            print("[TourTracker] setTourPoints: \(points.count) tour points")
            checkpoint.setTourPoints(points)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

private final class EventSinkHandler: NSObject, FlutterStreamHandler {
    private let listenCallback: (FlutterEventSink?) -> Void
    private let cancelCallback: () -> Void

    init(onListen: @escaping (FlutterEventSink?) -> Void, onCancel: @escaping () -> Void) {
        self.listenCallback = onListen
        self.cancelCallback = onCancel
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        listenCallback(events)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        cancelCallback()
        return nil
    }
}
