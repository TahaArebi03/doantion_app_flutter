import 'dart:convert';
import 'package:flutter/material.dart';
import 'member_organization_detail.dart';
import 'package:http/http.dart' as http;

class MemberDashboard extends StatefulWidget {
  final String userToken;

  const MemberDashboard({Key? key, required this.userToken}) : super(key: key);

  @override
  _MemberDashboardState createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // بيانات المشاريع
  List<dynamic> _projects = [];
  bool _isLoadingProjects = true;

  // بيانات الجمعيات
  List<dynamic> _allOrganizations = []; // جميع الجمعيات
  List<dynamic> _myOrganizations = []; // جمعياتي (المنضم لها)
  bool _isLoadingOrgs = true;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    await Future.wait([_fetchAllProjects(), _fetchAllOrganizations()]);
  }

  // ===================== جلب جميع المشاريع =====================
  Future<void> _fetchAllProjects() async {
    setState(() => _isLoadingProjects = true);
    final url = Uri.parse('http://127.0.0.1:8000/api/projects/all');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${widget.userToken}'},
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

  // ===================== جلب جميع الجمعيات =====================
  Future<void> _fetchAllOrganizations() async {
    setState(() => _isLoadingOrgs = true);
    final url = Uri.parse('http://127.0.0.1:8000/api/organizations/all');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${widget.userToken}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allOrgs = data['organizations'] ?? [];
        setState(() {
          _allOrganizations = allOrgs;
          // تصفية الجمعيات التي انضم لها المستخدم
          _myOrganizations = allOrgs
              .where((org) => org['is_member'] == true)
              .toList();
        });
      }
    } catch (e) {
      _showSnackBar('خطأ في جلب الجمعيات', Colors.red);
    }
    setState(() => _isLoadingOrgs = false);
  }

  // ===================== الانضمام لجمعية =====================
  Future<void> _joinOrganization(int organizationId) async {
    setState(() => _isJoining = true);
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/organizations/$organizationId/join',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer ${widget.userToken}'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showSnackBar('تم الانضمام للجمعية بنجاح', Colors.green);
        // تحديث قائمة الجمعيات
        await _fetchAllOrganizations();
      } else {
        _showSnackBar(data['message'] ?? 'فشل الانضمام', Colors.red);
      }
    } catch (e) {
      _showSnackBar('خطأ في الاتصال', Colors.red);
    }
    setState(() => _isJoining = false);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: color,
      ),
    );
  }

  // ===================== عرض تفاصيل المشروع =====================
  void _showProjectDetails(dynamic project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project['name'] ?? 'تفاصيل المشروع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الوصف: ${project['description'] ?? 'لا يوجد'}'),
            const SizedBox(height: 8),
            Text('الهدف: \$${project['goal_amount'] ?? 0}'),
            const SizedBox(height: 8),
            Text('الحالة: ${project['status'] ?? 'قيد التنفيذ'}'),
            const SizedBox(height: 8),
            Text('الجمعية: ${project['organization']?['name'] ?? 'غير محدد'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // ===================== عرض تفاصيل الجمعية (لجمعياتي) =====================
  void _showOrganizationDetails(dynamic organization) {
    // الانتقال لصفحة تفاصيل الجمعية (مشاريعها وأعضائها)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberOrganizationDetail(
          userToken: widget.userToken,
          organization: organization,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('منصة التبرعات'),
        backgroundColor: const Color(0xFF1E5631),
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المشاريع', icon: Icon(Icons.assignment)),
            Tab(text: 'استكشاف', icon: Icon(Icons.explore)),
            Tab(text: 'جمعياتي', icon: Icon(Icons.business)),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProjectsTab(),
          _buildAllOrganizationsTab(),
          _buildMyOrganizationsTab(),
        ],
      ),
    );
  }

  // ===================== تبويب المشاريع =====================
  Widget _buildProjectsTab() {
    return _isLoadingProjects
        ? const Center(child: CircularProgressIndicator())
        : _projects.isEmpty
        ? const Center(child: Text('لا توجد مشاريع حالياً'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _projects.length,
            itemBuilder: (context, index) {
              final project = _projects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => _showProjectDetails(project),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                project['name'] ?? 'مشروع بدون عنوان',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(
                                project['status'] ?? 'قيد التنفيذ',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: project['status'] == 'approved'
                                  ? Colors.green.shade100
                                  : Colors.blue.shade100,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project['description'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الهدف: \$${project['goal_amount'] ?? 0}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'تم التبرع: \$${project['donated_amount'] ?? 0}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  // ===================== تبويب استكشاف (جميع الجمعيات) =====================
  Widget _buildAllOrganizationsTab() {
    return _isLoadingOrgs
        ? const Center(child: CircularProgressIndicator())
        : _allOrganizations.isEmpty
        ? const Center(child: Text('لا توجد جمعيات متاحة'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _allOrganizations.length,
            itemBuilder: (context, index) {
              final org = _allOrganizations[index];
              final isMember = org['is_member'] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                            Text(
                              org['description'] ?? 'لا يوجد وصف',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (isMember)
                        const Chip(
                          label: Text('منضم'),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(color: Colors.white),
                        )
                      else
                        ElevatedButton(
                          onPressed: _isJoining
                              ? null
                              : () {
                                  _joinOrganization(org['id']);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E5631),
                            foregroundColor: Colors.white,
                          ),
                          child: _isJoining
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('انضمام'),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  // ===================== تبويب جمعياتي (الجمعيات المنضم لها) =====================
  Widget _buildMyOrganizationsTab() {
    return _isLoadingOrgs
        ? const Center(child: CircularProgressIndicator())
        : _myOrganizations.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business_center,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'لم تنضم لأي جمعية بعد',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اذهب إلى تبويب "استكشاف" للانضمام لجمعية',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _tabController.animateTo(1); // الانتقال إلى تبويب استكشاف
                  },
                  icon: const Icon(Icons.explore),
                  label: const Text('استكشاف الجمعيات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5631),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _myOrganizations.length,
            itemBuilder: (context, index) {
              final org = _myOrganizations[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => _showOrganizationDetails(org),
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
                              Text(
                                org['description'] ?? 'لا يوجد وصف',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Chip(
                          label: Text('منضم'),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
