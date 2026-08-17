enum NotificationType { invitation, request }

class NotificationItem {
  final int id;
  final NotificationType type;
  final String title;
  final String subtitle;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;
  final Map<String, dynamic>?
  data; // بيانات إضافية (مثل organizationId, requestId)

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.createdAt,
    this.data,
  });

  bool get isPending => status == 'pending';

  factory NotificationItem.fromInvitation(Map<String, dynamic> json) {
    final org = json['organization'] ?? json;
    return NotificationItem(
      id: json['id'] ?? 0,
      type: NotificationType.invitation,
      title: 'دعوة من ${org['name'] ?? 'جمعية'}',
      subtitle: org['description'] ?? 'انضم إلى جمعيتنا',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      data: {'invitation_id': json['id'], 'organization_id': org['id']},
    );
  }

  factory NotificationItem.fromRequest(Map<String, dynamic> json) {
    final org = json['organization'] ?? json;
    return NotificationItem(
      id: json['id'] ?? 0,
      type: NotificationType.request,
      title: 'طلب انضمام إلى ${org['name'] ?? 'جمعية'}',
      subtitle: 'في انتظار المراجعة',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      data: {'request_id': json['id'], 'organization_id': org['id']},
    );
  }
}
