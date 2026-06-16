import 'package:injectable/injectable.dart';

import '../../../../core/core_export.dart';
import '../../map_export.dart';

@LazySingleton(as: MapRepository)
class MapRepositoryImpl implements MapRepository {
  final MapDataSource mapDataSource;

  MapRepositoryImpl({required this.mapDataSource});

  @override
  Future<DataState<List<TourPoint>>> getTourPoints(
      {required String tourId}) async {
    final response = await mapDataSource.getTourPoints(tourId: tourId);
    if (response is DataSuccess) {
      List<TourPoint> tourPoints =
          response.data!.map((road) => TourPointModel.toEntity(road)).toList();
      return DataSuccess(tourPoints);
    } else {
      return response;
    }
  }
}