import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  final String adminToken;

  const AdminUsersScreen({super.key, required this.adminToken});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await _adminService.getUsers(
        adminToken: widget.adminToken,
      );
      if (mounted) {
        setState(() {
          _users = result;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // دالة ذكية لتحديد لون الشارة واسم الدور بالعربية بناءً على قيمة الـ role
  Widget _buildRoleBadge(String? role) {
    String roleName = 'مستخدم';
    Color badgeColor = const Color(0xFF457B9D); // لون أزرق افتراضي

    if (role != null) {
      switch (role.toLowerCase()) {
        case 'admin':
          roleName = 'مشرف نظام';
          badgeColor = const Color(0xFF1B4332); // أخضر فخم
          break;
        case 'donor':
        case 'kofil':
          roleName = 'كفيل / متبرع';
          badgeColor = const Color(0xFF2A9D8F); // تيل / أخضر فاتح
          break;
        case 'organization':
          roleName = 'جمعية خيرية';
          badgeColor = const Color(0xFFD4AF37); // ذهبي
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        roleName,
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryIslamicColor = Color(0xFF1B4332);
    const Color goldAccent = Color(0xFFD4AF37);

    return Directionality(
      textDirection: TextDirection.rtl, // دعم كامل ومثالي للغة العربية
      child: Scaffold(
        backgroundColor: const Color(
          0xFFF9F8F4,
        ), // الخلفية العاجية الموحدة للمشروع
        appBar: AppBar(
          title: const Text(
            'إدارة المستخدمين والكفلاء',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: primaryIslamicColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    primaryIslamicColor,
                  ),
                ),
              )
            : _users.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 70,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا يوجد مستخدمون مسجلون حالياً',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  final String firstName = user['firstName'] ?? '';
                  final String lastName = user['lastName'] ?? '';
                  final String fullName =
                      (firstName.isEmpty && lastName.isEmpty)
                      ? 'مستخدم كريم'
                      : '$firstName $lastName'.trim();

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 2,
                    shadowColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: goldAccent.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // الصورة الرمزية للمستخدم (Avatar) بستايل متناسق
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryIslamicColor.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: primaryIslamicColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // بيانات المستخدم الشخصية
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF2B2D42),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user['email'] ?? 'لا يوجد بريد إلكتروني',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // شارة نوع الحساب (Role Badge)
                          _buildRoleBadge(user['role']?.toString()),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
