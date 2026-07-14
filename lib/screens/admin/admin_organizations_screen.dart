import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'admin_organization_detail_screen.dart'; // تأكد من استيراد شاشة التفاصيل الثلاثية

class AdminOrganizationsScreen extends StatefulWidget {
  final String adminToken;

  const AdminOrganizationsScreen({Key? key, required this.adminToken})
    : super(key: key);

  @override
  State<AdminOrganizationsScreen> createState() =>
      _AdminOrganizationsScreenState();
}

class _AdminOrganizationsScreenState extends State<AdminOrganizationsScreen> {
  final AdminService _adminService = AdminService();

  List<dynamic> _organizations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAcceptedOrganizations();
  }

  // جلب قائمة الجمعيات المعتمدة من السيرفر
  Future<void> _fetchAcceptedOrganizations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // استدعاء الدالة المسؤولة عن جلب الجمعيات
      final data = await _adminService.getApprovedOrganizations(
        adminToken: widget.adminToken,
      );

      setState(() {
        _organizations = data
            .where((org) => org['status'] == 'approved')
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'حدث خطأ أثناء تحميل قائمة الجمعيات، تأكد من الاتصال بالسيرفر';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // الهوية البصرية الموحدة للتطبيق (الأخضر الإسلامي والذهبي العتيق)
    const Color primaryIslamicColor = Color(0xFF1B4332);
    const Color goldAccent = Color(0xFFD4AF37);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(
          0xFFF9F8F4,
        ), // الخلفية العاجية المريحة للعين
        appBar: AppBar(
          title: const Text(
            'الجمعيات المعتمدة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Tajawal', // إذا كنت تستخدم خط تاجويل
            ),
          ),
          backgroundColor: primaryIslamicColor,
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _fetchAcceptedOrganizations,
            ),
          ],
        ),
        body: _buildBody(primaryIslamicColor, goldAccent),
      ),
    );
  }

  Widget _buildBody(Color primaryColor, Color accentColor) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _fetchAcceptedOrganizations,
              ),
            ],
          ),
        ),
      );
    }

    if (_organizations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gavel_rounded, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'لا توجد جمعيات مقبولة أو مسجلة بالنظام حالياً',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _organizations.length,
      itemBuilder: (context, index) {
        final org = _organizations[index];
        final int orgId = org['id'];
        final String name = org['name'] ?? 'جمعية خيرية غير مسمية';
        final String type = org['type'] ?? 'غير محدد';
        final String description =
            org['description'] ?? 'لا يوجد وصف متاح لهذه الجمعية حالياً.';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الشريط العلوي الملون داخل البطاقة لإعطاء طابع الفخامة
                Container(height: 4, color: accentColor),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          // شارة الحالة (مقبولة / نشطة)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 3,
                                  backgroundColor: Colors.green,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'معتمدة',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // نوع وتصنيف الجمعية مع الأيقونة الخاصة به
                      Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 16,
                            color: accentColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'المجال: $type',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // وصف ومقدمة عن الجمعية الخيرية
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, thickness: 0.6),
                      ),
                      // قسم التحكم والولوج للتفاصيل
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(
                              Icons.analytics_outlined,
                              size: 18,
                            ),
                            label: const Text(
                              'عرض التفاصيل والتقارير',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            onPressed: () {
                              // 💡 الانتقال السلس لشاشة التفاصيل الثلاثية وتمرير المعطيات
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AdminOrganizationDetailScreen(
                                        adminToken: widget.adminToken,
                                        orgId: orgId,
                                      ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
