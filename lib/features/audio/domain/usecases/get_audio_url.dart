import 'package:injectable/injectable.dart';

import '../../../../core/core_export.dart';
import '../../audio_export.dart';

@lazySingleton
class GetAudioUrl {
  final AudioRepository _repository;

  GetAudioUrl(this._repository);

  Future<DataState<AudioUrlData>> call({required String audioFileId}) {
    return _repository.getAudioUrl(audioFileId: audioFileId);
  }
}
