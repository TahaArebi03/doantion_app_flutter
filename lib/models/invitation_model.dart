class Invitation {
  final int id;
  final int organizationId;
  final String organizationName;
  final String? organizationImage;
  final String inviteeName;
  final String inviteeEmail;
  final String? inviteeImage;
  final String status;
  final DateTime createdAt;

  Invitation({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    this.organizationImage,
    this.inviteeName = '',
    this.inviteeEmail = '',
    this.inviteeImage,
    required this.status,
    required this.createdAt,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    // محاولة استخراج بيانات المنظمة
    final org = json['organization'] ?? json;

    // محاولة استخراج بيانات المستخدم المدعو
    final inviteeData = json['user'] ?? json;

    // استخراج الاسم - يدعم عدة تنسيقات
    String inviteeName = '';
    if (inviteeData is Map) {
      inviteeName =
          inviteeData['firstName'] ??
          inviteeData['name'] ??
          inviteeData['full_name'] ??
          inviteeData['fullName'] ??
          '';
      // إذا كان هناك firstName و lastName
      if (inviteeName.isEmpty &&
          inviteeData['firstName'] != null &&
          inviteeData['lastName'] != null) {
        inviteeName = '${inviteeData['firstName']} ${inviteeData['lastName']}'
            .trim();
      }
    }

    // استخراج البريد الإلكتروني
    String inviteeEmail = '';
    if (inviteeData is Map) {
      inviteeEmail = inviteeData['email'] ?? '';
    }

    // استخراج الصورة
    String? inviteeImage;
    if (inviteeData is Map) {
      inviteeImage =
          inviteeData['image'] ??
          inviteeData['avatar'] ??
          inviteeData['profile_image'];
    }

    // تحويل التاريخ بشكل آمن
    DateTime createdAt = DateTime.now();
    if (json['created_at'] != null) {
      try {
        createdAt = DateTime.parse(json['created_at']);
      } catch (_) {
        // تجاهل
      }
    }

    return Invitation(
      id: json['id'] ?? 0,
      organizationId: org['id'] ?? 0,
      organizationName: org['name'] ?? 'جمعية غير معروفة',
      organizationImage: org['image'] ?? org['logo'],
      inviteeName: inviteeName,
      inviteeEmail: inviteeEmail,
      inviteeImage: inviteeImage,
      status: json['status'] ?? 'pending',
      createdAt: createdAt,
    );
  }
}
