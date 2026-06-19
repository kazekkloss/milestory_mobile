import 'package:audio_session/audio_session.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AudioSessionManager {
  AudioSession? _session;

  Future<void> activate() async {
    _session ??= await AudioSession.instance;
    await _session!.configure(const AudioSessionConfiguration.music());
    await _session!.setActive(true);
  }

  Future<void> deactivate() async {
    _session ??= await AudioSession.instance;
    await _session!.setActive(false);
  }
}
