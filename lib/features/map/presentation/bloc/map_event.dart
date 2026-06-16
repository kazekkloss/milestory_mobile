part of 'map_bloc.dart';

sealed class MapEvent extends Equatable {}

class GetTourPointsEvent extends MapEvent {
  final String tourId;
  GetTourPointsEvent({required this.tourId});

  @override
  List<Object?> get props => [tourId];
}
