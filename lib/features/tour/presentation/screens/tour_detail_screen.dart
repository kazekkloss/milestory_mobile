import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core_export.dart';
import '../../../map/presentation/widgets/tour_points_section.dart';

class TourDetailScreen extends StatefulWidget {
  final Tour tour;

  const TourDetailScreen({super.key, required this.tour});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final horizontalPadding = SizeConfig.horizontalPadding;
    final tour = widget.tour;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/home/tour/${tour.id}/map', extra: tour),
        child: const Icon(Icons.play_arrow_rounded),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              actionsPadding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              expandedHeight: 280,
              pinned: true,
              stretch: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  onPressed: () => setState(() => _isSaved = !_isSaved),
                  icon: Icon(
                    _isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
                title: Text(
                  tour.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    _TourImage(tour: tour),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black,
                            Color(0x99000000),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.30, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    if (tour.userOwner != null)
                      Row(
                        spacing: 15,
                        children: [
                          ImageNetwork(
                            imageUrl: tour.userOwner!.avatarUrl,
                            width: 30,
                            height: 30,
                          ),
                          Text(tour.userOwner!.name),
                        ],
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _InfoChip(
                          icon: TransportModeData.mapRouteEnumToIcon(
                            tour.transportMode,
                          ).icon!,
                          label: TransportModeData.mapRouteEnumToString(
                            tour.transportMode,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          icon: Icons.place_outlined,
                          label: '${tour.pointLength} punktów',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Opis',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(tour.description, style: theme.textTheme.bodyMedium),
                    if (tour.createdAt != null) ...[
                      const SizedBox(height: 20),
                      _DateRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Dodano',
                        date: tour.createdAt!,
                      ),
                    ],
                    if (tour.updatedAt != null) ...[
                      const SizedBox(height: 6),
                      _DateRow(
                        icon: Icons.update_outlined,
                        label: 'Zaktualizowano',
                        date: tour.updatedAt!,
                      ),
                    ],
                    const SizedBox(height: 32),
                    TourPointsSection(tourId: tour.id!),
                    const SizedBox(height: 88),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourImage extends StatelessWidget {
  const _TourImage({required this.tour});

  final Tour tour;

  @override
  Widget build(BuildContext context) {
    if (tour.image != null) {
      return Image.memory(tour.image!, fit: BoxFit.cover);
    }

    if (tour.imageUrl != null) {
      return Image.network(
        tour.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _Placeholder(),
      );
    }

    return const _Placeholder();
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.landscape_outlined,
          size: 64,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).accent;

    return AppContainer(
      height: 100,
      width: 100,
      padding: EdgeInsets.zero,
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 22, color: accent),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.icon, required this.label, required this.date});

  final IconData icon;
  final String label;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
