import '../../../../core/core_export.dart';
import '../entities/audio_url_data.dart';

abstract class AudioRepository {
  Future<DataState<AudioUrlData>> getAudioUrl({required String audioFileId});
}
