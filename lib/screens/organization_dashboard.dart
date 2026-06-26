import 'dart:convert';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;

// ============================================================
// 1. الشاشة الرئيسية (Dashboard)
// ============================================================
class OrganizationDashboard extends StatefulWidget {
  final String orgToken;

  const OrganizationDashboard({Key? key, required this.orgToken})
    : super(key: key);

  @override
  _OrganizationDashboardState createState() => _OrganizationDashboardState();
}

class _OrganizationDashboardState extends State<OrganizationDashboard> {
  String _currentSection = 'projects';

  Map<String, dynamic>? _organizationInfo;
  bool _isLoading = true;

  // بيانات المشاريع
  List<dynamic> _projects = [];
  bool _isLoadingProjects = false;
  // قائمة المستخدمين المتاحين للإضافة (جميع المستخدمين - الأعضاء الحاليين)
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoadingUsers = false;
  TextEditingController _searchUsersController = TextEditingController();
  // بيانات الأعضاء
  List<dynamic> _members = [];

  // ============================================================
  // دوال جلب البيانات
  // ============================================================
  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  void _debugHeaders() {
    print('🔑 Token: ${widget.orgToken}');
    final headers = _getHeaders();
    print('📋 Headers: $headers');
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // محاولة جلب معلومات الجمعية
      await _fetchOrganizationInfo();
      _debugHeaders();
      // إذا لم يتم جلب المعلومات، نعرض رسالة ونوقف التحميل
      if (_organizationInfo == null) {
        _showSnackBar('لم يتم العثور على جمعية لهذا المستخدم', Colors.orange);
        setState(() => _isLoading = false);
        return;
      }

      // جلب المشاريع والأعضاء
      await _fetchProjects();
      await _fetchMembers();

      setState(() => _isLoading = false);
    } catch (e) {
      _showSnackBar('فشل في تحميل البيانات', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchOrganizationInfo() async {
    // المحاولة 1: استخدام /organization/show
    final orgUrl = Uri.parse('http://127.0.0.1:8000/api/organization/show');
    final orgResponse = await http.get(orgUrl, headers: _getHeaders());
    print('📡 Organization response status: ${orgResponse.statusCode}');
    print('📡 Organization response body: ${orgResponse.body}');

    if (orgResponse.statusCode == 200) {
      final orgData = jsonDecode(orgResponse.body);
      setState(() => _organizationInfo = orgData);
      print('✅ Organization info fetched from /organization/show');
      return;
    }

    // المحاولة 2: استخدام list_organizations_for_user
    final backupUrl = Uri.parse(
      'http://127.0.0.1:8000/api/member/list_organizations_for_user',
    );
    final backupResponse = await http.get(backupUrl, headers: _getHeaders());
    if (backupResponse.statusCode == 200) {
      final data = jsonDecode(backupResponse.body);
      final orgs = data['organizations'] ?? [];
      if (orgs.isNotEmpty) {
        setState(() => _organizationInfo = orgs.first);
        print('✅ Organization info fetched from list_organizations_for_user');
        return;
      }
    }

    // المحاولة 3: استخدام user->organization (من خلال علاقة hasOne) ولكن لا يوجد مسار مباشر آخر
    // يمكننا محاولة استخدام /api/user (إن وجد) ولكننا لا نملكه.
    print('❌ All attempts to fetch organization info failed');
  }

  // --- جلب المشاريع ---
  Future<void> _fetchProjects() async {
    setState(() => _isLoadingProjects = true);
    final orgId =
        _organizationInfo?['id'] ?? widget.orgToken; // fallback if needed
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/organizations/$orgId/projects',
    );
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _projects = data['projects'] ?? data);
      }
    } catch (e) {
      _showSnackBar('خطأ في جلب المشاريع', Colors.red);
    }
    setState(() => _isLoadingProjects = false);
  }

  // -- جلب الأعضاء ---
  Future<void> _fetchMembers() async {
    final orgId = _organizationInfo?['id'];
    if (orgId == null) {
      setState(() {
        _members = [];
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
      'http://127.0.0.1:8000/api/member/list_members?organization_id=$orgId',
    );
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final members = data['members'] ?? [];
        setState(() => _members = members);
        // بعد تحديث _members، نحدث قائمة المستخدمين
        await _fetchAllUsers();
      } else {
        print('⚠️ Failed to fetch members: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error fetching members: $e');
    }
  }

  Future<void> _fetchAllUsers() async {
    setState(() => _isLoadingUsers = true);
    final url = Uri.parse('http://127.0.0.1:8000/api/users');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> users = [];
        if (data is List) {
          users = data;
        } else if (data['users'] is List) {
          users = data['users'];
        } else {
          print('⚠️ Unexpected data format: $data');
          setState(() {
            _allUsers = [];
            _filteredUsers = [];
          });
          setState(() => _isLoadingUsers = false);
          return;
        }

        // إزالة العناصر الفارغة
        users = users.where((u) => u != null).toList();

        final ownerId =
            _organizationInfo?['owner_id'] ?? _organizationInfo?['id'];
        final memberIds = _members
            .where((m) => m != null)
            .map<int>((m) => m['user']?['id'] ?? m['id'])
            .where((id) => id != null)
            .toSet();

        final availableUsers = users.where((u) {
          if (u == null) return false;
          final id = u['id'];
          if (id == null) return false;
          final isOwner = id == ownerId;
          final isMember = memberIds.contains(id);
          return !isOwner && !isMember;
        }).toList();

        setState(() {
          _allUsers = availableUsers;
          _filteredUsers = availableUsers;
        });
      } else {
        setState(() {
          _allUsers = [];
          _filteredUsers = [];
        });
      }
    } catch (e) {
      print('❌ Exception in _fetchAllUsers: $e');
      setState(() {
        _allUsers = [];
        _filteredUsers = [];
      });
    }
    setState(() => _isLoadingUsers = false);
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((u) {
          final name = '${u['firstName']} ${u['lastName']}'.toLowerCase();
          final email = u['email'].toLowerCase();
          final q = query.toLowerCase();
          return name.contains(q) || email.contains(q);
        }).toList();
      }
    });
  }

  // عرض حوار إضافة عضو مع تمرير المستخدم المحدد
  void _showAddMemberDialogWithUser(Map<String, dynamic> user) {
    String selectedRole = 'عضو';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final name = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'
                .trim();
            return AlertDialog(
              title: const Text('إضافة عضو جديد'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.isNotEmpty ? name : (user['email'] ?? 'مستخدم')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'عضو', child: Text('عضو')),
                      DropdownMenuItem(value: 'مشرف', child: Text('مشرف')),
                      DropdownMenuItem(
                        value: 'مدير مالي',
                        child: Text('مدير مالي'),
                      ),
                    ],
                    onChanged: (v) => setStateDialog(() => selectedRole = v!),
                    decoration: const InputDecoration(labelText: 'الدور'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    final id = user['id'];
                    if (id != null) _addMember(id, selectedRole);
                  },
                  child: const Text('إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // دوال إدارة المشاريع
  // ============================================================

  // إنشاء مشروع (يستقبل البيانات من الشاشة المنفصلة)
  Future<void> _createProject(Map<String, dynamic> projectData) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/project/create');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(projectData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('تم إنشاء المشروع بنجاح', Colors.green);
        await _fetchProjects(); // تحديث القائمة
      } else {
        _showSnackBar(data['message'] ?? 'فشل الإنشاء', Colors.red);
      }
    } catch (e) {
      _showSnackBar('خطأ في الاتصال', Colors.red);
    }
  }

  // عرض تفاصيل المشروع (حوار سريع)
  Future<void> _showProjectDetails(int projectId) async {
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/project/show?id=$projectId',
    );
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final project = data['project'] ?? data;
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
    } catch (e) {
      _showSnackBar('خطأ في جلب التفاصيل', Colors.red);
    }
  }

  // ============================================================
  // دوال إدارة الأعضاء (إضافة، بحث، حذف، ترقية)
  // ============================================================

  // البحث عن مستخدمين (لإضافتهم)
  Future<List<dynamic>> _searchUser(String query) async {
    if (query.trim().isEmpty) return [];
    final url = Uri.parse('http://127.0.0.1:8000/api/member/search');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({'query': query}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['users'] ?? data;
      }
    } catch (e) {
      _showSnackBar('خطأ في البحث', Colors.red);
    }
    return [];
  }

  // إضافة عضو
  Future<void> _addMember(int userId, String role) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/member/add');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({'user_id': userId, 'role': role}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('تمت الإضافة بنجاح', Colors.green);
        await _fetchMembers(); // هذا سيحدث _members و _allUsers
      } else {
        _showSnackBar(data['message'] ?? 'فشل الإضافة', Colors.red);
      }
    } catch (e) {
      _showSnackBar('خطأ في الاتصال', Colors.red);
    }
  }

  // ترقية / تحديث دور العضو
  Future<void> _updateMemberRole(int userId, String newRole) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/member/update-role');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'user_id': userId,
          'role': newRole,
        }), // ✅ بدون organization_id
      );
      if (response.statusCode == 200) {
        _showSnackBar('تم تحديث الدور', Colors.green);
        await _fetchMembers();
      }
    } catch (e) {
      _showSnackBar('خطأ في التحديث', Colors.red);
    }
  }

  // حذف عضو
  Future<void> _removeMember(int userId) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/member/remove');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({'user_id': userId}), // ✅ بدون organization_id
      );
      if (response.statusCode == 200) {
        _showSnackBar('تم الحذف', Colors.green);
        await _fetchMembers();
      }
    } catch (e) {
      _showSnackBar('خطأ في الحذف', Colors.red);
    }
  }

  // ============================================================
  // دوال مساعدة
  // ============================================================
  Map<String, String> _getHeaders() {
    final token = widget.orgToken.trim();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _logout() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/logout');
    await http.post(url, headers: _getHeaders()).catchError((_) {});
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  String _getAppBarTitle() {
    switch (_currentSection) {
      case 'projects':
        return 'مشاريع الجمعية';
      case 'members':
        return 'إدارة الأعضاء';
      default:
        return 'لوحة التحكم';
    }
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

  // ============================================================
  // بناء الواجهة الرئيسية
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E5631),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDashboardData,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1E5631)),
              accountName: Text(
                _organizationInfo?['name'] ?? 'الجمعية',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(_organizationInfo?['email'] ?? 'مدير الجمعية'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.business, size: 40, color: Color(0xFF1E5631)),
              ),
            ),
            _buildDrawerItem('projects', 'المشاريع', Icons.assignment),
            _buildDrawerItem('members', 'الأعضاء', Icons.people),
            const Divider(),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _logout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E5631)),
            )
          : (_currentSection == 'projects'
                ? _buildProjectsList()
                : _buildMembersList()),
    );
  }

  Widget _buildDrawerItem(String section, String title, IconData icon) {
    bool isSelected = _currentSection == section;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF1E5631) : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF1E5631) : Colors.black87,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF1E5631).withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);
        setState(() => _currentSection = section);
        if (section == 'projects') _fetchProjects();
        if (section == 'members') _fetchMembers();
      },
    );
  }

  // ============================================================
  // عرض المشاريع (الصفحة الرئيسية)
  // ============================================================
  Widget _buildProjectsList() {
    return Column(
      children: [
        // زر إنشاء مشروع (يؤدي لشاشة منفصلة)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () async {
              // فتح شاشة الإنشاء المنفصلة وانتظار النتيجة
              final newProject = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateProjectScreen(orgToken: widget.orgToken),
                ),
              );
              // إذا رجع المشروع ببيانات، نقوم بإنشائه
              if (newProject != null) {
                await _createProject(newProject);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E5631),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'إنشاء مشروع جديد',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: _isLoadingProjects
              ? const Center(child: CircularProgressIndicator())
              : _projects.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد مشاريع مسجلة',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _showProjectDetails(project['id']),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    ),
                                    backgroundColor: Colors.blue.shade100,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'الهدف: \$${project['goal_amount'] ?? 0}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${project['created_at']?.toString().substring(0, 10) ?? ''}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ============================================================
  // عرض الأعضاء (مع التبويبات)
  // ============================================================
  Widget _buildMembersList() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'الأعضاء الحاليين', icon: Icon(Icons.people)),
              Tab(text: 'إضافة عضو', icon: Icon(Icons.person_add)),
            ],
            labelColor: Color(0xFF1E5631),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF1E5631),
          ),
          Expanded(
            child: TabBarView(
              children: [_buildCurrentMembersTab(), _buildAddMemberTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMembersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'الأعضاء الحاليين (${_members.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchMembers,
              ),
            ],
          ),
        ),
        Expanded(
          child: _members.isEmpty
              ? const Center(child: Text('لا يوجد أعضاء مسجلين'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    final user = member['user'] ?? member;
                    final role =
                        member['pivot']?['role'] ?? member['role'] ?? 'عضو';
                    final userId = user['id'] ?? member['id'];
                    final name =
                        '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'
                            .trim();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: _getRoleColor(role),
                              child: Text(
                                name.isNotEmpty ? name[0] : 'U',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.isNotEmpty ? name : 'مستخدم #$userId',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    user['email'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DropdownButton<String>(
                              value: role,
                              items: const [
                                DropdownMenuItem(
                                  value: 'عضو',
                                  child: Text('عضو'),
                                ),
                                DropdownMenuItem(
                                  value: 'مشرف',
                                  child: Text('مشرف'),
                                ),
                                DropdownMenuItem(
                                  value: 'مدير مالي',
                                  child: Text('مدير مالي'),
                                ),
                              ],
                              onChanged: (newRole) {
                                if (newRole != null && newRole != role) {
                                  _updateMemberRole(userId, newRole);
                                }
                              },
                              underline: const SizedBox(),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: const Text(
                                      'هل أنت متأكد من حذف هذا العضو؟',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('إلغاء'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          _removeMember(userId);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                        ),
                                        child: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAddMemberTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchUsersController,
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم أو البريد الإلكتروني',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
            ),
            onChanged: _filterUsers,
          ),
        ),
        Expanded(
          child: _isLoadingUsers
              ? const Center(child: CircularProgressIndicator())
              : _filteredUsers.isEmpty
              ? const Center(child: Text('لا يوجد مستخدمين متاحين للإضافة'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    final name =
                        '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'
                            .trim();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          child: Text(name.isNotEmpty ? name[0] : 'U'),
                        ),
                        title: Text(name.isNotEmpty ? name : 'مستخدم بدون اسم'),
                        subtitle: Text(user['email'] ?? ''),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _showAddMemberDialogWithUser(user);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E5631),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('إضافة'),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ============================================================
  // حوار إضافة عضو (مع البحث المدمج)
  // ============================================================
  Widget _buildAddMemberDialog() {
    final searchController = TextEditingController();
    List<dynamic> results = [];
    String selectedRole = 'عضو';
    int? selectedUserId;

    return StatefulBuilder(
      builder: (context, setStateDialog) {
        return AlertDialog(
          title: const Text('إضافة عضو جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'ابحث بالاسم أو البريد',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) async {
                    if (value.length >= 2) {
                      final res = await _searchUser(value);
                      setStateDialog(() => results = res);
                    } else {
                      setStateDialog(() => results = []);
                    }
                  },
                ),
                const SizedBox(height: 8),
                if (results.isNotEmpty)
                  Container(
                    height: 100,
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (ctx, i) {
                        final u = results[i];
                        final n = '${u['firstName']} ${u['lastName']}'.trim();
                        return ListTile(
                          title: Text(n.isNotEmpty ? n : u['email']),
                          subtitle: Text(u['email']),
                          onTap: () {
                            setStateDialog(() {
                              selectedUserId = u['id'];
                              searchController.text = n.isNotEmpty
                                  ? n
                                  : u['email'];
                              results = [];
                            });
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'عضو', child: Text('عضو')),
                    DropdownMenuItem(value: 'مشرف', child: Text('مشرف')),
                    DropdownMenuItem(
                      value: 'مدير مالي',
                      child: Text('مدير مالي'),
                    ),
                  ],
                  onChanged: (v) => setStateDialog(() => selectedRole = v!),
                  decoration: const InputDecoration(
                    labelText: 'الدور',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedUserId == null) {
                  _showSnackBar('يرجى اختيار مستخدم من البحث', Colors.red);
                  return;
                }
                Navigator.pop(context);
                _addMember(selectedUserId!, selectedRole);
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  // حوار عرض نتائج البحث (بديل)
  void _showSearchResultsDialog(List<dynamic> results) {
    // يمكن تنفيذها إذا أردت، لكننا دمجناها داخل حوار الإضافة أعلاه.
  }
}

// ============================================================
// 2. شاشة إنشاء المشروع (منفصلة تماماً)
// ============================================================
class CreateProjectScreen extends StatefulWidget {
  final String orgToken;
  const CreateProjectScreen({Key? key, required this.orgToken})
    : super(key: key);

  @override
  _CreateProjectScreenState createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _goalController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء مشروع جديد'),
        backgroundColor: const Color(0xFF1E5631),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'بيانات المشروع',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المشروع',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'اسم المشروع مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'وصف المشروع',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _goalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الهدف المالي (\$)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'الهدف مطلوب' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // إرجاع البيانات للشاشة السابقة
                      Navigator.pop(context, {
                        'name': _nameController.text,
                        'description': _descController.text,
                        'goal_amount':
                            double.tryParse(_goalController.text) ?? 0,
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5631),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'حفظ المشروع',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
