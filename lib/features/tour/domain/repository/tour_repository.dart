import '../../../../core/core_export.dart';

abstract class TourRepository {
  Future<DataState<List<Tour>>> searchTour({required String query});
}
