class Invitation {
  final int id;
  final int organizationId;
  final String organizationName;
  final String? organizationImage;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  Invitation({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    this.organizationImage,
    required this.status,
    required this.createdAt,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    final org = json['organization'] ?? json;
    return Invitation(
      id: json['id'] ?? 0,
      organizationId: org['id'] ?? 0,
      organizationName: org['name'] ?? 'جمعية غير معروفة',
      organizationImage: org['image'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}