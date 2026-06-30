import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/core_export.dart';
import '../../../audio/audio_export.dart';
import '../../map_export.dart';

part 'map_event.dart';
part 'map_state.dart';

@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  final GetTourPoints _getTourPoints;
  final SetTourPoints _setTourPoints;
  final TourTrackingRepository _tourTrackingRepository;
  StreamSubscription<LatLng>? _locationSubscription;
  StreamSubscription<CheckpointHit>? _checkpointSubscription;

  MapBloc({
    required this._getTourPoints,
    required this._setTourPoints,
    required this._tourTrackingRepository,
  })  : super(MapState.initial()) {
    on<GetTourPointsEvent>(_onGetTourPoints);
    on<SelectAreaEvent>(_onSelectArea);
    on<StartLocationTrackingEvent>(_onStartLocationTracking);
    on<StopLocationTrackingEvent>(_onStopLocationTracking);
    on<_UserLocationUpdatedEvent>(_onUserLocationUpdated);
    on<_CheckpointHitEvent>(_onCheckpointHit);
    on<_StreamErrorEvent>(_onStreamError);
  }

  List<Polygon<String>> _buildPolygons(
    List<TourPoint> tourPoints,
    String? selectedAreaId,
  ) {
    final polygons = <Polygon<String>>[];
    for (final tp in tourPoints) {
      for (final area in tp.areas) {
        final isSelected = area.id == selectedAreaId;
        polygons.add(Polygon<String>(
          points: area.latLng.map((p) => p.toLatLng2()).toList(),
          hitValue: area.id,
          color: isSelected
              ? Colors.orange.withValues(alpha: 0.5)
              : Colors.blue.withValues(alpha: 0.35),
          borderColor: isSelected ? Colors.orange : Colors.blue,
          borderStrokeWidth: 2,
        ));
      }
    }
    return polygons;
  }

  Future<void> _onGetTourPoints(
    GetTourPointsEvent event,
    Emitter<MapState> emit,
  ) async {
    final alreadyLoaded = state.tourPoints.isNotEmpty &&
        state.tourPoints.first.tourId == event.tourId;
    if (alreadyLoaded) return;

    emit(state.copyWith(uiEvent: null));

    final response = await _getTourPoints(tourId: event.tourId);
    if (response is DataSuccess) {
      debugPrint('[TourTracker] tour points loaded: ${response.data!.length}');
      emit(state.copyWith(
        tourPoints: response.data,
        polygons: _buildPolygons(response.data!, null),
      ));
      await _setTourPoints(response.data!);
    } else {
      emit(state.copyWith(uiEvent: response.uiEvent));
    }
  }

  void _onSelectArea(SelectAreaEvent event, Emitter<MapState> emit) {
    final newId = event.areaId == state.selectedAreaId ? null : event.areaId;
    emit(state.copyWith(
      selectedAreaId: newId,
      polygons: _buildPolygons(state.tourPoints, newId),
    ));
  }

  Future<void> _onStartLocationTracking(
    StartLocationTrackingEvent event,
    Emitter<MapState> emit,
  ) async {
    debugPrint('[TourTracker] requesting permission');
    await _tourTrackingRepository.requestPermission();
    debugPrint('[TourTracker] subscribing to streams');
    _locationSubscription = _tourTrackingRepository.locationStream.listen(
      (location) {
        debugPrint('[TourTracker] location received: ${location.latitude}, ${location.longitude}');
        add(_UserLocationUpdatedEvent(location));
      },
      onError: (e) => add(_StreamErrorEvent(e)),
    );
    _checkpointSubscription = _tourTrackingRepository.checkpointStream.listen(
      (hit) {
        debugPrint('[TourTracker] CHECKPOINT HIT — tourPoint: ${hit.tourPointId}, area: ${hit.areaId}');
        add(_CheckpointHitEvent(hit));
      },
      onError: (e) => add(_StreamErrorEvent(e)),
    );
    debugPrint('[TourTracker] startTracking');
    await _tourTrackingRepository.startTracking();
  }

  Future<void> _onStopLocationTracking(
    StopLocationTrackingEvent event,
    Emitter<MapState> emit,
  ) async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    await _checkpointSubscription?.cancel();
    _checkpointSubscription = null;
    await _tourTrackingRepository.stopTracking();
  }

  void _onUserLocationUpdated(
    _UserLocationUpdatedEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(userLocation: event.location));
  }

  Future<void> _onCheckpointHit(
    _CheckpointHitEvent event,
    Emitter<MapState> emit,
  ) async {
    debugPrint('[AudioUrl] checkpoint hit — tourPointId: ${event.hit.tourPointId}, areaId: ${event.hit.areaId}');
    final tourPoint = state.tourPoints.firstWhere(
      (tp) => tp.id.toString() == event.hit.tourPointId,
      orElse: () => throw StateError('TourPoint not found: ${event.hit.tourPointId}'),
    );

    if (state.activePoint?.id == tourPoint.id) {
      debugPrint('[TourTracker] checkpoint ignored — already active: ${tourPoint.id}');
      return;
    }

    emit(state.copyWith(activePoint: tourPoint));

    final audioFileId = tourPoint.audioFileId;
    if (audioFileId == null) {
      debugPrint('[AudioUrl] no audioFileId for tourPoint ${event.hit.tourPointId} — skipping');
      return;
    }
    debugPrint('[AudioUrl] dispatching play for audioFileId: $audioFileId');
    GetIt.I<AudioBloc>().add(PlayAudioEvent(
      audioFileId: audioFileId,
      title: tourPoint.title ?? '',
    ));
  }

  void _onStreamError(
    _StreamErrorEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      uiEvent: UiEvent(message: event.error.toString()),
    ));
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _checkpointSubscription?.cancel();
    return super.close();
  }
}
