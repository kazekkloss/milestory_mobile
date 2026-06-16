import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core_export.dart';

class TourDetailScreen extends StatelessWidget {
  final Tour tour;

  const TourDetailScreen({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły trasy'),
      ),
      body: Center(
        child: Text(tour.title),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => context.push('/home/tour/${tour.id}/map', extra: tour),
            child: const Text('Ruszaj w drogę'),
          ),
        ),
      ),
    );
  }
}
