import 'package:injectable/injectable.dart';

import '../../../../core/core_export.dart';
import '../../tour_export.dart';

@lazySingleton
class SearchTour {
  final TourRepository repository;

  SearchTour(this.repository);

  Future<DataState<List<Tour>>> call({required String query}) async {
    return await repository.searchTour(query: query);
  }
}
