import 'package:flutter/material.dart';
import '../../services/member_service.dart';
import '../../models/invitation_model.dart';

class MyInvitationsScreen extends StatefulWidget {
  final String token;
  const MyInvitationsScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<MyInvitationsScreen> createState() => _MyInvitationsScreenState();
}

class _MyInvitationsScreenState extends State<MyInvitationsScreen> {
  late MemberService _memberService;
  List<Invitation> _invitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _memberService = MemberService(widget.token);
    _fetchInvitations();
  }

  Future<void> _fetchInvitations() async {
    setState(() => _isLoading = true);
    try {
      _invitations = await _memberService.getMyInvitations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب الدعوات: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _respondToInvitation(int invitationId, bool accept) async {
    try {
      if (accept) {
        await _memberService.acceptInvitation(invitationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم قبول الدعوة'), backgroundColor: Colors.green),
        );
      } else {
        await _memberService.rejectInvitation(invitationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفض الدعوة'), backgroundColor: Colors.orange),
        );
      }
      await _fetchInvitations(); // تحديث القائمة
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دعواتي'),
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invitations.isEmpty
              ? const Center(child: Text('لا توجد دعوات'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _invitations.length,
                  itemBuilder: (context, index) {
                    final invitation = _invitations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: invitation.organizationImage != null
                              ? NetworkImage(invitation.organizationImage!)
                              : null,
                          child: invitation.organizationImage == null
                              ? Text(invitation.organizationName.isNotEmpty
                                  ? invitation.organizationName[0]
                                  : 'ج')
                              : null,
                        ),
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
                                label: Text(invitation.status == 'accepted' ? 'مقبولة' : 'مرفوضة'),
                                backgroundColor: invitation.status == 'accepted'
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}