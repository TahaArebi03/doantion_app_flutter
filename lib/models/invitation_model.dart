class Invitation {
  final int id;
  final int organizationId;
  final String organizationName;
  final String? organizationImage;
  final String inviteeName;
  final String inviteeEmail;
  final String? inviteeImage;
  final String status; // pending, accepted, rejected
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
    final org = json['organization'] ?? json;
    final inviteeData = json['user'] ?? json['invitee'];
    final String inviteeName = inviteeData is Map
        ? (inviteeData['name'] ?? inviteeData['full_name'] ?? '')
        : '';
    final String inviteeEmail = inviteeData is Map
        ? (inviteeData['email'] ?? '')
        : '';
    final String? inviteeImage = inviteeData is Map
        ? (inviteeData['image'] ??
              inviteeData['avatar'] ??
              inviteeData['profile_image'])
        : null;
    return Invitation(
      id: json['id'] ?? 0,
      organizationId: org['id'] ?? 0,
      organizationName: org['name'] ?? 'جمعية غير معروفة',
      organizationImage: org['image'],
      inviteeName: inviteeName,
      inviteeEmail: inviteeEmail,
      inviteeImage: inviteeImage,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
