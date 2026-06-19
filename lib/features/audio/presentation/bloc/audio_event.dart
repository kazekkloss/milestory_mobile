part of 'audio_bloc.dart';

sealed class AudioEvent extends Equatable {}

class PlayAudioEvent extends AudioEvent {
  final String audioFileId;
  final String title;

  PlayAudioEvent({required this.audioFileId, required this.title});

  @override
  List<Object?> get props => [audioFileId, title];
}

class PauseAudioEvent extends AudioEvent {
  @override
  List<Object?> get props => [];
}

class ResumeAudioEvent extends AudioEvent {
  @override
  List<Object?> get props => [];
}

class SeekAudioEvent extends AudioEvent {
  final Duration position;

  SeekAudioEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class StopAudioEvent extends AudioEvent {
  @override
  List<Object?> get props => [];
}

class _PositionUpdatedEvent extends AudioEvent {
  final Duration position;

  _PositionUpdatedEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class _DurationUpdatedEvent extends AudioEvent {
  final Duration duration;

  _DurationUpdatedEvent(this.duration);

  @override
  List<Object?> get props => [duration];
}

class _PlaybackCompletedEvent extends AudioEvent {
  @override
  List<Object?> get props => [];
}
