import '../../../../core/core_export.dart';
import '../entities/checkpoint_hit.dart';

abstract class TourTrackingRepository {
  Future<void> requestPermission();
  Future<void> startTracking();
  Future<void> stopTracking();
  Future<void> setTourPoints(List<TourPoint> tourPoints);
  Stream<LatLng> get locationStream;
  Stream<CheckpointHit> get checkpointStream;
}
