import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core_export.dart';
import '../../audio_export.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({super.key, required this.title});

  final String title;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  double? _dragValue;

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        final bloc = context.read<AudioBloc>();
        final totalSeconds = state.duration.inSeconds;
        final sliderValue =
            _dragValue ??
            (totalSeconds > 0
                ? state.position.inSeconds.clamp(0, totalSeconds) / totalSeconds
                : 0.0);
        final timeColor = state.currentAudioFileId != null
            ? colors.textPrimary
            : colors.textMuted;

        return Row(
          children: [
            _PlayPauseButton(state: state, colors: colors, bloc: bloc),
            SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      activeTrackColor: colors.accent,
                      inactiveTrackColor: colors.borderSubtle,
                      thumbColor: colors.accent,
                      overlayColor: colors.accentDim,
                    ),
                    child: Slider(
                      value: sliderValue.toDouble(),
                      onChanged: totalSeconds > 0
                          ? (v) => setState(() => _dragValue = v)
                          : null,
                      onChangeEnd: totalSeconds > 0
                          ? (v) {
                              bloc.add(
                                SeekAudioEvent(
                                  Duration(
                                    seconds: (v * totalSeconds).round(),
                                  ),
                                ),
                              );
                              setState(() => _dragValue = null);
                            }
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dragValue != null
                              ? _format(
                                  Duration(
                                    seconds: (_dragValue! * totalSeconds)
                                        .round(),
                                  ),
                                )
                              : _format(state.position),
                          style: TextStyle(color: timeColor, fontSize: 11),
                        ),
                        Text(
                          _format(state.duration),
                          style: TextStyle(color: timeColor, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.state,
    required this.colors,
    required this.bloc,
  });

  final AudioState state;
  final AppColors colors;
  final AudioBloc bloc;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (state.isPlaying) {
          bloc.add(PauseAudioEvent());
        } else {
          bloc.add(ResumeAudioEvent());
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
        child: state.isLoading
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Icon(
                state.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.black,
                size: 20,
              ),
      ),
    );
  }
}
