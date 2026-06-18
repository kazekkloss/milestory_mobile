import 'package:equatable/equatable.dart';

class CheckpointHit extends Equatable {
  final String tourPointId;
  final String areaId;

  const CheckpointHit({required this.tourPointId, required this.areaId});

  @override
  List<Object?> get props => [tourPointId, areaId];
}
