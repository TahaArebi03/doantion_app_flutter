import 'package:flutter/material.dart';
import '../../models/organization_model.dart';
import '../../services/member_service.dart';
import '../../themes/app_theme.dart';

class OrganizationDetailScreen extends StatefulWidget {
  final Organization organization;
  const OrganizationDetailScreen({super.key, required this.organization});

  @override
  State<OrganizationDetailScreen> createState() =>
      _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen> {
  late Organization? _organization;
  late MemberService _memberService;
  String? _requestStatus; // pending, approved, rejected, null
  bool _isLoadingRequest = false;

  @override
  void initState() {
    super.initState();
    _organization = widget.organization;
    _memberService = MemberService('your_token_here');
    _fetchOrganizationDetails();
    _fetchRequestStatus();
  }

  Future<void> _fetchOrganizationDetails() async {
    if (_organization == null) return;
    try {
      // يمكنك إضافة منطق جلب تفاصيل الجمعية هنا
      setState(() {
        _organization = _organization;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل التفاصيل: $e')));
    }
  }

  Future<void> _fetchRequestStatus() async {
    if (_organization == null) return;
    try {
      final status = await _memberService.getUserRequestStatus(
        _organization!.id,
      );
      setState(() => _requestStatus = status);
    } catch (e) {
      _requestStatus = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // نفترض أن الـ organization يحتوي على 'role' قادم من الـ API
    // يمكنك تعديل الموديل ليشمل role
    final String role = 'مدير مشاريع'; // هذا سيأتي من API في المستقبل

    return Scaffold(
      appBar: AppBar(title: Text('صلاحياتي في ${_organization!.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.verified_user,
                    color: AppTheme.primaryGold,
                  ),
                  title: const Text('دوري في الجمعية'),
                  subtitle: Text(role),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'الصلاحيات المتاحة:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // أزرار الصلاحيات - تظهر حسب role
              if (role == 'مدير مشاريع' || role == 'مدير')
                _buildPermissionButton(
                  Icons.add_box,
                  'إضافة مشروع جديد',
                  () {},
                ),
              if (role == 'مدير' || role == 'مشرف')
                _buildPermissionButton(Icons.people, 'إدارة الأعضاء', () {}),
              if (role == 'مدير')
                _buildPermissionButton(
                  Icons.settings,
                  'إعدادات الجمعية',
                  () {},
                ),
              _buildPermissionButton(
                Icons.payments,
                'عرض التقارير المالية',
                () {},
              ),
              const SizedBox(height: 16),
              _buildJoinButton(),
            ],
          ),
        ),
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
    if (_isLoadingRequest) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_organization?.isMember == true) {
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
    if (_requestStatus == 'pending') {
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
        setState(() => _isLoadingRequest = true);
        try {
          await _memberService.submitJoinRequest(_organization!.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تقديم طلبك بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          await _fetchRequestStatus();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل تقديم الطلب: $e'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          setState(() => _isLoadingRequest = false);
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
