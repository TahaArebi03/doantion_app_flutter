import 'package:flutter/material.dart';
import '../../models/organization_model.dart';
import '../../services/member_service.dart';
import '../../themes/app_theme.dart';
import '../../services/join_request_service.dart';
import '../../models/member_model.dart';
import '../../services/project_service.dart';

class OrganizationDetailScreen extends StatefulWidget {
  final Organization organization;
  final String? token;

  const OrganizationDetailScreen({
    super.key,
    required this.organization,
    this.token,
  });

  @override
  State<OrganizationDetailScreen> createState() =>
      _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen> {
  late Organization? _organization;

  late JoinRequestService _joinRequestService;
  String? _requestStatus; // pending, approved, rejected, null
  bool _isLoadingRequest = false;

  List<dynamic> _projects = [];
  List<MemberModel> _members = [];
  bool _isLoadingProjects = false;
  bool _isLoadingMembers = false;
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  void _showSnackBar(String message, Color color) {
    _messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void initState() {
    super.initState();
    _organization = widget.organization;
    _joinRequestService = JoinRequestService(widget.token ?? '');
    _fetchOrganizationDetails();
    _fetchRequestStatus();
    _fetchOrganizationProjects();
    _fetchOrganizationMembers();
  }

  Future<void> _fetchOrganizationDetails() async {
    if (_organization == null) return;
    try {
      setState(() {
        _organization = _organization;
      });
    } catch (e) {
      _showSnackBar('خطأ في تحميل التفاصيل: $e', Colors.red);
    }
  }

  Future<void> _fetchOrganizationProjects() async {
    if (_organization == null) return;
    setState(() => _isLoadingProjects = true);
    try {
      final service = ProjectService(token: widget.token ?? '');
      final projects = await service.getProjectsForOrganization(
        _organization!.id,
      );
      if (mounted) setState(() => _projects = projects);
    } catch (e) {
      if (mounted) setState(() => _projects = []);
      if (mounted) {
        _showSnackBar('فشل جلب المشاريع: $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoadingProjects = false);
    }
  }

  Future<void> _fetchOrganizationMembers() async {
    if (_organization == null) return;
    setState(() => _isLoadingMembers = true);
    try {
      final service = MemberService(widget.token ?? '');
      final members = await service.getMembers(_organization!.id);
      if (mounted) setState(() => _members = members);
    } catch (e) {
      if (mounted) setState(() => _members = []);
      if (mounted) {
        _showSnackBar('فشل جلب الأعضاء: $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoadingMembers = false);
    }
  }

  Future<void> _fetchRequestStatus() async {
    if (_organization == null) return;
    setState(() => _isLoadingRequest = true);
    try {
      final status = await _joinRequestService.getRequestStatus(
        _organization!.id,
      );
      if (mounted) setState(() => _requestStatus = status);
    } catch (e) {
      if (mounted) _showSnackBar('خطأ في جلب حالة الطلب: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoadingRequest = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final organization = _organization ?? widget.organization;

    return DefaultTabController(
      length: 3,
      child: ScaffoldMessenger(
        key: _messengerKey,
        child: Scaffold(
          appBar: AppBar(
            title: Text(organization.name),
            backgroundColor: Colors.grey.shade800,
            foregroundColor: Colors.white,
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.info_outline), text: 'المعلومات'),
                Tab(icon: Icon(Icons.assignment_outlined), text: 'المشاريع'),
                Tab(icon: Icon(Icons.people_alt_outlined), text: 'الأعضاء'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildInfoTab(organization),
              _buildProjectsTab(),
              _buildMembersTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTab(Organization organization) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(organization),
            const SizedBox(height: 20),
            _buildInfoTile(
              icon: Icons.info_outline,
              title: 'الوصف',
              value: organization.description.isNotEmpty
                  ? organization.description
                  : 'لا يوجد وصف متاح',
            ),
            _buildInfoTile(
              icon: Icons.category,
              title: 'نوع الجمعية',
              value: organization.type ?? 'غير محدد',
            ),
            _buildInfoTile(
              icon: Icons.verified,
              title: 'الحالة',
              value: organization.status ?? 'غير محدد',
            ),
            _buildInfoTile(
              icon: Icons.people,
              title: 'عدد الأعضاء',
              value: '${organization.membersCount ?? _members.length}',
            ),
            _buildInfoTile(
              icon: Icons.assignment,
              title: 'عدد المشاريع',
              value: '${organization.projectsCount ?? _projects.length}',
            ),
            const SizedBox(height: 20),
            _buildJoinButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsTab() {
    if (_isLoadingProjects) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_projects.isEmpty) {
      return const Center(child: Text('لا توجد مشاريع في هذه الجمعية حالياً'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _projects.length,
      itemBuilder: (context, index) {
        final project = _projects[index];
        final progress = (project.goal_amount > 0)
            ? (project.balance / project.goal_amount).clamp(0.0, 1.0)
            : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(progress * 100).round()}%'),
                    Text(
                      '${project.balance.toStringAsFixed(0)} / ${project.goal_amount.toStringAsFixed(0)} د.ل',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.green.shade700,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMembersTab() {
    if (_isLoadingMembers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_members.isEmpty) {
      return const Center(child: Text('لا يوجد أعضاء مسجلين في هذه الجمعية'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade700,
              child: Text(
                member.fullName.isNotEmpty ? member.fullName[0] : 'U',
              ),
            ),
            title: Text(member.fullName),
            subtitle: Text(member.email),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                MemberModel.translateRole(member.role),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(Organization organization) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  organization.image != null && organization.image!.isNotEmpty
                  ? Image.network(
                      organization.image!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72,
                        height: 72,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.business, size: 30),
                      ),
                    )
                  : Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.business, size: 30),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organization.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    organization.ownerName ?? 'مالك الجمعية غير محدد',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGold),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildPermissionButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGold),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildJoinButton() {
    final organization = _organization ?? widget.organization;

    if (_isLoadingRequest) {
      return const Center(child: CircularProgressIndicator());
    }

    if (organization.isMember || _requestStatus == 'approved') {
      return const Card(
        color: Colors.green,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              'أنت عضو في هذه الجمعية',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    if (_requestStatus == 'pending' ||
        organization.volunteerStatus == 'pending') {
      return const Card(
        color: Colors.orange,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              'طلبك قيد المراجعة',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () async {
        if ((widget.token ?? '').trim().isEmpty) {
          _showSnackBar(
            'يجب تسجيل الدخول أولاً لتقديم طلب الانضمام',
            Colors.orange,
          );
          return;
        }

        if (!mounted) return;
        setState(() => _isLoadingRequest = true);
        try {
          await _joinRequestService.sendRequest(organization.id);
          if (mounted) {
            _showSnackBar('تم تقديم طلبك بنجاح', Colors.green);
          }
          await _fetchRequestStatus();
          if (mounted) {
            setState(() {
              _organization = Organization(
                id: organization.id,
                name: organization.name,
                description: organization.description,
                image: organization.image,
                isFollowed: organization.isFollowed,
                isMember: false,
                volunteerStatus: 'pending',
                membersCount: organization.membersCount,
                projectsCount: organization.projectsCount,
                ownerId: organization.ownerId,
                ownerName: organization.ownerName,
                ownerEmail: organization.ownerEmail,
                type: organization.type,
                status: organization.status,
              );
            });
          }
        } catch (e) {
          if (mounted) {
            _showSnackBar('فشل تقديم الطلب: $e', Colors.red);
          }
        } finally {
          if (mounted) {
            setState(() => _isLoadingRequest = false);
          }
        }
      },
      icon: const Icon(Icons.how_to_reg),
      label: const Text('تقديم طلب انضمام'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}
