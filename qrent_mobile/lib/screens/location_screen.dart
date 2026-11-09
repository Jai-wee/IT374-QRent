import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/api_service.dart';

class LocationScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const LocationScreen({super.key, this.onNavigate});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _isInside = true;
  int _distance = 18;

  Future<void> _testLocation(bool inside) async {

    // Simulated coordinates: inside vs outside
    final lat = inside ? 13.736717 : 13.740500;
    final lon = inside ? 100.523186 : 100.528000;

    final result = await ApiService.verifyLocation(
      latitude: lat,
      longitude: lon,
    );

    if (mounted) {
      setState(() {
        _isInside = result['is_inside'] ?? inside;
        _distance = result['distance_meters'] ?? (inside ? 18 : 420);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'ตรวจสอบพิกัดสำเร็จ'),
          backgroundColor: _isInside ? AppTheme.success : AppTheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตรวจสอบพิกัดห้องแล็บ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onNavigate != null) widget.onNavigate!(0);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ActionChip(
              backgroundColor: AppTheme.primaryFixed,
              label: const Text(
                'รีเฟรช GPS',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 11),
              ),
              onPressed: () => _testLocation(_isInside),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Stylized Map Card
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.surfaceContainer),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Stack(
                children: [
                  // Stylized Grid pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                        ),
                        itemCount: 24,
                        itemBuilder: (context, index) => Container(
                          decoration: BoxDecoration(border: Border.all(color: AppTheme.primary, width: 0.5)),
                        ),
                      ),
                    ),
                  ),

                  // Geofence Circle Overlay
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        border: Border.all(
                          color: _isInside ? AppTheme.primary : AppTheme.error,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // Center Lab Pin
                  Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: const Icon(Icons.corporate_fare, color: Colors.white, size: 22),
                    ),
                  ),

                  // User Pin (animates position inside or outside)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    top: _isInside ? 85 : 20,
                    right: _isInside ? 95 : 25,
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _isInside ? AppTheme.success : AppTheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6),
                            ],
                          ),
                          child: const Icon(Icons.person_pin, color: Colors.white, size: 18),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('คุณ', style: TextStyle(color: Colors.white, fontSize: 8)),
                        ),
                      ],
                    ),
                  ),

                  // Map Info Badge (bottom left)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _isInside ? AppTheme.success : AppTheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_distance ม. จากจุดบริการ',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. GPS Tester Switcher
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.surfaceContainer),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tune, color: AppTheme.primary, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'จำลองพิกัด GPS สำหรับทดสอบ',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        Text(
                          'แตะเพื่อทดสอบเงื่อนไข',
                          style: TextStyle(fontSize: 10, color: AppTheme.outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // In Geofence Button
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _testLocation(true),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isInside ? AppTheme.successBg : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isInside ? AppTheme.success : AppTheme.surfaceContainer,
                                  width: _isInside ? 1.5 : 1,
                                ),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.check_circle, color: AppTheme.success, size: 22),
                                  SizedBox(height: 4),
                                  Text(
                                    'อยู่ในพื้นที่ (18 ม.)',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'ทำรายการได้',
                                    style: TextStyle(fontSize: 10, color: AppTheme.outline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Outside Geofence Button
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _testLocation(false),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: !_isInside ? const Color(0xFFFFE4E6) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !_isInside ? AppTheme.error : AppTheme.surfaceContainer,
                                  width: !_isInside ? 1.5 : 1,
                                ),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.cancel, color: AppTheme.error, size: 22),
                                  SizedBox(height: 4),
                                  Text(
                                    'นอกพื้นที่ (420 ม.)',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'ระบบจะระงับ',
                                    style: TextStyle(fontSize: 10, color: AppTheme.outline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 3. Lab Service Details Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.surfaceContainer),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'รายละเอียดจุดบริการ',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.outline),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ห้องแล็บ:', style: TextStyle(fontSize: 12, color: AppTheme.outline)),
                        Text('CE Innovation Center (CE-402)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('รัศมีบริการ:', style: TextStyle(fontSize: 12, color: AppTheme.outline)),
                        Text('50 เมตร (Geofence)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      ],
                    ),
                    Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('เวลาทำการ:', style: TextStyle(fontSize: 12, color: AppTheme.outline)),
                        Text('จันทร์ - ศุกร์ (08:30 - 17:30 น.)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.success)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 4. Quick Action Button to QR Scanner
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  if (widget.onNavigate != null) widget.onNavigate!(1);
                },
                icon: const Icon(Icons.qr_code_scanner, size: 20),
                label: const Text('ไปยังหน้าสแกน QR Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
