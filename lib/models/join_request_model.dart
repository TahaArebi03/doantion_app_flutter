class JoinRequest {
  final int id;
  final int userId;
  final int organizationId;
  final String organizationName;
  final String status;
  final String firstName;
  final String lastName;
  final String email;
  final String? userImage;
  final DateTime createdAt;

  JoinRequest({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.organizationName,
    required this.status,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.userImage,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    final org = json['organization'] ?? json;

    // تحويل آمن للتاريخ
    DateTime? parsedDate;
    if (json['created_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at']);
      } catch (_) {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    return JoinRequest(
      id: json['id'] ?? 0,
      userId: user['id'] ?? 0,
      organizationId: json['organization_id'] ?? org['id'] ?? 0,
      organizationName:
          org['name'] ??
          json['organization_name'] ??
          json['organizationName'] ??
          '',
      status: json['status'] ?? 'pending',
      firstName: user['firstName'] ?? '',
      lastName: user['lastName'] ?? '',
      email: user['email'] ?? '',
      userImage: user['image'],
      createdAt: parsedDate,
    );
  }
}
