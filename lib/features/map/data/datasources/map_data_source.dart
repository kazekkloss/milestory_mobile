import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/core_export.dart';
import '../../map_export.dart';

abstract class MapDataSource {
  Future<DataState<List<TourPointModel>>> getTourPoints(
      {required String tourId});
  Future<DataState<String>> getAudioUrl({required String audioFileId});
}

@LazySingleton(as: MapDataSource)
class CreatorDataSourceImpl implements MapDataSource {
  final ApiClient apiClient;

  CreatorDataSourceImpl(this.apiClient);

  @override
  Future<DataState<List<TourPointModel>>> getTourPoints(
      {required String tourId}) async {
    try {
      final response = await apiClient.request(
        url: '${ApiConstants.getTourPoints}?tourId=$tourId',
        method: RequestMethod.get,
      );

      if (response is DataSuccess) {
        List<TourPointModel> tourPoints = (response.data as List)
            .map((tourPoint) => TourPointModel.fromJson(tourPoint))
            .toList();
        return DataSuccess(tourPoints);
      } else {
        return DataFailed(response.uiEvent!);
      }
    } catch (e) {
      return DataFailed(UiEvent(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<DataState<String>> getAudioUrl({required String audioFileId}) async {
    try {
      final response = await apiClient.request(
        url: ApiConstants.getAudioUrl,
        method: RequestMethod.get,
        queryParameters: {'audioFileId': audioFileId},
      );

      if (response is DataSuccess) {
        debugPrint('[AudioUrl] raw response: ${response.data}');
        final url = response.data['url'] as String;
        return DataSuccess(url);
      } else {
        return DataFailed(response.uiEvent!);
      }
    } catch (e) {
      return DataFailed(UiEvent(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}