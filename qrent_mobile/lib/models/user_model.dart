class UserModel {
  final String studentId;
  final String firstName;
  final String lastName;
  final String role;
  final String? fcmToken;

  UserModel({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.fcmToken,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      studentId: json['student_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'student',
      fcmToken: json['fcm_token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'fcm_token': fcmToken,
    };
  }
}
