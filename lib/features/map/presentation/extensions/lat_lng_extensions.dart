import 'package:latlong2/latlong.dart' as ll2;
import '../../../../core/domain/entities/lat_lng_entity.dart';

extension LatLngToMap on LatLng {
  ll2.LatLng toLatLng2() => ll2.LatLng(latitude, longitude);

  Map<String, double> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

extension LatLng2ToDomain on ll2.LatLng {
  LatLng toDomain() => LatLng(latitude, longitude);
}