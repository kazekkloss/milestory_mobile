part of 'map_bloc.dart';

class MapState extends Equatable {
  final List<TourPoint> tourPoints;
  final UiEvent? uiEvent;

  const MapState({required this.tourPoints, this.uiEvent});

  MapState copyWith({
    List<TourPoint>? tourPoints,
    Object? uiEvent = _undefined,
  }) {
    return MapState(
      tourPoints: tourPoints ?? this.tourPoints,
      uiEvent: uiEvent == _undefined ? this.uiEvent : uiEvent as UiEvent?,
    );
  }

  static const _undefined = Object();

  factory MapState.initial() => const MapState(tourPoints: []);

  @override
  List<Object?> get props => [tourPoints, uiEvent];
}
