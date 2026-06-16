import 'package:injectable/injectable.dart';
import 'package:milestory_mobile/core/error/response.dart';
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
