import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/core_export.dart';
import '../../audio_export.dart';

part 'audio_event.dart';
part 'audio_state.dart';

@LazySingleton()
class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final GetAudioUrl _getAudioUrl;
  final AudioPlayerHandler _audioPlayerHandler;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  AudioBloc({required GetAudioUrl getAudioUrl})
      : _getAudioUrl = getAudioUrl,
        _audioPlayerHandler = GetIt.I<AudioPlayerHandler>(),
        super(const AudioState()) {
    on<PlayAudioEvent>(_onPlay);
    on<PauseAudioEvent>(_onPause);
    on<ResumeAudioEvent>(_onResume);
    on<SeekAudioEvent>(_onSeek);
    on<StopAudioEvent>(_onStop);
    on<_PositionUpdatedEvent>(_onPositionUpdated);
    on<_DurationUpdatedEvent>(_onDurationUpdated);
    on<_PlaybackCompletedEvent>(_onPlaybackCompleted);

    _positionSubscription = _audioPlayerHandler.positionStream.listen(
      (position) => add(_PositionUpdatedEvent(position)),
    );
    _durationSubscription = _audioPlayerHandler.durationStream.listen(
      (duration) {
        if (duration != null) add(_DurationUpdatedEvent(duration));
      },
    );
    _playerStateSubscription = _audioPlayerHandler.playerStateStream.listen(
      (playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          add(_PlaybackCompletedEvent());
        }
      },
    );
  }

  Future<void> _onPlay(PlayAudioEvent event, Emitter<AudioState> emit) async {
    if (state.currentAudioFileId == event.audioFileId &&
        (state.isPlaying || state.isLoading)) {
      debugPrint('[Audio] play ignored — already playing: ${event.audioFileId}');
      return;
    }

    emit(state.copyWith(
      status: AudioStatus.loading,
      currentAudioFileId: event.audioFileId,
      position: Duration.zero,
      error: null,
    ));

    final result = await _getAudioUrl(audioFileId: event.audioFileId);

    if (result is DataSuccess<AudioUrlData>) {
      final data = result.data!;
      emit(state.copyWith(
        duration: Duration(milliseconds: data.duration),
      ));
      await _audioPlayerHandler.loadAndPlay(
        url: data.audioUrl,
        id: event.audioFileId,
        title: event.title,
        durationMs: data.duration,
      );
      emit(state.copyWith(status: AudioStatus.playing));
    } else {
      emit(state.copyWith(
        status: AudioStatus.error,
        error: result.uiEvent,
      ));
    }
  }

  Future<void> _onPause(PauseAudioEvent event, Emitter<AudioState> emit) async {
    emit(state.copyWith(status: AudioStatus.paused));
    await _audioPlayerHandler.pause();
  }

  Future<void> _onResume(ResumeAudioEvent event, Emitter<AudioState> emit) async {
    emit(state.copyWith(status: AudioStatus.playing));
    await _audioPlayerHandler.play();
  }

  Future<void> _onSeek(SeekAudioEvent event, Emitter<AudioState> emit) async {
    await _audioPlayerHandler.seek(event.position);
  }

  Future<void> _onStop(StopAudioEvent event, Emitter<AudioState> emit) async {
    await _audioPlayerHandler.stop();
    emit(const AudioState());
  }

  void _onPositionUpdated(
      _PositionUpdatedEvent event, Emitter<AudioState> emit) {
    emit(state.copyWith(position: event.position));
  }

  void _onDurationUpdated(
      _DurationUpdatedEvent event, Emitter<AudioState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  Future<void> _onPlaybackCompleted(
      _PlaybackCompletedEvent event, Emitter<AudioState> emit) async {
    await _audioPlayerHandler.stop();
    emit(const AudioState(status: AudioStatus.completed));
    emit(const AudioState());
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    return super.close();
  }
}
