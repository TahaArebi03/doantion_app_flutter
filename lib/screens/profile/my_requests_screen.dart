import 'package:flutter/material.dart';
import '../../services/member_service.dart';
import '../../models/join_request_model.dart';

class MyRequestsScreen extends StatefulWidget {
  final String token;
  const MyRequestsScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  late MemberService _memberService;
  List<JoinRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _memberService = MemberService(widget.token);
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      _requests = await _memberService.getMyRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب الطلبات: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('لا توجد طلبات'))
              : ListView.builder(
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
                ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'pending') return Colors.orange;
    if (status == 'approved') return Colors.green;
    return Colors.red;
  }

  String _getArabicStatus(String status) {
    if (status == 'pending') return 'قيد الانتظار';
    if (status == 'approved') return 'مقبول';
    return 'مرفوض';
  }
}