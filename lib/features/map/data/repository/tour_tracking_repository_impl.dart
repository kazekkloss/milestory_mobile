import 'package:injectable/injectable.dart';

import '../../../../core/core_export.dart';
import '../../domain/entities/checkpoint_hit.dart';
import '../../domain/repository/tour_tracking_repository.dart';
import '../services/tour_tracking_service.dart';

@LazySingleton(as: TourTrackingRepository)
class TourTrackingRepositoryImpl implements TourTrackingRepository {
  final TourTrackingService _service;

  TourTrackingRepositoryImpl(this._service);

  @override
  Future<void> requestPermission() => _service.requestPermission();

  @override
  Future<void> startTracking() => _service.startTracking();

  @override
  Future<void> stopTracking() => _service.stopTracking();

  @override
  Future<void> setTourPoints(List<TourPoint> tourPoints) {
    final payload = tourPoints
        .map((tp) => {
              'id': tp.id.toString(),
              'areas': tp.areas
                  .map((a) => {
                        'id': a.id,
                        'coordinates': a.latLng
                            .map((ll) => {
                                  'latitude': ll.latitude,
                                  'longitude': ll.longitude,
                                })
                            .toList(),
                      })
                  .toList(),
            })
        .toList();
    return _service.setTourPoints(payload);
  }

  @override
  Stream<LatLng> get locationStream => _service.locationStream;

  @override
  Stream<CheckpointHit> get checkpointStream => _service.checkpointStream;
}
