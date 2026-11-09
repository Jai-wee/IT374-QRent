class TransactionModel {
  final String transactionId;
  final String? studentId;
  final String equipmentId;
  final String equipmentName;
  final String? description;
  final String? imageUrl;
  final String? locationName;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final String status; // 'active', 'returned', 'overdue'

  TransactionModel({
    required this.transactionId,
    this.studentId,
    required this.equipmentId,
    required this.equipmentName,
    this.description,
    this.imageUrl,
    this.locationName,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    required this.status,
  });

  bool get isActive => status == 'active';
  bool get isReturned => status == 'returned';

  bool get isNearDue {
    if (!isActive) return false;
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference <= 2;
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id']?.toString() ?? '',
      studentId: json['student_id']?.toString(),
      equipmentId: json['equipment_id']?.toString() ?? '',
      equipmentName: json['equipment_name']?.toString() ?? 'อุปกรณ์',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      locationName: json['location_name']?.toString() ?? 'แล็บวิศวกรรม',
      borrowDate: json['borrow_date'] != null
          ? DateTime.tryParse(json['borrow_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString()) ?? DateTime.now().add(const Duration(days: 7))
          : DateTime.now().add(const Duration(days: 7)),
      returnDate: json['return_date'] != null
          ? DateTime.tryParse(json['return_date'].toString())
          : null,
      status: json['status']?.toString() ?? 'active',
    );
  }
}
