import 'package:flutter/material.dart';
import '../../services/member_service.dart';
import '../../models/join_request_model.dart';
import '../../models/invitation_model.dart';
import '../../services/invitation_service.dart';
import '../../services/join_request_service.dart';

class NotificationsScreen extends StatefulWidget {
  final String token;
  const NotificationsScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MemberService _memberService;
  late InvitationService _invitationsService;
  late JoinRequestService _requestsService;

  List<JoinRequest> _requests = [];
  List<Invitation> _invitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _memberService = MemberService(widget.token);
    _invitationsService = InvitationService(widget.token);
    _requestsService = JoinRequestService(widget.token);
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);

    // جلب الطلبات
    try {
      final r = await _requestsService.getMyRequests();
      if (mounted) {
        setState(() => _requests = r);
      }
    } catch (e) {
      print('❌ Error fetching requests: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل جلب الطلبات: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    // جلب الدعوات
    try {
      final i = await _invitationsService.getMyInvitations();
      if (mounted) {
        setState(() => _invitations = i);
      }
    } catch (e) {
      print('❌ Error fetching invitations: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل جلب الدعوات: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAll),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الطلبات'),
            Tab(text: 'الدعوات'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildRequestsTab(), _buildInvitationsTab()],
            ),
    );
  }

  Widget _buildRequestsTab() {
    if (_requests.isEmpty) return const Center(child: Text('لا توجد طلبات'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(request.status),
              child: Text(
                request.fullName.isNotEmpty ? request.fullName[0] : 'U',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            //  اسم الجمعية
            title: Text('طلب انضمام إلى ${request.organizationName}'),
            subtitle: Text('التاريخ: ${request.createdAt.toLocal()}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(_getArabicStatus(request.status)),
                  backgroundColor: _getStatusColor(
                    request.status,
                  ).withOpacity(0.2),
                ),
                if (request.status == 'pending') ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('تأكيد الإلغاء'),
                          content: const Text(
                            'هل أنت متأكد من إلغاء هذا الطلب؟',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('إلغاء'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              child: const Text('تأكيد الإلغاء'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          await _requestsService.cancelRequest(request.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إلغاء الطلب'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          await _fetchAll();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('فشل إلغاء الطلب: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    tooltip: 'إلغاء الطلب',
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvitationsTab() {
    if (_invitations.isEmpty) return const Center(child: Text('لا توجد دعوات'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _invitations.length,
      itemBuilder: (context, index) {
        final invitation = _invitations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(invitation.organizationName),
            subtitle: Text('تاريخ الدعوة: ${invitation.createdAt.toLocal()}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (invitation.status == 'pending') ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _respondToInvitation(invitation.id, true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _respondToInvitation(invitation.id, false),
                  ),
                ] else
                  Chip(
                    label: Text(
                      invitation.status == 'accepted' ? 'مقبولة' : 'مرفوضة',
                    ),
                    backgroundColor: invitation.status == 'accepted'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _respondToInvitation(int invitationId, bool accept) async {
    try {
      if (accept) {
        await _invitationsService.acceptInvitation(invitationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم قبول الدعوة'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _invitationsService.rejectInvitation(invitationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفض الدعوة'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      await _fetchAll(); // تحديث القوائم
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'pending') return Colors.orange;
    if (status == 'approved' || status == 'accepted') return Colors.green;
    return Colors.red;
  }

  String _getArabicStatus(String status) {
    if (status == 'pending') return 'قيد الانتظار';
    if (status == 'approved' || status == 'accepted') return 'مقبول';
    return 'مرفوض';
  }
}
