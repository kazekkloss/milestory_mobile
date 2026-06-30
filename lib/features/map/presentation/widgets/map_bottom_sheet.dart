import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milestory_mobile/core/extensions/size_extensions.dart';

import '../../../audio/audio_export.dart';
import '../bloc/map_bloc.dart';

class MapBottomSheet extends StatefulWidget {
  const MapBottomSheet({super.key});

  @override
  State<MapBottomSheet> createState() => _MapBottomSheetState();
}

class _MapBottomSheetState extends State<MapBottomSheet> {
  bool _isExpanded = false;
  bool _isAutoMode = true;

  static const _radius = BorderRadius.vertical(top: Radius.circular(20));
  // drag handle (~24px) + player row (~72px) + padding bottom (16px)
  static const _kPlayerHeight = 120.0;

  void _onHandleTap() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
        _isAutoMode = true;
      });
      return;
    }

    final hasActivePoint =
        context.read<MapBloc>().state.activePoint != null;
    if (!hasActivePoint) return;

    setState(() {
      _isExpanded = true;
      _isAutoMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final expandedHeight = screenHeight * 0.5;
    final collapsedOffset = (expandedHeight - _kPlayerHeight) / expandedHeight;

    return BlocListener<AudioBloc, AudioState>(
      listenWhen: (prev, curr) =>
          (prev.currentAudioFileId == null) !=
          (curr.currentAudioFileId == null),
      listener: (context, state) {
        if (!_isAutoMode) return;
        setState(() => _isExpanded = state.currentAudioFileId != null);
      },
      child: BlocBuilder<MapBloc, MapState>(
        buildWhen: (prev, curr) => prev.activePoint != curr.activePoint,
        builder: (context, mapState) {
          final point = mapState.activePoint;

          return Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              offset: Offset(0, _isExpanded ? 0 : collapsedOffset),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: SizedBox(
                height: expandedHeight,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: _radius,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _onHandleTap,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: SizeConfig.horizontalPadding,
                            right: SizeConfig.horizontalPadding,
                            bottom: SizeConfig.horizontalPadding,
                          ),
                          child: AudioPlayerWidget(
                            title: point?.title ??
                                'Udaj się do obszaru na mapie',
                          ),
                        ),
                        if (point?.description != null)
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.only(
                                left: SizeConfig.horizontalPadding,
                                right: SizeConfig.horizontalPadding,
                                bottom: SizeConfig.horizontalPadding,
                              ),
                              child: Text(
                                point!.description!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
