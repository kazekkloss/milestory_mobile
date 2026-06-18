part of 'map_bloc.dart';

sealed class MapEvent extends Equatable {}

class GetTourPointsEvent extends MapEvent {
  final String tourId;
  GetTourPointsEvent({required this.tourId});

  @override
  List<Object?> get props => [tourId];
}

class SelectAreaEvent extends MapEvent {
  final String areaId;
  SelectAreaEvent({required this.areaId});

  @override
  List<Object?> get props => [areaId];
}

class StartLocationTrackingEvent extends MapEvent {
  @override
  List<Object?> get props => [];
}

class StopLocationTrackingEvent extends MapEvent {
  @override
  List<Object?> get props => [];
}

class _UserLocationUpdatedEvent extends MapEvent {
  final LatLng location;
  _UserLocationUpdatedEvent(this.location);

  @override
  List<Object?> get props => [location];
}

class _CheckpointHitEvent extends MapEvent {
  final CheckpointHit hit;
  _CheckpointHitEvent(this.hit);

  @override
  List<Object?> get props => [hit];
}

class _StreamErrorEvent extends MapEvent {
  final Object error;
  _StreamErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}
