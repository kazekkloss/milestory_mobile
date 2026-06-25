import '../../domain/entities/area_entity.dart';
import '../../domain/entities/lat_lng_entity.dart';

class AreaModel extends Area {
  const AreaModel({
    required super.id,
    super.direction,
    required super.latLng,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: (json['_id'] ?? json['id']) as String,
      direction: (json['direction'] as num?)?.toDouble(),
      latLng: (json['latLng'] as List)
          .map((p) => LatLng(
                (p['latitude'] as num).toDouble(),
                (p['longitude'] as num).toDouble(),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'direction': direction,
      'latLng': latLng
          .map((p) => {'latitude': p.latitude, 'longitude': p.longitude})
          .toList(),
    };
  }

  static AreaModel fromEntity(Area area) {
    return AreaModel(
      id: area.id,
      direction: area.direction,
      latLng: area.latLng,
    );
  }

  static Area toEntity(AreaModel model) {
    return Area(
      id: model.id,
      direction: model.direction,
      latLng: model.latLng,
    );
  }
}
