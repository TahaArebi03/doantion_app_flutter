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

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    return MemberModel(
      id: json['id'] ?? 0,
      userId: user['id'] ?? 0,
      role: json['role'] ?? 'عضو',
      firstName: user['firstName'] ?? '',
      lastName: user['lastName'] ?? '',
      email: user['email'] ?? '',
    );
  }
}