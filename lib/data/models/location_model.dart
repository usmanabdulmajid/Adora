import '../../domain/entities/location_entity.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
  };

  factory LocationModel.fromMap(Map<String, dynamic> map) => LocationModel(
    latitude: map['latitude'] as double,
    longitude: map['longitude'] as double,
    timestamp: DateTime.parse(map['timestamp'] as String),
  );

  LocationEntity toEntity() => LocationEntity(
    latitude: latitude,
    longitude: longitude,
    timestamp: timestamp,
  );
}
