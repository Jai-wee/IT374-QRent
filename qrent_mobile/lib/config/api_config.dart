import 'package:flutter/foundation.dart';

class ApiConfig {
  // Use 10.0.2.2 for Android Emulator, localhost for Windows/Web, or your machine's LAN IP for real devices
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // 10.0.2.2 points to host machine from Android Emulator
      return 'http://10.0.2.2:5000/api';
    } else {
      return 'http://localhost:5000/api';
    }
  }

  // Auth endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get profile => '$baseUrl/auth/me';
  static String get fcmToken => '$baseUrl/auth/fcm-token';

  // Equipment endpoints
  static String get equipments => '$baseUrl/equipments';
  static String equipmentDetail(String id) => '$baseUrl/equipments/$id';

  // Transaction endpoints
  static String get borrow => '$baseUrl/transactions/borrow';
  static String get returnItem => '$baseUrl/transactions/return';
  static String get myActive => '$baseUrl/transactions/my-active';
  static String get myHistory => '$baseUrl/transactions/my-history';

  // Location endpoints
  static String get locations => '$baseUrl/locations';
  static String get verifyLocation => '$baseUrl/locations/verify';

  // Report endpoints
  static String get reports => '$baseUrl/reports';
}
