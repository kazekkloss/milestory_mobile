import 'package:injectable/injectable.dart';
import '../../../../core/core_export.dart';
import '../../map_export.dart';

@lazySingleton
class GetTourPoints {
  final MapRepository repository;

  GetTourPoints(this.repository);

  Future<DataState<List<TourPoint>>> call({required String tourId}) async {
    final response = await repository.getTourPoints(tourId: tourId);
    return response;
  }
}
