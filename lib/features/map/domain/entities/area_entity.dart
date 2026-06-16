import 'package:equatable/equatable.dart';
import 'lat_lng_entity.dart';

class Area extends Equatable {
  final String id;
  final double? direction;
  final List<LatLng> latLng;

  const Area({required this.id, this.direction, required this.latLng});

  static const _undefined = Object();

  Area copyWith({
    String? id,
    Object? direction = _undefined,
    List<LatLng>? latLng,
  }) {
    return Area(
      id: id ?? this.id,
      direction: direction == _undefined
          ? this.direction
          : direction as double?,
      latLng: latLng ?? this.latLng,
    );
  }

  @override
  List<Object?> get props => [id, direction, latLng];
}
