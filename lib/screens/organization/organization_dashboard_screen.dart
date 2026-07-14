import 'package:flutter/material.dart';
import '../../services/organization_service.dart';
import '../../services/project_service.dart';
import '../../services/member_service.dart';
import '../../models/organization_model.dart';
import '../../models/project_model.dart';
import '../../models/member_model.dart';
import '../../models/user_model.dart';
import '../../widgets/project_card.dart';
import '../../widgets/member_card.dart';
import '../../widgets/custom_drawer.dart';
import '../projects/create_project_screen.dart';   // مسار صحيح
import '../projects/project_detail_screen.dart';   // مسار صحيح
import '../auth/login_screen.dart';               
class OrganizationDashboardScreen extends StatefulWidget {
  final String orgToken;

  const OrganizationDashboardScreen({Key? key, required this.orgToken})
      : super(key: key);

  @override
  State<OrganizationDashboardScreen> createState() =>
      _OrganizationDashboardScreenState();
}

class _OrganizationDashboardScreenState
    extends State<OrganizationDashboardScreen> {
  // Services
  late OrganizationService _orgService;
  late ProjectService _projectService;
  late MemberService _memberService;

  // Data
  Organization? _organization;
  List<ProjectModel> _projects = [];
  List<MemberModel> _members = [];
  List<UserModel> _availableUsers = [];
  List<UserModel> _filteredUsers = [];

  // UI State
  bool _isLoading = true;
  bool _isLoadingProjects = false;
  bool _isLoadingMembers = false;
  String _currentSection = 'projects';

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _orgService = OrganizationService(widget.orgToken);
    _projectService = ProjectService(token: widget.orgToken);
    _memberService = MemberService(widget.orgToken);
    _fetchDashboardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==================== Data Fetching ====================
  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      await _fetchOrganizationInfo();
      if (_organization != null) {
        await Future.wait([
          _fetchProjects(),
          _fetchMembers(),
        ]);
      }
    } catch (e) {
      _showSnackBar('فشل تحميل البيانات: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchOrganizationInfo() async {
    try {
      _organization = await _orgService.getOrganizationInfo();
    } catch (e) {
      _showSnackBar('فشل جلب معلومات الجمعية', Colors.orange);
    }
  }

  Future<void> _fetchProjects() async {
    if (_organization == null) return;
    setState(() => _isLoadingProjects = true);
    try {
      _projects = await _projectService.getProjectsForOrganization(_organization!.id);
    } catch (e) {
      _showSnackBar('فشل جلب المشاريع', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoadingProjects = false);
    }
  }

  Future<void> _fetchMembers() async {
    if (_organization == null) return;
    setState(() => _isLoadingMembers = true);
    try {
      _members = await _memberService.getMembers(_organization!.id);
      await _fetchAvailableUsers();
    } catch (e) {
      _showSnackBar('فشل جلب الأعضاء', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoadingMembers = false);
    }
  }

  Future<void> _fetchAvailableUsers() async {
    try {
      final allUsers = await _memberService.getAllUsers();
      final ownerId = _organization!.ownerId;
      final memberIds = _members.map((m) => m.userId).toSet();

      _availableUsers = allUsers.where((u) {
        return u.id != ownerId && !memberIds.contains(u.id);
      }).toList();
      _filteredUsers = _availableUsers;
    } catch (e) {
      _availableUsers = [];
      _filteredUsers = [];
    }
  }

  // ==================== Member Actions ====================
  Future<void> _addMember(UserModel user, String role) async {
    try {
      await _memberService.addMember(user.id, role);
      _showSnackBar('تمت إضافة العضو بنجاح', Colors.green);
      await _fetchMembers();
    } catch (e) {
      _showSnackBar('فشل الإضافة', Colors.red);
    }
  }

  Future<void> _updateMemberRole(MemberModel member, String newRole) async {
    try {
      await _memberService.updateRole(member.userId, newRole);
      _showSnackBar('تم تحديث الدور', Colors.green);
      await _fetchMembers();
    } catch (e) {
      _showSnackBar('فشل التحديث', Colors.red);
    }
  }

  Future<void> _removeMember(MemberModel member) async {
    try {
      await _memberService.removeMember(member.userId);
      _showSnackBar('تم حذف العضو', Colors.green);
      await _fetchMembers();
    } catch (e) {
      _showSnackBar('فشل الحذف', Colors.red);
    }
  }

  // ==================== Project Actions ====================
  Future<void> _createProject(Map<String, dynamic> data) async {
    try {
      await _projectService.createProject(
  adminToken: widget.orgToken,
  title: data['title'] ?? '',
  description: data['description'] ?? '',
  goalAmount: data['goal_amount'] ?? 0.0,
);
      _showSnackBar('تم إنشاء المشروع بنجاح', Colors.green);
      await _fetchProjects();
    } catch (e) {
      _showSnackBar('فشل إنشاء المشروع', Colors.red);
    }
  }

  // ==================== Navigation ====================
  void _logout() async {
    // يمكن إضافة طلب logout
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ==================== UI Helpers ====================
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ==================== Build Methods ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F4),
      appBar: AppBar(
        title: Text(
          _currentSection == 'projects' ? 'مشاريع الجمعية' : 'إدارة الأعضاء',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDashboardData,
          ),
        ],
      ),
      drawer: CustomDrawer(
        organizationName: _organization?.name ?? 'الجمعية',
        currentSection: _currentSection,
        onSectionChanged: (section) {
          setState(() => _currentSection = section);
          if (section == 'projects') _fetchProjects();
          if (section == 'members') _fetchMembers();
        },
        onLogout: _logout,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
          : _currentSection == 'projects'
              ? _buildProjectsTab()
              : _buildMembersTab(),
    );
  }

  // ==================== Projects Tab ====================
  Widget _buildProjectsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () async {
              final newProject = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateProjectScreen(orgToken: widget.orgToken),
                ),
              );
              if (newProject != null) await _createProject(newProject);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4332),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
              : _projects.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد مشاريع مسجلة',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _projects.length,
                      itemBuilder: (context, index) {
                        final project = _projects[index];
                        return ProjectCard(
                          project: project,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectDetailScreen(project: project),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // ==================== Members Tab ====================
  Widget _buildMembersTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'الأعضاء الحاليين', icon: Icon(Icons.people)),
              Tab(text: 'إضافة عضو', icon: Icon(Icons.person_add)),
            ],
            labelColor: Color(0xFF1B4332),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFD4AF37),
            indicatorWeight: 3,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCurrentMembersTab(),
                _buildAddMemberTab(),
              ],
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
          child: _isLoadingMembers
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
              : _members.isEmpty
                  ? const Center(child: Text('لا يوجد أعضاء مسجلين'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _members.length,
                      itemBuilder: (context, index) {
                        final member = _members[index];
                        return MemberCard(
                          member: member,
                          onRoleChanged: (newRole) {
                            _updateMemberRole(member, newRole);
                          },
                          onRemove: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('تأكيد الحذف'),
                                content: const Text('هل أنت متأكد من حذف هذا العضو؟'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('إلغاء'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _removeMember(member);
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
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم أو البريد الإلكتروني',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (query) {
              setState(() {
                if (query.isEmpty) {
                  _filteredUsers = _availableUsers;
                } else {
                  _filteredUsers = _availableUsers.where((u) {
                    final name = u.fullName.toLowerCase();
                    final email = u.email.toLowerCase();
                    final q = query.toLowerCase();
                    return name.contains(q) || email.contains(q);
                  }).toList();
                }
              });
            },
          ),
        ),
        Expanded(
          child: _filteredUsers.isEmpty
              ? const Center(child: Text('لا يوجد مستخدمين متاحين للإضافة'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1B4332),
                          child: Text(
                            user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(user.fullName.isNotEmpty ? user.fullName : 'مستخدم بدون اسم'),
                        subtitle: Text(user.email),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _showAddMemberDialog(user);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4332),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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

  void _showAddMemberDialog(UserModel user) {
    String selectedRole = 'عضو';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('إضافة عضو جديد'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName.isNotEmpty ? user.fullName : user.email,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'عضو', child: Text('عضو')),
                      DropdownMenuItem(value: 'مشرف', child: Text('مشرف')),
                      DropdownMenuItem(value: 'مدير مالي', child: Text('مدير مالي')),
                    ],
                    onChanged: (v) => setStateDialog(() => selectedRole = v!),
                    decoration: const InputDecoration(
                      labelText: 'الدور',
                      border: OutlineInputBorder(),
                    ),
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
                    _addMember(user, selectedRole);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4332),
                  ),
                  child: const Text('إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}