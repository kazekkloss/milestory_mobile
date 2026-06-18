import '../entities/checkpoint_hit.dart';
import '../entities/lat_lng_entity.dart';
import '../entities/tour_point_entity.dart';

abstract class TourTrackingRepository {
  Future<void> requestPermission();
  Future<void> startTracking();
  Future<void> stopTracking();
  Future<void> setTourPoints(List<TourPoint> tourPoints);
  Stream<LatLng> get locationStream;
  Stream<CheckpointHit> get checkpointStream;
}
