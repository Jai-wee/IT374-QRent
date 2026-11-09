import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/api_service.dart';

class ReportScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const ReportScreen({super.key, this.onNavigate});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedEquipmentId = 'EQ-00124';
  String _selectedEquipmentName = 'Lenovo ThinkPad X1 Carbon';
  String _selectedEquipmentLab = 'CE Innovation Center';
  String _selectedEquipmentImg = 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400&q=80';

  String _selectedCategory = 'ฮาร์ดแวร์ชำรุด / แตกหัก';
  final TextEditingController _noteController = TextEditingController();
  bool _hasPhotoAttached = true;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'ชำรุด / แตกหัก',
      'full': 'ฮาร์ดแวร์ชำรุด / แตกหัก',
      'icon': Icons.broken_image,
      'color': const Color(0xFFF43F5E),
    },
    {
      'title': 'เปิดไม่ติด / ไฟไม่เข้า',
      'full': 'ระบบเปิดไม่ติด / ไฟไม่เข้า',
      'icon': Icons.power_off,
      'color': const Color(0xFFF59E0B),
    },
    {
      'title': 'สายหรืออุปกรณ์หาย',
      'full': 'อุปกรณ์ต่อพ่วงหรือสายหาย',
      'icon': Icons.cable,
      'color': const Color(0xFF3B82F6),
    },
    {
      'title': 'ปัญหาอื่น ๆ',
      'full': 'ปัญหาอื่น ๆ',
      'icon': Icons.help_outline,
      'color': const Color(0xFF64748B),
    },
  ];

  final List<Map<String, String>> _availableEquipments = [
    {
      'id': 'EQ-00124',
      'name': 'Lenovo ThinkPad X1 Carbon',
      'lab': 'CE Innovation Center',
      'img': 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400&q=80',
    },
    {
      'id': 'EQ-00125',
      'name': 'Epson 4K Projector Pro',
      'lab': 'Lab AV-101',
      'img': 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=400&q=80',
    },
    {
      'id': 'EQ-00142',
      'name': 'Sony FE 24-70mm GM II',
      'lab': 'Media Lab',
      'img': 'https://images.unsplash.com/photo-1617005082133-548c4dd27f35?w=400&q=80',
    },
  ];

  void _showChangeEquipmentDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เลือกอุปกรณ์ที่ต้องการรายงานปัญหา',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._availableEquipments.map(
              (eq) => ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(eq['img']!, width: 40, height: 40, fit: BoxFit.cover),
                ),
                title: Text(eq['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('${eq['id']} • ${eq['lab']}', style: const TextStyle(fontSize: 11)),
                onTap: () {
                  setState(() {
                    _selectedEquipmentId = eq['id']!;
                    _selectedEquipmentName = eq['name']!;
                    _selectedEquipmentLab = eq['lab']!;
                    _selectedEquipmentImg = eq['img']!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedCategory = 'ฮาร์ดแวร์ชำรุด / แตกหัก';
      _noteController.clear();
      _hasPhotoAttached = true;
    });
  }

  Future<void> _handleSubmit() async {
    final note = _noteController.text.trim();
    setState(() => _isSubmitting = true);

    final result = await ApiService.submitReport(
      equipmentId: _selectedEquipmentId,
      category: _selectedCategory,
      note: note,
      imageUrl: _hasPhotoAttached ? _selectedEquipmentImg : null,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.success, size: 24),
              SizedBox(width: 8),
              Text('ส่งรายงานเรียบร้อย'),
            ],
          ),
          content: Text(
            result['message'] ?? 'รายงานปัญหาของ $_selectedEquipmentName ถูกส่งไปยังเจ้าหน้าที่แล็บเรียบร้อยแล้ว',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
                if (widget.onNavigate != null) widget.onNavigate!(0);
              },
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายงานปัญหาอุปกรณ์'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onNavigate != null) widget.onNavigate!(0);
          },
        ),
        actions: [
          TextButton(
            onPressed: _resetForm,
            child: const Text(
              'ล้างข้อมูล',
              style: TextStyle(color: AppTheme.outline, fontSize: 12),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Selected Equipment Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceContainer),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'อุปกรณ์ที่ต้องการรายงาน',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.outline),
                      ),
                      InkWell(
                        onTap: _showChangeEquipmentDialog,
                        child: const Text(
                          'เปลี่ยนอุปกรณ์',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _selectedEquipmentImg,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedEquipmentName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _selectedEquipmentId,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              _selectedEquipmentLab,
                              style: const TextStyle(fontSize: 10, color: AppTheme.outline),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Issue Categories
            const Text(
              'หมวดหมู่ปัญหา *',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['full'];
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _selectedCategory = cat['full']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryFixed : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.surfaceContainer,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(cat['icon'] as IconData, size: 18, color: cat['color'] as Color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            cat['title'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // 3. Photo Capture Card (Camera Feature)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceContainer),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 18, color: AppTheme.primary),
                          SizedBox(width: 6),
                          Text(
                            'ภาพถ่ายความเสียหาย (Camera)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        'หลักฐาน',
                        style: TextStyle(fontSize: 10, color: AppTheme.outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() => _hasPhotoAttached = !_hasPhotoAttached);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_hasPhotoAttached ? 'ถ่ายรูปความเสียหายเรียบร้อย' : 'ลบรูปภาพออกแล้ว'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.surfaceContainer),
                          ),
                          child: _hasPhotoAttached
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(_selectedEquipmentImg, fit: BoxFit.cover),
                                )
                              : const Icon(Icons.add_a_photo, color: AppTheme.primary, size: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _hasPhotoAttached ? 'แนบภาพความเสียหายแล้ว (1 ภาพ)' : 'แตะเพื่อเปิดกล้องถ่ายภาพ',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _hasPhotoAttached
                                  ? 'แตะที่รูปเพื่อถ่ายใหม่ หรือแตะลบ'
                                  : 'ถ่ายรอยชำรุดเพื่อให้เจ้าหน้าที่ประเมินได้ทันที',
                              style: const TextStyle(fontSize: 10, color: AppTheme.outline),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Notes Description (Text Input replaces Audio as agreed)
            const Text(
              'รายละเอียดเพิ่มเติม (Note)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'อธิบายจุดชำรุด หรืออาการที่เกิดขึ้นกับอุปกรณ์ (พิมพ์ข้อความแทนอัดเสียง)...',
              ),
            ),

            const SizedBox(height: 24),

            // 5. Submit Button
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryContainer, AppTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _isSubmitting ? null : _handleSubmit,
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'ส่งรายงานปัญหา (Submit Report)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
