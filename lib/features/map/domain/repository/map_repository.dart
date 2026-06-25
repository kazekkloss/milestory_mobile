import '../../../../core/core_export.dart';

abstract class MapRepository {
  Future<DataState<List<TourPoint>>> getTourPoints({required String tourId});
}