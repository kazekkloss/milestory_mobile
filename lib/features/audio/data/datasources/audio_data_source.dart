import 'package:injectable/injectable.dart';

import '../../../../core/core_export.dart';
import '../../audio_export.dart';

abstract class AudioDataSource {
  Future<DataState<AudioUrlData>> getAudioUrl({required String audioFileId});
}

@LazySingleton(as: AudioDataSource)
class AudioDataSourceImpl implements AudioDataSource {
  final ApiClient _apiClient;

  AudioDataSourceImpl(this._apiClient);

  @override
  Future<DataState<AudioUrlData>> getAudioUrl({required String audioFileId}) async {
    try {
      final response = await _apiClient.request(
        url: ApiConstants.getAudioUrl,
        method: RequestMethod.get,
        queryParameters: {'audioFileId': audioFileId},
      );

      if (response is DataSuccess) {
        final model = AudioUrlDataModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return DataSuccess(AudioUrlDataModel.toEntity(model));
      } else {
        return DataFailed(response.uiEvent!);
      }
    } catch (e) {
      return DataFailed(UiEvent.unexpected(e.toString()));
    }
  }
}
