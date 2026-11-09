class EquipmentModel {
  final String equipmentId;
  final String name;
  final String? description;
  final String? imageUrl;
  final String status; // 'available', 'borrowed', 'maintenance'
  final int? locationId;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final int? radiusMeters;
  final String? borrowerId;
  final String? borrowerName;
  final DateTime? dueDate;

  EquipmentModel({
    required this.equipmentId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.status,
    this.locationId,
    this.locationName,
    this.latitude,
    this.longitude,
    this.radiusMeters,
    this.borrowerId,
    this.borrowerName,
    this.dueDate,
  });

  bool get isAvailable => status == 'available';
  bool get isBorrowed => status == 'borrowed';
  bool get isMaintenance => status == 'maintenance';

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      equipmentId: json['equipment_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      status: json['status']?.toString() ?? 'available',
      locationId: json['location_id'] != null ? int.tryParse(json['location_id'].toString()) : null,
      locationName: json['location_name']?.toString(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      radiusMeters: json['radius_meters'] != null ? int.tryParse(json['radius_meters'].toString()) : null,
      borrowerId: json['borrower_id']?.toString(),
      borrowerName: json['borrower_first_name'] != null
          ? '${json['borrower_first_name']} ${json['borrower_last_name'] ?? ''}'
          : null,
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipment_id': equipmentId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'status': status,
      'location_id': locationId,
      'location_name': locationName,
    };
  }
}
