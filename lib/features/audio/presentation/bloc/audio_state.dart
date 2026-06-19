part of 'audio_bloc.dart';

enum AudioStatus { idle, loading, playing, paused, completed, error }

class AudioState extends Equatable {
  final AudioStatus status;
  final String? currentAudioFileId;
  final Duration position;
  final Duration duration;
  final UiEvent? error;

  const AudioState({
    this.status = AudioStatus.idle,
    this.currentAudioFileId,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.error,
  });

  bool get isPlaying => status == AudioStatus.playing;
  bool get isLoading => status == AudioStatus.loading;

  AudioState copyWith({
    AudioStatus? status,
    Object? currentAudioFileId = _undefined,
    Duration? position,
    Duration? duration,
    Object? error = _undefined,
  }) {
    return AudioState(
      status: status ?? this.status,
      currentAudioFileId: currentAudioFileId == _undefined
          ? this.currentAudioFileId
          : currentAudioFileId as String?,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      error: error == _undefined ? this.error : error as UiEvent?,
    );
  }

  static const _undefined = Object();

  @override
  List<Object?> get props =>
      [status, currentAudioFileId, position, duration, error];
}
