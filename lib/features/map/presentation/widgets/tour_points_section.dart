import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core_export.dart';
import '../bloc/map_bloc.dart';

class TourPointsSection extends StatefulWidget {
  const TourPointsSection({super.key, this.tourId});

  final String? tourId;

  @override
  State<TourPointsSection> createState() => _TourPointsSectionState();
}

class _TourPointsSectionState extends State<TourPointsSection> {
  late bool _expanded = widget.tourId == null;
  int _shownCount = 3;

  void _onToggle(BuildContext context, MapState state) {
    final tourId = widget.tourId;
    if (!_expanded && tourId != null && state.tourPoints.isEmpty) {
      context.read<MapBloc>().add(GetTourPointsEvent(tourId: tourId));
    }
    setState(() {
      _expanded = !_expanded;
      if (!_expanded) _shownCount = 3;
    });
  }

  void _onShowMore() => setState(() => _shownCount += 3);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        final visibleCount = _shownCount.clamp(0, state.tourPoints.length);
        final hasMore = state.tourPoints.length > _shownCount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Punkty trasy',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.tourId != null)
                  TextButton(
                    onPressed: () => _onToggle(context, state),
                    child: Text(_expanded ? 'Zwiń' : 'Pokaż przystanki'),
                  ),
              ],
            ),
            ClipRect(
              child: AnimatedAlign(
                alignment: Alignment.topCenter,
                heightFactor: _expanded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    if (state.tourPoints.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      for (int i = 0; i < visibleCount; i++)
                        _TourPointRow(
                          index: i + 1,
                          tourPoint: state.tourPoints[i],
                          showLine: i < visibleCount - 1 || hasMore,
                        ),
                      if (hasMore) ...[
                        const SizedBox(height: 8),
                        _TourPointMoreRow(
                          count: state.tourPoints.length - _shownCount,
                          onTap: _onShowMore,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TourPointRow extends StatefulWidget {
  const _TourPointRow({
    required this.index,
    required this.tourPoint,
    required this.showLine,
  });

  final int index;
  final TourPoint tourPoint;
  final bool showLine;

  @override
  State<_TourPointRow> createState() => _TourPointRowState();
}

class _TourPointRowState extends State<_TourPointRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colors = AppColors.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _StepCircle(
                  color: _expanded
                      ? colors.accent
                      : colorScheme.surfaceContainerHighest,
                  textColor: _expanded ? colors.bg : colorScheme.onSurface,
                  label: '${widget.index}',
                  style: theme.textTheme.labelLarge,
                ),
              ),
              if (widget.showLine)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Center(
                      child: Container(
                        width: 1.5,
                        color: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: widget.showLine ? 10 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ImageNetwork(
                            imageUrl: widget.tourPoint.imageUrl,
                            height: 50,
                            width: 50,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.tourPoint.title ?? '',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 280),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (widget.tourPoint.description != null)
                        ClipRect(
                          child: AnimatedAlign(
                            alignment: Alignment.topCenter,
                            heightFactor: _expanded ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeInOut,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                              child: Text(
                                widget.tourPoint.description!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TourPointMoreRow extends StatelessWidget {
  const _TourPointMoreRow({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          _StepCircle(
            color: colorScheme.surfaceContainerHighest,
            textColor: colorScheme.onSurface,
            label: '+$count',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(width: 12),
          Text(
            'i $count kolejnych punktów',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.color,
    required this.textColor,
    required this.label,
    required this.style,
  });

  final Color color;
  final Color textColor;
  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        label,
        style: style?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
