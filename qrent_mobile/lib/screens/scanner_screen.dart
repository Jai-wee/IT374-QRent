import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/equipment_model.dart';
import '../services/api_service.dart';

class ScannerScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const ScannerScreen({super.key, this.onNavigate});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  bool _isFlashOn = false;
  bool _isProcessingAction = false;
  EquipmentModel? _scannedEquipment;
  late AnimationController _laserController;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Initial default scan for showcase
    _loadScannedItem('EQ-00142');
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  Future<void> _loadScannedItem(String id) async {
    final eq = await ApiService.getEquipmentById(id);
    if (mounted) {
      setState(() {
        _scannedEquipment = eq;
      });
    }
  }

  Future<void> _handleBorrow() async {
    if (_scannedEquipment == null) return;
    setState(() => _isProcessingAction = true);

    final result = await ApiService.borrowItem(
      equipmentId: _scannedEquipment!.equipmentId,
      latitude: 13.736717,
      longitude: 100.523186,
    );

    setState(() => _isProcessingAction = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.success, size: 24),
              SizedBox(width: 8),
              Text('ทำรายการยืมสำเร็จ'),
            ],
          ),
          content: Text(
            result['message'] ?? 'ยืมอุปกรณ์ ${_scannedEquipment!.name} เรียบร้อยแล้ว กำหนดส่งคืน 7 วัน',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (widget.onNavigate != null) {
                  widget.onNavigate!(0); // Back to Home
                }
              },
              child: const Text('กลับสู่หน้าหลัก'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleReturn() async {
    if (_scannedEquipment == null) return;
    setState(() => _isProcessingAction = true);

    final result = await ApiService.returnItem(
      equipmentId: _scannedEquipment!.equipmentId,
      latitude: 13.736717,
      longitude: 100.523186,
    );

    setState(() => _isProcessingAction = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.success, size: 24),
              SizedBox(width: 8),
              Text('คืนอุปกรณ์เรียบร้อย'),
            ],
          ),
          content: Text(
            result['message'] ?? 'ส่งคืนอุปกรณ์ ${_scannedEquipment!.name} เข้าสู่คลังห้องแล็บแล้ว',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (widget.onNavigate != null) {
                  widget.onNavigate!(0); // Back to Home
                }
              },
              child: const Text('กลับสู่หน้าหลัก'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.black.withValues(alpha: 0.6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (widget.onNavigate != null) widget.onNavigate!(0);
                      },
                    ),
                    const Column(
                      children: [
                        Text(
                          'สแกน QR Code อุปกรณ์',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'จัดวางรหัส QR ให้อยู่ในกรอบ',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: _isFlashOn ? Colors.amber : Colors.white,
                      ),
                      onPressed: () => setState(() => _isFlashOn = !_isFlashOn),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Camera Viewfinder & Laser Simulation
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Scanner Reticle Box
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // Corner borders
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFF22D3EE), width: 4),
                                left: BorderSide(color: Color(0xFF22D3EE), width: 4),
                              ),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFF22D3EE), width: 4),
                                right: BorderSide(color: Color(0xFF22D3EE), width: 4),
                              ),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(16)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF22D3EE), width: 4),
                                left: BorderSide(color: Color(0xFF22D3EE), width: 4),
                              ),
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF22D3EE), width: 4),
                                right: BorderSide(color: Color(0xFF22D3EE), width: 4),
                              ),
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)),
                            ),
                          ),
                        ),

                        // Center QR outline
                        const Center(
                          child: Icon(Icons.qr_code_2, size: 80, color: Colors.white12),
                        ),

                        // Animated Laser Line
                        AnimatedBuilder(
                          animation: _laserController,
                          builder: (context, child) {
                            return Positioned(
                              top: 20 + (_laserController.value * 170),
                              left: 10,
                              right: 10,
                              child: Container(
                                height: 2.5,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.transparent, Color(0xFF22D3EE), Colors.transparent],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF22D3EE).withValues(alpha: 0.8),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Testing Simulation Shortcuts
                  const Text(
                    'แตะเพื่อจำลองรหัส QR สำหรับทดสอบ:',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ActionChip(
                        backgroundColor: Colors.white12,
                        label: const Text('📷 Sony 24-70 (พร้อมยืม)', style: TextStyle(color: Colors.white, fontSize: 11)),
                        onPressed: () => _loadScannedItem('EQ-00142'),
                      ),
                      ActionChip(
                        backgroundColor: Colors.white12,
                        label: const Text('💻 ThinkPad (คืน)', style: TextStyle(color: Colors.white, fontSize: 11)),
                        onPressed: () => _loadScannedItem('EQ-00124'),
                      ),
                      ActionChip(
                        backgroundColor: Colors.white12,
                        label: const Text('🎥 Ronin RS3 (ไม่ว่าง)', style: TextStyle(color: Colors.white, fontSize: 11)),
                        onPressed: () => _loadScannedItem('EQ-00088'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Scanned Equipment Bottom Sheet
            if (_scannedEquipment != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag Handle
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Equipment Row
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _scannedEquipment!.imageUrl ?? 'https://images.unsplash.com/photo-1617005082133-548c4dd27f35?w=400&q=80',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 56,
                                height: 56,
                                color: AppTheme.surfaceContainer,
                                child: const Icon(Icons.devices, color: AppTheme.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _scannedEquipment!.equipmentId,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _scannedEquipment!.isAvailable
                                            ? AppTheme.successBg
                                            : const Color(0xFFDBEAFE),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        _scannedEquipment!.isAvailable ? 'พร้อมให้ยืม' : 'กำลังถูกยืม',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: _scannedEquipment!.isAvailable
                                              ? AppTheme.success
                                              : const Color(0xFF1D4ED8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _scannedEquipment!.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _scannedEquipment!.description ?? 'CE Innovation Center',
                                  style: const TextStyle(fontSize: 10, color: AppTheme.outline),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Geofence Strip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.surfaceContainer),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.verified, size: 16, color: AppTheme.success),
                                SizedBox(width: 6),
                                Text(
                                  'อยู่ในรัศมีบริการห้องแล็บ (18 ม.)',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                if (widget.onNavigate != null) widget.onNavigate!(2);
                              },
                              child: const Text('ตรวจพิกัด', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Action Button (Borrow vs Return vs Disabled)
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: _scannedEquipment!.isAvailable
                            ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _isProcessingAction ? null : _handleBorrow,
                                icon: _isProcessingAction
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.shopping_bag_outlined, size: 18),
                                label: const Text('ยืนยันการยืมอุปกรณ์ (7 วัน)'),
                              )
                            : _scannedEquipment!.borrowerId == '65070214'
                                ? ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.success,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: _isProcessingAction ? null : _handleReturn,
                                    icon: _isProcessingAction
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : const Icon(Icons.assignment_returned_outlined, size: 18),
                                    label: const Text('ยืนยันการคืนอุปกรณ์นี้'),
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.outline,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: null,
                                    child: Text(
                                      'อุปกรณ์นี้ถูกยืมโดย ${_scannedEquipment!.borrowerName ?? "ผู้อื่น"}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
