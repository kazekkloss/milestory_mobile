import 'package:injectable/injectable.dart';

import '../../../../core/core_export.dart';
import '../../audio_export.dart';

@LazySingleton(as: AudioRepository)
class AudioRepositoryImpl implements AudioRepository {
  final AudioDataSource _dataSource;

  AudioRepositoryImpl(this._dataSource);

  @override
  Future<DataState<AudioUrlData>> getAudioUrl({required String audioFileId}) {
    return _dataSource.getAudioUrl(audioFileId: audioFileId);
  }
}
