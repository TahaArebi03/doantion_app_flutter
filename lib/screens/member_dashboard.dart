import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Map<String, String> _buildAuthHeaders(String token) {
  return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
}

class MemberDashboard extends StatefulWidget {
  final String userToken;

  const MemberDashboard({Key? key, required this.userToken}) : super(key: key);

  @override
  _MemberDashboardState createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  List<dynamic> _organizations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrganizations();
  }

  Future<void> _fetchOrganizations() async {
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/member/list_organizations_for_user',
    );
    try {
      final response = await http.get(
        url,
        headers: _buildAuthHeaders(widget.userToken),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _organizations = data['organizations'] ?? [];
          _isLoading = false;
        });
      } else {
        _showSnackBar('فشل في جلب الجمعيات', Colors.red);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar('خطأ في الاتصال', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الجمعيات التي أنضم إليها'),
        backgroundColor: const Color(0xFF1E5631),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrganizations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E5631)),
            )
          : _organizations.isEmpty
          ? const Center(
              child: Text(
                'أنت غير مسجل في أي جمعية حالياً',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _organizations.length,
              itemBuilder: (context, index) {
                final org = _organizations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MemberOrganizationDetail(
                            userToken: widget.userToken,
                            organization: org,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF1E5631),
                            child: Text(
                              org['name']?.isNotEmpty == true
                                  ? org['name'][0]
                                  : 'ج',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  org['name'] ?? 'بدون اسم',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  org['description'] ?? 'لا يوجد وصف',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================
// شاشة تفاصيل الجمعية للأعضاء
// ============================================================
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
    _fetchProjects();
    _fetchMembers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        headers: _buildAuthHeaders(widget.userToken),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _projects = data['projects'] ?? data;
          _isLoadingProjects = false;
        });
      } else {
        _isLoadingProjects = false;
      }
    } catch (e) {
      setState(() => _isLoadingProjects = false);
      _showSnackBar('خطأ في جلب المشاريع', Colors.red);
    }
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
        headers: _buildAuthHeaders(widget.userToken),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _members = data['members'] ?? data;
          _isLoadingMembers = false;
        });
      } else {
        _isLoadingMembers = false;
      }
    } catch (e) {
      setState(() => _isLoadingMembers = false);
      _showSnackBar('خطأ في جلب الأعضاء', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: color,
      ),
    );
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
            Tab(text: 'المشاريع', icon: Icon(Icons.assignment)),
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
              ? const Center(child: Text('لا توجد مشاريع في هذه الجمعية'))
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
                        subtitle: Text(
                          project['description'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
              ? const Center(child: Text('لا يوجد أعضاء مسجلين'))
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
}
