import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milestory_mobile/features/map/map_export.dart';

import '../../../../core/core_export.dart';
import '../../../audio/audio_export.dart';
import '../bloc/map_bloc.dart';

class MapBottomSheet extends StatefulWidget {
  const MapBottomSheet({super.key});

  @override
  State<MapBottomSheet> createState() => _MapBottomSheetState();
}

class _MapBottomSheetState extends State<MapBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isAutoMode = true;
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  static const _radius = BorderRadius.vertical(top: Radius.circular(20));
  // drag handle (~24px) + player row (~72px) + padding bottom (16px)
  static const _kPlayerHeight = 120.0;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onHandleTap() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
        _isAutoMode = true;
      });
      return;
    }

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
                            title:
                                point?.title ?? 'Udaj się do obszaru na mapie',
                          ),
                        ),

                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Opis'),
                            Tab(text: 'Lista'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _DescriptionTab(point: point),
                              SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SizeConfig.horizontalPadding,
                                  vertical: 25,
                                ),
                                child: const TourPointsSection(),
                              ),
                            ],
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

class _DescriptionTab extends StatelessWidget {
  const _DescriptionTab({required this.point});

  final TourPoint? point;

  static String _areaLabel(int count) {
    if (count == 1) return '1 obszar';
    final lastDigit = count % 10;
    final lastTwoDigits = count % 100;
    if (lastDigit >= 2 &&
        lastDigit <= 4 &&
        !(lastTwoDigits >= 12 && lastTwoDigits <= 14)) {
      return '$count obszary';
    }
    return '$count obszarów';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final areaCount = point?.areas.length ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: SizeConfig.horizontalPadding,
        vertical: 25,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ImageNetwork(
                  imageUrl: point?.imageUrl,
                  width: 120,
                  height: 120,
                  borderRadius: 16,
                ),
                if (point != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.layers_outlined, size: 14, color: colors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _areaLabel(areaCount),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                point?.description ?? 'Brak opisu dla tego przystanku.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
