import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll2;

import '../../../../core/core_export.dart';
import '../../map_export.dart';

class TourMapScreen extends StatefulWidget {
  final Tour tour;

  const TourMapScreen({super.key, required this.tour});

  @override
  State<TourMapScreen> createState() => _TourMapScreenState();
}

class _TourMapScreenState extends State<TourMapScreen> {
  late MapBloc _bloc;
  final _mapController = MapController();
  final _hitNotifier = LayerHitNotifier<String>(null);
  bool _isFollowing = true;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<MapBloc>();
    _bloc.add(GetTourPointsEvent(tourId: widget.tour.id!));
  }

  @override
  void dispose() {
    _bloc.add(StopLocationTrackingEvent());
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['MAPTILER_API_KEY'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(widget.tour.title)),
      body: MultiBlocListener(
        listeners: [
          BlocListener<MapBloc, MapState>(
            listenWhen: (prev, curr) =>
                prev.tourPoints.isEmpty && curr.tourPoints.isNotEmpty,
            listener: (_, _) => _bloc.add(StartLocationTrackingEvent()),
          ),
          BlocListener<MapBloc, MapState>(
            listenWhen: (prev, curr) =>
                curr.userLocation != null &&
                prev.userLocation != curr.userLocation,
            listener: (_, state) {
              if (_isFollowing) {
                _mapController.move(
                  state.userLocation!.toLatLng2(),
                  _mapController.camera.zoom,
                );
              }
            },
          ),
        ],
        child: GlobalErrorListener(
          child: Stack(
            children: [
              BlocBuilder<MapBloc, MapState>(
                builder: (context, state) => FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const ll2.LatLng(50.091506, 20.010941),
                    initialZoom: 13,
                    onPositionChanged: (_, hasGesture) {
                      if (hasGesture && _isFollowing) {
                        setState(() => _isFollowing = false);
                      }
                    },
                    onTap: (_, _) {
                      final hit = _hitNotifier.value;
                      if (hit != null && hit.hitValues.isNotEmpty) {
                        _bloc.add(SelectAreaEvent(areaId: hit.hitValues.first));
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$apiKey',
                    ),
                    PolygonLayer<String>(
                      polygons: state.polygons,
                      hitNotifier: _hitNotifier,
                    ),
                    if (state.userLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: state.userLocation!.toLatLng2(),
                            width: 20,
                            height: 20,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isFollowing)
                        FloatingActionButton.small(
                          heroTag: 'follow',
                          onPressed: () => setState(() => _isFollowing = true),
                          child: const Icon(Icons.my_location),
                        ),
                      if (!_isFollowing) const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_in',
                        onPressed: () => _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        ),
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        onPressed: () => _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        ),
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
