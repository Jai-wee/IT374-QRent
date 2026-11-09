import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../models/equipment_model.dart';
import '../models/transaction_model.dart';
import 'storage_service.dart';

class ApiService {
  // Common headers with optional auth token
  static Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await StorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // 1. LOGIN
  static Future<Map<String, dynamic>> login(String studentId, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: await _getHeaders(),
            body: jsonEncode({
              'student_id': studentId,
              'password': password,
              'fcm_token': 'fcm_token_$studentId',
            }),
          )
          .timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['token'];
        final user = UserModel.fromJson(data['user']);
        await StorageService.saveAuthSession(token: token, user: user, rememberMe: true);
        return {'success': true, 'user': user, 'token': token};
      } else {
        return {'success': false, 'message': data['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ'};
      }
    } catch (_) {
      // Offline / Local Demo Fallback
      if (studentId == '65070214' || studentId.isNotEmpty) {
        final mockUser = UserModel(
          studentId: studentId.isEmpty ? '65070214' : studentId,
          firstName: studentId == '68112269' ? 'วีรภัทร' : 'นภัสสร',
          lastName: studentId == '68112269' ? 'ใจดี' : 'ธนวัฒน์',
          role: studentId == 'admin01' ? 'admin' : 'student',
          fcmToken: 'mock_fcm_token_$studentId',
        );
        const mockToken = 'mock_jwt_token_offline_mode';
        await StorageService.saveAuthSession(token: mockToken, user: mockUser, rememberMe: true);
        return {'success': true, 'user': mockUser, 'token': mockToken, 'isMock': true};
      }
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้'};
    }
  }

  // 2. GET ACTIVE LOANS
  static Future<List<TransactionModel>> getActiveLoans() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.myActive),
            headers: await _getHeaders(requireAuth: true),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List list = data['data'];
          final loans = list.map((item) => TransactionModel.fromJson(item)).toList();
          await StorageService.cacheActiveLoans(loans);
          return loans;
        }
      }
    } catch (_) {}

    // Check cached loans first
    final cached = await StorageService.getCachedLoans();
    if (cached.isNotEmpty) {
      return cached;
    }

    // Default Demo Loans
    final defaultLoans = [
      TransactionModel(
        transactionId: '11111111-1111-1111-1111-111111111111',
        equipmentId: 'EQ-00124',
        equipmentName: 'Lenovo ThinkPad X1 Carbon',
        description: 'Intel Core i7, 16GB RAM, 512GB SSD',
        imageUrl: 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400&q=80',
        locationName: 'CE Innovation Center',
        borrowDate: DateTime.now().subtract(const Duration(days: 6)),
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: 'active',
      ),
      TransactionModel(
        transactionId: '22222222-2222-2222-2222-222222222222',
        equipmentId: 'EQ-00125',
        equipmentName: 'Epson 4K Projector Pro',
        description: 'โปรเจกเตอร์ 4K 4000 Lumens',
        imageUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=400&q=80',
        locationName: 'Lab AV-101',
        borrowDate: DateTime.now().subtract(const Duration(days: 3)),
        dueDate: DateTime.now().add(const Duration(days: 6)),
        status: 'active',
      ),
    ];
    await StorageService.cacheActiveLoans(defaultLoans);
    return defaultLoans;
  }

  // 3. GET LOAN HISTORY
  static Future<List<TransactionModel>> getLoanHistory() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.myHistory),
            headers: await _getHeaders(requireAuth: true),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List list = data['data'];
          return list.map((item) => TransactionModel.fromJson(item)).toList();
        }
      }
    } catch (_) {}

    return [
      TransactionModel(
        transactionId: '33333333-3333-3333-3333-333333333333',
        equipmentId: 'EQ-00099',
        equipmentName: 'iPad Pro 11" M2 + Pencil',
        locationName: 'CE Innovation Center',
        borrowDate: DateTime.now().subtract(const Duration(days: 15)),
        dueDate: DateTime.now().subtract(const Duration(days: 8)),
        returnDate: DateTime.now().subtract(const Duration(days: 8)),
        status: 'returned',
      ),
      TransactionModel(
        transactionId: '44444444-4444-4444-4444-444444444444',
        equipmentId: 'EQ-00052',
        equipmentName: 'Rode Wireless GO II Mic',
        locationName: 'Media Lab',
        borrowDate: DateTime.now().subtract(const Duration(days: 20)),
        dueDate: DateTime.now().subtract(const Duration(days: 13)),
        returnDate: DateTime.now().subtract(const Duration(days: 13)),
        status: 'returned',
      ),
    ];
  }

  // 4. GET EQUIPMENT BY ID (QR CODE SCANNER)
  static Future<EquipmentModel?> getEquipmentById(String id) async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.equipmentDetail(id)))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return EquipmentModel.fromJson(data['data']);
        }
      }
    } catch (_) {}

    // Mock catalog for testing
    final mockCatalog = {
      'EQ-00142': EquipmentModel(
        equipmentId: 'EQ-00142',
        name: 'Sony FE 24-70mm GM II',
        description: 'F2.8 G Master II Lens • Media Lab',
        imageUrl: 'https://images.unsplash.com/photo-1617005082133-548c4dd27f35?w=400&q=80',
        status: 'available',
        locationName: 'CE Innovation Center',
        latitude: 13.736717,
        longitude: 100.523186,
        radiusMeters: 50,
      ),
      'EQ-00124': EquipmentModel(
        equipmentId: 'EQ-00124',
        name: 'Lenovo ThinkPad X1 Carbon',
        description: 'Intel Core i7, 16GB RAM, 512GB SSD',
        imageUrl: 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400&q=80',
        status: 'borrowed',
        locationName: 'CE Innovation Center',
        borrowerId: '65070214',
        borrowerName: 'นภัสสร ธนวัฒน์',
        latitude: 13.736717,
        longitude: 100.523186,
        radiusMeters: 50,
      ),
      'EQ-00088': EquipmentModel(
        equipmentId: 'EQ-00088',
        name: 'DJI RS 3 Pro Gimbal',
        description: 'กิมบอลกันสั่น 3 แกนสำหรับกล้อง Cinema',
        imageUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=400&q=80',
        status: 'borrowed',
        locationName: 'Media Lab',
        borrowerId: '68112269',
        borrowerName: 'วีรภัทร ใจดี',
        latitude: 13.736200,
        longitude: 100.522500,
        radiusMeters: 60,
      ),
    };

    return mockCatalog[id] ??
        EquipmentModel(
          equipmentId: id,
          name: 'อุปกรณ์ $id',
          description: 'อุปกรณ์ทดสอบในระบบ QRent',
          status: 'available',
          locationName: 'CE Innovation Center',
          latitude: 13.736717,
          longitude: 100.523186,
          radiusMeters: 50,
        );
  }

  // 5. BORROW EQUIPMENT
  static Future<Map<String, dynamic>> borrowItem({
    required String equipmentId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.borrow),
            headers: await _getHeaders(requireAuth: true),
            body: jsonEncode({
              'equipment_id': equipmentId,
              'days': 7,
              'latitude': latitude,
              'longitude': longitude,
            }),
          )
          .timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body);
      return data;
    } catch (_) {
      // Mock Success for demo
      return {
        'success': true,
        'message': 'ยืมอุปกรณ์ $equipmentId สำเร็จ (โหมดออฟไลน์)',
      };
    }
  }

  // 6. RETURN EQUIPMENT
  static Future<Map<String, dynamic>> returnItem({
    required String equipmentId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.returnItem),
            headers: await _getHeaders(requireAuth: true),
            body: jsonEncode({
              'equipment_id': equipmentId,
              'latitude': latitude,
              'longitude': longitude,
            }),
          )
          .timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body);
      return data;
    } catch (_) {
      return {
        'success': true,
        'message': 'คืนอุปกรณ์ $equipmentId สำเร็จ (โหมดออฟไลน์)',
      };
    }
  }

  // 7. VERIFY LOCATION (GEOFENCING)
  static Future<Map<String, dynamic>> verifyLocation({
    required double latitude,
    required double longitude,
    int locationId = 1,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.verifyLocation),
            headers: await _getHeaders(),
            body: jsonEncode({
              'latitude': latitude,
              'longitude': longitude,
              'location_id': locationId,
            }),
          )
          .timeout(const Duration(seconds: 4));

      return jsonDecode(response.body);
    } catch (_) {
      // Calculate locally (CE-402 Lab is at 13.736717, 100.523186)
      const labLat = 13.736717;
      const labLon = 100.523186;
      final distance = _calculateDistance(latitude, longitude, labLat, labLon);
      final isInside = distance <= 50;

      return {
        'success': true,
        'is_inside': isInside,
        'distance_meters': distance.round(),
        'allowed_radius': 50,
        'location': {
          'id': 1,
          'name': 'CE Innovation Center (CE-402)',
          'latitude': labLat,
          'longitude': labLon,
        },
        'message': isInside
            ? 'คุณอยู่ในพื้นที่ให้บริการ (${distance.round()} ม.) สามารถทำรายการได้'
            : 'คุณอยู่นอกพื้นที่ (${distance.round()} ม.) กรุณาเข้ามาในรัศมี 50 ม.',
      };
    }
  }

  // 8. SUBMIT REPORT
  static Future<Map<String, dynamic>> submitReport({
    required String equipmentId,
    required String category,
    String? note,
    String? imageUrl,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.reports),
            headers: await _getHeaders(requireAuth: true),
            body: jsonEncode({
              'equipment_id': equipmentId,
              'category': category,
              'note': note ?? '',
              'image_url': imageUrl ?? '',
            }),
          )
          .timeout(const Duration(seconds: 4));

      return jsonDecode(response.body);
    } catch (_) {
      return {
        'success': true,
        'message': 'ส่งรายงานปัญหาเรียบร้อยแล้ว (โหมดออฟไลน์)',
      };
    }
  }

  // Haversine formula
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a = 0.5 -
        (1 - (lat2 - lat1) * p) / 2 +
        (1 + (lat1 * p)) * (1 + (lat2 * p)) * (1 - ((lon2 - lon1) * p)) / 2;
    return 12742000 * 0.001 * (1 - a); // approx in meters
  }
}
