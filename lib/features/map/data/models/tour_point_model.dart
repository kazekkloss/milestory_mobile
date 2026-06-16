import '../../map_export.dart';

class TourPointModel extends TourPoint {
  const TourPointModel({
    required super.id,
    super.externalId,
    required super.tourId,
    required super.title,
    required super.description,
    required List<AreaModel> super.areas,
    super.audioFileId,
    super.audioFileName,
    super.audioDuration,
    super.imageUrl,
    super.imageFileName,
  });

  factory TourPointModel.fromJson(Map<String, dynamic> json) {
    return TourPointModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      externalId: json['_id'] as String?,
      tourId: json['tourId'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      areas: (json['areas'] as List)
          .map((a) => AreaModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      audioFileId: json['audioFileId'] as String?,
      audioFileName: json['audioFileName'] as String?,
      audioDuration: json['audioDuration'] as int?,
      imageUrl: json['imageUrl'] as String?,
      imageFileName: json['imageFileName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': externalId,
      'tourId': tourId,
      'title': title,
      'description': description,
      'areas': areas.map((a) => AreaModel.fromEntity(a).toJson()).toList(),
      'audioFileId': audioFileId,
      'audioFileName': audioFileName,
      'audioDuration': audioDuration,
      'imageUrl': imageUrl,
      'imageFileName': imageFileName,
    };
  }

  static TourPointModel fromEntity(TourPoint point) {
    return TourPointModel(
      id: point.id,
      externalId: point.externalId,
      tourId: point.tourId,
      title: point.title,
      description: point.description,
      areas: point.areas.map((a) => AreaModel.fromEntity(a)).toList(),
      audioFileId: point.audioFileId,
      audioFileName: point.audioFileName,
      audioDuration: point.audioDuration,
      imageUrl: point.imageUrl,
      imageFileName: point.imageFileName,
    );
  }

  static TourPoint toEntity(TourPointModel tourPointModel) {
    final List<Area> areas = tourPointModel.areas
        .map((area) => AreaModel.toEntity(AreaModel.fromEntity(area)))
        .toList();
    return TourPoint(
      id: tourPointModel.id,
      externalId: tourPointModel.externalId,
      tourId: tourPointModel.tourId,
      title: tourPointModel.title,
      description: tourPointModel.description,
      areas: areas,
      audioFileId: tourPointModel.audioFileId,
      audioFileName: tourPointModel.audioFileName,
      audioDuration: tourPointModel.audioDuration,
      imageUrl: tourPointModel.imageUrl,
      imageFileName: tourPointModel.imageFileName,
    );
  }
}
