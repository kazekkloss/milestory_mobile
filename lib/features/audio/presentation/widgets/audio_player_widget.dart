import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core_export.dart';
import '../../audio_export.dart';

class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        if (state.status == AudioStatus.idle ||
            state.currentAudioFileId == null) {
          return const SizedBox.shrink();
        }
        return _AudioPlayerContent(state: state);
      },
    );
  }
}

class _AudioPlayerContent extends StatelessWidget {
  final AudioState state;

  const _AudioPlayerContent({required this.state});

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bloc = context.read<AudioBloc>();

    final totalSeconds = state.duration.inSeconds;
    final currentSeconds = state.position.inSeconds.clamp(0, totalSeconds);
    final sliderValue =
        totalSeconds > 0 ? currentSeconds / totalSeconds : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: colors.bgElevated,
        border: Border(
          top: BorderSide(color: colors.borderSubtle),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.music_note_rounded, color: colors.accent, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.currentAudioFileId ?? '',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => bloc.add(StopAudioEvent()),
                icon: Icon(Icons.close, color: colors.textMuted, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: colors.accent,
              inactiveTrackColor: colors.borderSubtle,
              thumbColor: colors.accent,
              overlayColor: colors.accentDim,
            ),
            child: Slider(
              value: sliderValue.toDouble(),
              onChanged: totalSeconds > 0
                  ? (v) => bloc.add(SeekAudioEvent(
                        Duration(seconds: (v * totalSeconds).round()),
                      ))
                  : null,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(state.position),
                style: TextStyle(color: colors.textMuted, fontSize: 11),
              ),
              _buildPlayPauseButton(context, colors, bloc),
              Text(
                _format(state.duration),
                style: TextStyle(color: colors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton(
      BuildContext context, AppColors colors, AudioBloc bloc) {
    if (state.isLoading) {
      return SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colors.accent,
        ),
      );
    }

    return IconButton(
      onPressed: () {
        if (state.isPlaying) {
          bloc.add(PauseAudioEvent());
        } else {
          bloc.add(ResumeAudioEvent());
        }
      },
      icon: Icon(
        state.isPlaying
            ? Icons.pause_rounded
            : Icons.play_arrow_rounded,
        color: colors.accent,
        size: 32,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
