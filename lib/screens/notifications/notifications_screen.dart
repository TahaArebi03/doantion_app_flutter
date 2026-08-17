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
    try {
      final r = await _requestsService.getMyRequests();
      final i = await _invitationsService.getMyInvitations();
      if (mounted)
        setState(() {
          _requests = r;
          _invitations = i;
        });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل جلب الإشعارات: $e'),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            title: Text('طلب انضمام إلى جمعية #${request.organizationId}'),
            subtitle: Text('التاريخ: ${request.createdAt.toLocal()}'),
            trailing: Chip(
              label: Text(_getArabicStatus(request.status)),
              backgroundColor: _getStatusColor(request.status).withOpacity(0.2),
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
      await _fetchAll();
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
