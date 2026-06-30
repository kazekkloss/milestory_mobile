part of 'map_bloc.dart';

class MapState extends Equatable {
  final List<TourPoint> tourPoints;
  final List<Polygon<String>> polygons;
  final String? selectedAreaId;
  final LatLng? userLocation;
  final UiEvent? uiEvent;
  final TourPoint? activePoint;

  const MapState({
    required this.tourPoints,
    required this.polygons,
    this.selectedAreaId,
    this.userLocation,
    this.uiEvent,
    this.activePoint,
  });

  MapState copyWith({
    List<TourPoint>? tourPoints,
    List<Polygon<String>>? polygons,
    Object? selectedAreaId = _undefined,
    Object? userLocation = _undefined,
    Object? uiEvent = _undefined,
    Object? activePoint = _undefined,
  }) {
    return MapState(
      tourPoints: tourPoints ?? this.tourPoints,
      polygons: polygons ?? this.polygons,
      selectedAreaId: selectedAreaId == _undefined ? this.selectedAreaId : selectedAreaId as String?,
      userLocation: userLocation == _undefined ? this.userLocation : userLocation as LatLng?,
      uiEvent: uiEvent == _undefined ? this.uiEvent : uiEvent as UiEvent?,
      activePoint: activePoint == _undefined ? this.activePoint : activePoint as TourPoint?,
    );
  }

  static const _undefined = Object();

  factory MapState.initial() => const MapState(tourPoints: [], polygons: []);

  @override
  List<Object?> get props => [tourPoints, polygons, selectedAreaId, userLocation, uiEvent, activePoint];
}
