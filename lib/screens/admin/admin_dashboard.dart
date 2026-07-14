import 'package:flutter/material.dart';
import 'admin_organizations_screen.dart';
import 'admin_users_screen.dart';
import 'admin_donations_screen.dart';
import 'admin_pending_orgs_screen.dart';
import '../../services/admin_service.dart';
import '../auth/login_screen.dart'; // استيراد شاشة تسجيل الدخول المذكورة في شجرتك

class AdminDashboard extends StatelessWidget {
  final String adminToken;
  const AdminDashboard({Key? key, required this.adminToken}) : super(key: key);

  // دالة معالجة تسجيل الخروج
  void _handleLogout(BuildContext context) async {
    // إظهار مؤشر انتظار
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B4332)),
        ),
      ),
    );

    try {
      final adminService = AdminService();
      // استدعاء الدالة من ملف admin_service.dart المرفق مسبقاً
      await adminService.logout(adminToken: adminToken);

      // إغلاق الديالوج ونقل المستخدم لشاشة تسجيل الدخول وتنظيف الـ Stack
      Navigator.of(context).pop();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      // إغلاق الديالوج وعرض الخطأ إن وجد
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تسجيل الخروج: $e'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة تحكم الإشراف '),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => _handleLogout(context), // ربط الأكشن هنا
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بنر ترحيبي بهوية إسلامية واقتباس
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مرحباً بك في لوحة الإشراف',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ' قال تعالى: "وَمَا تَفْعَلُوا مِنْ خَيْرٍ فَإِنَّ اللَّهَ بِهِ عَلِيمٌ"',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'الإحصائيات العامة والمتابعة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332),
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildDashboardCard(
                    context,
                    title: 'طلبات الانضمام المعلقة',
                    icon: Icons.hourglass_empty_rounded,
                    color: const Color(0xFFD4AF37),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminPendingOrgsScreen(adminToken: adminToken),
                      ),
                    ),
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'إدارة الجمعيات والمؤسسات',
                    icon: Icons.corporate_fare_rounded,
                    color: const Color(0xFF1B4332),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminOrganizationsScreen(adminToken: adminToken),
                      ),
                    ),
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'سجل التبرعات والصدقات',
                    icon: Icons.volunteer_activism_rounded,
                    color: const Color(0xFF2A9D8F),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminDonationsScreen(adminToken: adminToken),
                      ),
                    ),
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'المستخدمين والكفلاء',
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF457B9D),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminUsersScreen(adminToken: adminToken),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 3,
        shadowColor: color.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2D42),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
