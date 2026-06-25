import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core_export.dart';

class TourDetailScreen extends StatelessWidget {
  final Tour tour;

  const TourDetailScreen({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final horizontalPadding = SizeConfig.horizontalPadding;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: horizontalPadding),
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
                  SizedBox(height: 10),
                  Row(
                    spacing: 15,
                    children: [
                    ImageNetwork(imageUrl: tour.userOwner!.avatarUrl, width: 30, height: 30),
                    Text(tour.userOwner!.name),
                  ]),
                  SizedBox(height: 20),
                  Row(
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
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.push(
                        '/home/tour/${tour.id}/map',
                        extra: tour,
                      ),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Rozpocznij trasę'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TourImage extends StatelessWidget {
  const _TourImage({required this.tour});

  final Tour tour;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (tour.image != null) {
      return Image.memory(
        tour.image!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (tour.imageUrl != null) {
      return Image.network(
        tour.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _Placeholder(colorScheme: colorScheme),
      );
    }

    return _Placeholder(colorScheme: colorScheme);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
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
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).accent;

    return AppContainer(
      height: 100,
      width: 100,
      padding: EdgeInsets.all(0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
