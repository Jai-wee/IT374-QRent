class LocationModel {
  final int locationId;
  final String name;
  final double latitude;
  final double longitude;
  final int radiusMeters;

  LocationModel({
    required this.locationId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      locationId: int.tryParse(json['location_id']?.toString() ?? '1') ?? 1,
      name: json['name']?.toString() ?? 'ห้องแล็บ',
      latitude: double.tryParse(json['latitude']?.toString() ?? '13.736717') ?? 13.736717,
      longitude: double.tryParse(json['longitude']?.toString() ?? '100.523186') ?? 100.523186,
      radiusMeters: int.tryParse(json['radius_meters']?.toString() ?? '50') ?? 50,
    );
  }
}
