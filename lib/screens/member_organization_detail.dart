import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class MemberOrganizationDetail extends StatefulWidget {
  final String userToken;
  final dynamic organization;

  const MemberOrganizationDetail({
    Key? key,
    required this.userToken,
    required this.organization,
  }) : super(key: key);

  @override
  _MemberOrganizationDetailState createState() =>
      _MemberOrganizationDetailState();
}

class _MemberOrganizationDetailState extends State<MemberOrganizationDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<dynamic> _projects = [];
  List<dynamic> _members = [];
  bool _isLoadingProjects = true;
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    await Future.wait([_fetchProjects(), _fetchMembers()]);
  }

  // جلب مشاريع الجمعية
  Future<void> _fetchProjects() async {
    setState(() => _isLoadingProjects = true);
    final orgId = widget.organization['id'];
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/organizations/$orgId/projects',
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.userToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _projects = data['projects'] ?? data);
      }
    } catch (e) {
      _showSnackBar('خطأ في جلب المشاريع', Colors.red);
    }
    setState(() => _isLoadingProjects = false);
  }

  // جلب أعضاء الجمعية
  Future<void> _fetchMembers() async {
    setState(() => _isLoadingMembers = true);
    final orgId = widget.organization['id'];
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/organizations/$orgId/members',
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.userToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _members = data['members'] ?? data);
      }
    } catch (e) {
      _showSnackBar('خطأ في جلب الأعضاء', Colors.red);
    }
    setState(() => _isLoadingMembers = false);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: color,
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'مدير مالي':
        return Colors.orange;
      case 'مشرف':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.organization['name'] ?? 'تفاصيل الجمعية'),
        backgroundColor: const Color(0xFF1E5631),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الحملات', icon: Icon(Icons.assignment)),
            Tab(text: 'الأعضاء', icon: Icon(Icons.people)),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // تبويب المشاريع
          _isLoadingProjects
              ? const Center(child: CircularProgressIndicator())
              : _projects.isEmpty
              ? const Center(child: Text('لا توجد حملات حالياً'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(
                          Icons.assignment,
                          color: Color(0xFF1E5631),
                        ),
                        title: Text(project['name'] ?? ''),
                        subtitle: Text(project['description'] ?? ''),
                        trailing: Chip(
                          label: Text(project['status'] ?? 'قيد التنفيذ'),
                          backgroundColor: Colors.blue.shade100,
                        ),
                      ),
                    );
                  },
                ),

          // تبويب الأعضاء
          _isLoadingMembers
              ? const Center(child: CircularProgressIndicator())
              : _members.isEmpty
              ? const Center(child: Text('لا يوجد أعضاء'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    final user = member['user'] ?? member;
                    final role =
                        member['pivot']?['role'] ?? member['role'] ?? 'عضو';
                    final name =
                        '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'
                            .trim();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(name.isNotEmpty ? name[0] : 'U'),
                        ),
                        title: Text(name.isNotEmpty ? name : 'مستخدم'),
                        subtitle: Text(user['email'] ?? ''),
                        trailing: Chip(
                          label: Text(role),
                          backgroundColor: _getRoleColor(role),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
