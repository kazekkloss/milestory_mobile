import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/checkpoint_hit.dart';
import '../../domain/entities/lat_lng_entity.dart';

@lazySingleton
class TourTrackingService {
  static const _method = MethodChannel('milestory/tour_tracker');
  static const _locationEvents = EventChannel('milestory/tour_tracker/location');
  static const _checkpointEvents = EventChannel('milestory/tour_tracker/checkpoint');

  Future<void> requestPermission() => _method.invokeMethod('requestPermission');

  Future<void> startTracking() => _method.invokeMethod('startTracking');

  Future<void> stopTracking() => _method.invokeMethod('stopTracking');

  Future<void> setTourPoints(List<Map<String, dynamic>> payload) =>
      _method.invokeMethod('setTourPoints', payload);

  late final Stream<LatLng> locationStream = _locationEvents
      .receiveBroadcastStream()
      .map((event) {
        final map = Map<String, dynamic>.from(event as Map);
        return LatLng(
          (map['latitude'] as num).toDouble(),
          (map['longitude'] as num).toDouble(),
        );
      })
      .asBroadcastStream();

  late final Stream<CheckpointHit> checkpointStream = _checkpointEvents
      .receiveBroadcastStream()
      .map((event) {
        final map = Map<String, dynamic>.from(event as Map);
        return CheckpointHit(
          tourPointId: map['tourPointId'] as String,
          areaId: map['areaId'] as String,
        );
      })
      .asBroadcastStream();
}
