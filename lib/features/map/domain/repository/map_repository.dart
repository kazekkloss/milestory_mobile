import '../../../../core/error/response.dart';
import '../../map_export.dart';

abstract class MapRepository {
  Future<DataState<List<TourPoint>>> getTourPoints({required String tourId});
}