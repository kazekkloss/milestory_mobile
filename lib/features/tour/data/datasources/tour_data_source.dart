import 'package:injectable/injectable.dart';

import '../../../../core/core_export.dart';

abstract class TourDataSource {
  Future<DataState<List<TourModel>>> searchTour({required String title});
}

@LazySingleton(as: TourDataSource)
class TourDataSourceImpl implements TourDataSource {
  final ApiClient apiClient;

  TourDataSourceImpl(this.apiClient);

  @override
  Future<DataState<List<TourModel>>> searchTour({required String title}) async {
    try {
      final response = await apiClient.request(
        url: '${ApiConstants.getToursByTitle}?title=$title',
        method: RequestMethod.get,
      );

      if (response is DataSuccess) {
        List<TourModel> roads = (response.data['tours'] as List)
            .map((roadJson) => TourModel.fromJson(roadJson))
            .toList();
        return DataSuccess(roads);
      } else {
        return DataFailed(response.uiEvent!);
      }
    } catch (e) {
      return DataFailed(UiEvent(message: e.toString()));
    }
  }
}
