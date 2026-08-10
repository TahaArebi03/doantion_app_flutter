class JoinRequest {
  final int id;
  final int userId;
  final int organizationId;
  final String status; // pending, approved, rejected
  final String firstName;
  final String lastName;
  final String email;
  final String? userImage;
  final DateTime createdAt;

  JoinRequest({
    required this.id,
    required this.userId,
    required this.organizationId,
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
    return JoinRequest(
      id: json['id'] ?? 0,
      userId: user['id'] ?? 0,
      organizationId: json['organization_id'] ?? 0,
      status: json['status'] ?? 'pending',
      firstName: user['firstName'] ?? '',
      lastName: user['lastName'] ?? '',
      email: user['email'] ?? '',
      userImage: user['image'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}