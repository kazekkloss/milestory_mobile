import 'package:injectable/injectable.dart';
import '../../../../core/core_export.dart';
import '../../tour_export.dart';

@LazySingleton(as: TourRepository)
class TourRepositoryImpl implements TourRepository {
  final TourDataSource tourDataSource;

  TourRepositoryImpl({required this.tourDataSource});

  @override
  Future<DataState<List<Tour>>> searchTour({required String query}) async {
    final response = await tourDataSource.searchTour(title: query);
    if (response is DataSuccess) {
      List<Tour> tours = response.data!
          .map((tour) => TourModel.toEntity(tour))
          .toList();
      return DataSuccess(tours);
    } else {
      return response;
    }
  }
}
