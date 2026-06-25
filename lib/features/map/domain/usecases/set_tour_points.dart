import 'package:injectable/injectable.dart';

import '../../../../core/core_export.dart';
import '../repository/tour_tracking_repository.dart';

@lazySingleton
class SetTourPoints {
  final TourTrackingRepository _repository;

  SetTourPoints(this._repository);

  Future<void> call(List<TourPoint> tourPoints) =>
      _repository.setTourPoints(tourPoints);
}
