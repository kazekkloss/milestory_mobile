import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../audio_export.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final AudioSessionManager _audioSessionManager;
  final ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: []);

  AudioPlayerHandler({required AudioSessionManager audioSessionManager})
      : _audioSessionManager = audioSessionManager {
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (_) {
      // Interruption during service startup is expected for an empty playlist
    }
    _notifyPlaybackEvents();
    _listenToPlayerState();
  }

  Future<void> loadAndPlay({
    required String url,
    required String id,
    required String title,
    required int durationMs,
  }) async {
    if (_playlist.length > 0) {
      await _playlist.clear();
      await _player.seek(Duration.zero);
    }

    final tag = MediaItem(
      id: id,
      title: title,
      duration: Duration(milliseconds: durationMs),
    );

    final source = AudioSource.uri(Uri.parse(url), tag: tag);
    mediaItem.add(tag);
    await _playlist.add(source);
    await _player.play();
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  void _notifyPlaybackEvents() {
    _player.playbackEventStream.listen((event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          if (playing) MediaControl.pause else MediaControl.play,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0],
        processingState: _mapProcessingState(_player.processingState),
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ));
    });
  }

  void _listenToPlayerState() {
    _player.playerStateStream.listen((state) async {
      final isPlaying =
          state.playing && state.processingState == ProcessingState.ready;
      if (isPlaying) {
        await _audioSessionManager.activate();
      } else {
        await _audioSessionManager.deactivate();
      }
    });
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    await _audioSessionManager.deactivate();
    await super.stop();
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await super.onTaskRemoved();
  }
}
