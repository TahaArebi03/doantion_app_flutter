import 'package:flutter/material.dart';
import '../../widgets/project_card.dart';
import '../../widgets/organization_card.dart';
import '../../widgets/member_card.dart';
import '../../services/admin_service.dart';
import '../../models/project_model.dart';

import '../../services/project_service.dart';
import '../projects/project_detail_screen.dart';

class AdminOrganizationDetailScreen extends StatefulWidget {
  final int orgId;
  final String? adminToken;

  const AdminOrganizationDetailScreen({
    Key? key,
    this.adminToken,
    required this.orgId,
  }) : super(key: key);

  @override
  State<AdminOrganizationDetailScreen> createState() =>
      _AdminOrganizationDetailScreenState();
}

class _AdminOrganizationDetailScreenState
    extends State<AdminOrganizationDetailScreen> {
  // إنشاء نسخة من كلاس الخدمات
  final AdminService _adminServices = AdminService();
  final ProjectService _projectService = ProjectService();
  bool _isLoading = true;
  late String safeToken;
  Map<String, dynamic>? _orgData;
  List<ProjectModel> _orgProjects = [];

  bool _isProjectsLoading = true;
  String? _projectsErrorMessage;

  @override
  void initState() {
    super.initState();
    safeToken = widget.adminToken ?? 'no_token';
    _fetchOrganizationDetails();
    _fetchOrganizationProjects();
  }

  // دالة مساعدة لإظهار الرسائل بستايل أنيق
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isError
            ? Colors.red.shade800
            : const Color(0xFF2A9D8F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // دالة جلب البيانات باستخدام ملف الخدمات
  Future<void> _fetchOrganizationDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _projectsErrorMessage = null;
      });
      final data = await _adminServices.getOrganizationDetails(
        adminToken: safeToken,
        id: widget.orgId,
      );

      setState(() {
        _orgData = data['organization'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _projectsErrorMessage = 'حدث خطأ أثناء جلب بيانات المشاريع: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchOrganizationProjects() async {
    try {
      setState(() {
        _isProjectsLoading = true;
        _projectsErrorMessage = null;
      });
      final projectsData = await _projectService.getProjectsForOrganization(
        widget.orgId,
      );
      setState(() {
        _orgProjects = projectsData; // أصبحت من النوع List<ProjectModel>
        _isProjectsLoading = false;
      });
    } catch (e) {
      setState(() {
        _projectsErrorMessage = 'فشل في تحميل مشاريع الجمعية';
        _isProjectsLoading = false;
      });
    }
  }

  Widget build(BuildContext context) {
    const Color primaryIslamicColor = Color(0xFF1B4332);
    const Color goldAccent = Color(0xFFD4AF37);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3, // 3 تبويبات: البيانات، المشاريع، الأعضاء
        child: Scaffold(
          backgroundColor: const Color(0xFFF9F8F4), // خلفية عاجية مريحة
          appBar: AppBar(
            title: const Text(
              'إدارة وتفاصيل الجمعية',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            backgroundColor: primaryIslamicColor,
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            bottom: const TabBar(
              indicatorColor: goldAccent,
              labelColor: goldAccent,
              unselectedLabelColor: Colors.white70,
              indicatorWeight: 3,
              tabs: [
                Tab(icon: Icon(Icons.info_outline), text: 'بيانات الجمعية'),
                Tab(icon: Icon(Icons.assignment_outlined), text: 'المشاريع'),
                Tab(icon: Icon(Icons.people_outline), text: 'الأعضاء'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildInfoTab(context),
              _buildProjectsTab(context),
              _buildMembersTab(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. تبويب بيانات الجمعية مع تصحيح صياغة الأزرار
  Widget _buildInfoTab(BuildContext context) {
    if (_orgData == null) {
    return const Center(child: CircularProgressIndicator());
  }

  final Map<String, dynamic> org = _orgData!;
    // قراءة البيانات بناءً على الهيكل الراجع من السيرفر الخاص بك
    final orgId = _orgData?['id'] ?? 0;
    final name = _orgData?['name'] ?? 'لا يوجد اسم رسمي';
    final description = _orgData?['description'] ?? 'لا يوجد وصف متاح';
    final type = _orgData?['type'] ?? 'غير محدد';
    final status = _orgData?['status'] ?? 'غير معروف';

    // قراءة بيانات مالك الجمعية (owner) الراجعة مع العلاقة (with)
    final owner = _orgData?['owner'];
    final ownerName = owner != null
        ? '${owner['firstName'] ?? ''} ${owner['lastName'] ?? ''}'
        : 'غير متوفر';
    final ownerEmail = owner?['email'] ?? 'غير متوفر';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shadowColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              // أزلنا الـ const من هنا تماماً
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.business,
                      color: Color(0xFF1B4332),
                    ),
                    title: const Text(
                      'الاسم الرسمي للجمعية',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(name),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.merge_type,
                      color: Color(0xFF1B4332),
                    ),
                    title: const Text(
                      'نوع الجمعية',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(type),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF1B4332),
                    ),
                    title: const Text(
                      'حالة الحساب حالياً',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      status,
                      style: TextStyle(
                        color: status == 'active' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.description_outlined,
                      color: Color(0xFF1B4332),
                    ),
                    title: const Text(
                      'الوصف / نبذة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(description),
                  ),
                  const Divider(height: 24, thickness: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF1B4332),
                    ),
                    title: const Text(
                      'مالك الجمعية / المسؤول',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('$ownerName\n($ownerEmail)'),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // صف الأزرار لتعطيل أو حذف الجمعية
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  // زر تعطيل مؤقت
onPressed: () async {
  try {
    setState(() {
      _isLoading = true; // لإظهار مؤشر تحميل إذا أردت
    });
    await _adminServices.pendingOrganization(adminToken: safeToken, id: orgId);
    await _fetchOrganizationDetails(); // تحديث بيانات الجمعية
    await _fetchOrganizationProjects(); // تحديث المشاريع
    _showSnackBar('تم تعطيل الجمعية مؤقتاً بنجاح');
  } catch (error) {
    _showSnackBar('حدث خطأ أثناء تعطيل الجمعية', isError: true);
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
},
                  child: const Text(
                    'تعطيل مؤقت',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  // زر حذف نهائي
onPressed: () async {
  try {
    setState(() => _isLoading = true);
    await _adminServices.rejectOrganization(adminToken: safeToken, id: orgId);
    await _fetchOrganizationDetails();
    await _fetchOrganizationProjects();
    _showSnackBar('تم رفض طلب الانضمام بنجاح');
  } catch (error) {
    _showSnackBar('حدث خطأ أثناء رفض الطلب', isError: true);
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
},
                  child: const Text(
                    'حذف نهائي',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  // زر اعتماد وقبول
onPressed: () async {
  try {
    setState(() => _isLoading = true);
    await _adminServices.approveOrganization(adminToken: safeToken, id: orgId);
    await _fetchOrganizationDetails();
    await _fetchOrganizationProjects();
    _showSnackBar('تم اعتماد الجمعية بنجاح');
  } catch (error) {
    _showSnackBar('حدث خطأ أثناء اعتماد الجمعية', isError: true);
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
},
                  child: const Text(
                    'اعتماد وقبول',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. تبويب المشاريع
  Widget _buildProjectsTab(BuildContext context) {
    if (_isProjectsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1B4332)),
      );
    }
    if (_projectsErrorMessage != null) {
      return Center(
        child: Text(
          _projectsErrorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }
    if (_orgProjects.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد مشاريع مضافة لهذه الجمعية حالياً',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orgProjects.length,
      itemBuilder: (context, index) {
        final project = _orgProjects[index];
        final double goal = project.goal_amount;
        final double balance = project.balance;
        final double remaining = goal - balance;
        final String title = project.title;
        final String status = project.status;
        final String description = project.description;

        // نسبة التقدم
        double progress = goal > 0 ? (balance / goal) : 0.0;
        if (progress > 1.0) progress = 1.0;
        final int percent = (progress * 100).round();

        // الصورة المصغرة (اختيار الأولى من القائمة)
        String? imageUrl = project.images.isNotEmpty
            ? project.images.first
            : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Card(
            elevation: 0, // نعتمد على الظل الخارجي
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFD4AF37), width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // قسم الصورة (إن وجدت)
                  if (imageUrl != null)
                    Stack(
                      children: [
                        Image.network(
                          imageUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 150,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              (status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    // إذا لم توجد صورة، نضع لون خلفية مع الحالة
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1B4332).withOpacity(0.1),
                            const Color(0xFFD4AF37).withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.assignment_outlined,
                              size: 40,
                              color: Color(0xFF1B4332),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                (status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // المحتوى النصي
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // العنوان
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B4332),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // الوصف
                        if (description.isNotEmpty)
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        const SizedBox(height: 16),
                        // النسبة المئوية وشريط التقدم
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'نسبة الإنجاز',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '$percent%',
                              style: const TextStyle(
                                color: Color(0xFF1B4332),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFFD4AF37),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        const SizedBox(height: 16),
                        // المبالغ المالية بأيقونات
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFinancialItem(
                              Icons.flag,
                              'المستهدف',
                              '${goal.toStringAsFixed(0)} د.ل',
                            ),
                            _buildFinancialItem(
                              Icons.attach_money,
                              'المجموع',
                              '${balance.toStringAsFixed(0)} د.ل',
                            ),
                            _buildFinancialItem(
                              Icons.timeline,
                              'المتبقي',
                              '${remaining.toStringAsFixed(0)} د.ل',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // زر تفاصيل (يمكن تفعيله لاحقاً)
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: TextButton.icon(
                            // داخل زر TextButton.icon
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectDetailScreen(project: project),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Color(0xFFD4AF37),
                            ),
                            label: const Text(
                              'عرض التفاصيل',
                              style: TextStyle(
                                color: Color(0xFF1B4332),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF1B4332),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: const BorderSide(
                                  color: Color(0xFFD4AF37),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // تحديث _buildFinancialItem لتقبل أيقونة
  Widget _buildFinancialItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFFD4AF37)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4332),
          ),
        ),
      ],
    );
  }

  // 3. تبويب الأعضاء
  Widget _buildMembersTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: 2,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFF1B4332),
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
            index == 0
                ? 'الشيخ عبد الله أحمد (مدير الجمعية)'
                : 'م. محمد علي (مشرف مشاريع)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: const Text(
            'صلاحيات إدارة كاملة',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}
