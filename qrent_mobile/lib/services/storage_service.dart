import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class StorageService {
  static const String _keyToken = 'qrent_jwt_token';
  static const String _keyStudentId = 'qrent_student_id';
  static const String _keyRememberMe = 'qrent_remember_me';
  static const String _keyUserData = 'qrent_user_data';
  static const String _keyCachedLoans = 'qrent_cached_loans';

  // Save Auth Session
  static Future<void> saveAuthSession({
    required String token,
    required UserModel user,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyStudentId, user.studentId);
    await prefs.setBool(_keyRememberMe, rememberMe);
    await prefs.setString(_keyUserData, jsonEncode(user.toJson()));
  }

  // Get Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Get Saved Student ID
  static Future<String?> getSavedStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStudentId);
  }

  // Get Remember Me Status
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  // Get Cached User Data
  static Future<UserModel?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUserData);
    if (raw != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(raw);
        return UserModel.fromJson(decoded);
      } catch (_) {}
    }
    return null;
  }

  // Cache Active Loans (Offline feature requirement)
  static Future<void> cacheActiveLoans(List<TransactionModel> loans) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> rawList = loans.map((l) => {
      'transaction_id': l.transactionId,
      'equipment_id': l.equipmentId,
      'equipment_name': l.equipmentName,
      'description': l.description,
      'image_url': l.imageUrl,
      'location_name': l.locationName,
      'borrow_date': l.borrowDate.toIso8601String(),
      'due_date': l.dueDate.toIso8601String(),
      'status': l.status,
    }).toList();
    await prefs.setString(_keyCachedLoans, jsonEncode(rawList));
  }

  // Get Cached Active Loans (Offline fallback)
  static Future<List<TransactionModel>> getCachedLoans() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCachedLoans);
    if (raw != null) {
      try {
        final List<dynamic> decoded = jsonDecode(raw);
        return decoded.map((item) => TransactionModel.fromJson(item as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    return [];
  }

  // Clear Session (Logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_keyRememberMe) ?? false;
    final savedId = prefs.getString(_keyStudentId);

    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserData);
    await prefs.remove(_keyCachedLoans);

    if (!remember) {
      await prefs.remove(_keyStudentId);
      await prefs.remove(_keyRememberMe);
    } else if (savedId != null) {
      await prefs.setString(_keyStudentId, savedId);
      await prefs.setBool(_keyRememberMe, true);
    }
  }
}
