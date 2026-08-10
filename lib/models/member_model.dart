class MemberModel {
  final int id;
  final int userId;
  final String role;
  final String firstName;
  final String lastName;
  final String email;

  MemberModel({
    required this.id,
    required this.userId,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  String get fullName => '$firstName $lastName'.trim();

  // دالة ترجمة للعرض فقط (تأخذ إنجليزية وترجع عربية)
  static String translateRole(String role) {
    switch (role) {
      case 'admin':
        return 'مشرف';
      case 'finance_manager':
        return 'مدير مالي';
      case 'member':
      case 'user':
        return 'عضو';
      default:
        return 'عضو';
    }
  }

  // دالة لتطبيع الدور من أي قيمة قادمة من السيرفر إلى القيم المتوقعة
  static String normalizeRole(String role) {
    switch (role) {
      case 'admin':
        return 'admin';
      case 'finance_manager':
        return 'finance_manager';
      case 'user':
      case 'member':
      default:
        return 'member'; // القيمة الافتراضية
    }
  }

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    // استخراج بيانات المستخدم
    final user = json['user'] ?? json;

    // استخراج pivot (الذي يحتوي على الدور داخل الجمعية)
    final pivot = json['pivot'] ?? user['pivot'] ?? {};

    // الأولوية للدور من pivot، ثم من json، ثم من user، وأخيراً القيمة الافتراضية
    final role = pivot['role'] ?? json['role'] ?? user['role'] ?? 'member';

    return MemberModel(
      id: json['id'] ?? 0,
      userId: user['id'] ?? 0,
      role: normalizeRole(role), // تطبيع الدور
      firstName: user['firstName'] ?? '',
      lastName: user['lastName'] ?? '',
      email: user['email'] ?? '',
    );
  }
}
