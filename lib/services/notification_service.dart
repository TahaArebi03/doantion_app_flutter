import '../models/notification_item.dart';
import 'join_request_service.dart';
import 'invitation_service.dart';

class NotificationService {
  final String token;
  late final JoinRequestService _requestService;
  late final InvitationService _invitationService;

  NotificationService(this.token) {
    _requestService = JoinRequestService(token);
    _invitationService = InvitationService(token);
  }

  Future<List<NotificationItem>> getNotifications() async {
    try {
      final invitations = await _invitationService.getMyInvitations();
      final requests = await _requestService.getMyRequests();

      final all = <NotificationItem>[
        ...invitations.map(
          (i) => NotificationItem.fromInvitation({
            'id': i.id,
            'organization': {
              'id': i.organizationId,
              'name': i.organizationName,
              'description': null,
              'image': i.organizationImage,
            },
            'status': i.status,
            'created_at': i.createdAt.toIso8601String(),
          }),
        ),
        ...requests.map(
          (r) => NotificationItem.fromRequest({
            'id': r.id,
            'organization': {'id': r.organizationId, 'name': ''},
            'status': r.status,
            'created_at': r.createdAt.toIso8601String(),
          }),
        ),
      ];
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return all;
    } catch (e) {
      throw Exception('فشل جلب الإشعارات: $e');
    }
  }

  // دوال مختصرة للتعامل مع الدعوات والطلبات
  Future<void> acceptInvitation(int id) =>
      _invitationService.acceptInvitation(id);
  Future<void> rejectInvitation(int id) =>
      _invitationService.rejectInvitation(id);
}
