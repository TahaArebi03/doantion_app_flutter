import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notification_item.dart';
import '../screens/notifications/notifications_screen.dart';

class NotificationBadge extends StatefulWidget {
  final String token;
  final VoidCallback? onNotificationTap;

  const NotificationBadge({
    Key? key,
    required this.token,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  late NotificationService _notificationService;
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService(widget.token);
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      _notifications = await _notificationService.getNotifications();
    } catch (e) {
      // silent fail
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int get _pendingCount => _notifications.where((n) => n.isPending).length;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationsScreen(token: widget.token),
              ),
            ).then((_) => widget.onNotificationTap?.call());
          },
        ),
        if (_pendingCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                _pendingCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return ListTile(
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isPending
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.subtitle),
          const SizedBox(height: 4),
          _buildStatusChip(notification.status),
        ],
      ),
      trailing:
          notification.type == NotificationType.invitation &&
              notification.isPending
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () async {
                    try {
                      await _notificationService.acceptInvitation(
                        notification.data!['invitation_id'],
                      );
                      _showSnackBar('تم قبول الدعوة', Colors.green);
                      await _fetchNotifications();
                      widget.onNotificationTap?.call();
                    } catch (e) {
                      _showSnackBar('فشل القبول', Colors.red);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () async {
                    try {
                      await _notificationService.rejectInvitation(
                        notification.data!['invitation_id'],
                      );
                      _showSnackBar('تم رفض الدعوة', Colors.orange);
                      await _fetchNotifications();
                      widget.onNotificationTap?.call();
                    } catch (e) {
                      _showSnackBar('فشل الرفض', Colors.red);
                    }
                  },
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'معلقة';
        break;
      case 'accepted':
      case 'approved':
        color = Colors.green;
        label = 'مقبولة';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'مرفوضة';
        break;
      default:
        color = Colors.grey;
        label = 'غير معروف';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
