import 'package:flutter/material.dart';
import 'admin_organization_detail_screen.dart';
import '../../services/admin_service.dart';

class AdminPendingOrgsScreen extends StatefulWidget {
  final String adminToken;
  const AdminPendingOrgsScreen({Key? key, required this.adminToken})
    : super(key: key);

  @override
  State<AdminPendingOrgsScreen> createState() => _AdminPendingOrgsScreenState();
}

class _AdminPendingOrgsScreenState extends State<AdminPendingOrgsScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> pendingOrgs = [];
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
      final result = await _adminService.getPendingOrganizations(
        adminToken: widget.adminToken,
      );
      if (mounted) {
        setState(() {
          pendingOrgs = result;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    // تحديد الألوان الثابتة للهوية الإسلامية
    const Color primaryIslamicColor = Color(0xFF1B4332); // الأخضر الفاخر
    const Color goldAccent = Color(0xFFD4AF37); // الذهبي المطفي

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F8F4), // خلفية عاجية مريحة للعين
        appBar: AppBar(
          title: const Text(
            'طلبات الاعتماد المعلقة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          backgroundColor: primaryIslamicColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    primaryIslamicColor,
                  ),
                ),
              )
            : pendingOrgs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_turned_in_rounded,
                      size: 70,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد طلبات معلقة حالياً',
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
                itemCount: pendingOrgs.length,
                itemBuilder: (context, index) {
                  final org = pendingOrgs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shadowColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: goldAccent.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // القسم العلوي: الهوية والمعلومات
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: primaryIslamicColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.account_balance_rounded,
                                  color: primaryIslamicColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      org['name'] ?? 'جمعية خيرية غير مسمية',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF2B2D42),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // شارة توضح حالة "قيد الانتظار"
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: goldAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text(
                                  'قيد المراجعة',
                                  style: TextStyle(
                                    color: Color(0xFFB58900),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                          ),
                          // القسم السفلي: أزرار التحكم والعمليات
                          Row(
                            children: [
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  size: 18,
                                  color: Color(0xFF457B9D),
                                ),
                                label: const Text(
                                  'تفاصيل الطلب',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF457B9D),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AdminOrganizationDetailScreen(
                                            adminToken: widget.adminToken,
                                            orgId: org['id'],
                                          ),
                                    ),
                                  );
                                },
                              ),
                              const Spacer(),
                              // زر الرفض بستايل متناسق ونظيف
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                  side: BorderSide(color: Colors.red.shade200),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: () {
                                  _adminService
                                      .rejectOrganization(
                                        adminToken: widget.adminToken,
                                        id: org['id'],
                                      )
                                      .then((_) {
                                        _showSnackBar(
                                          'تم رفض طلب الانضمام بنجاح',
                                        );
                                        _loadData();
                                      })
                                      .catchError((error) {
                                        _showSnackBar(
                                          'حدث خطأ أثناء رفض الطلب',
                                          isError: true,
                                        );
                                      });
                                },
                                child: const Text(
                                  'رفض',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // زر القبول والاعتماد الفخم الأخضر
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryIslamicColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: () {
                                  _adminService
                                      .approveOrganization(
                                        adminToken: widget.adminToken,
                                        id: org['id'],
                                      )
                                      .then((_) {
                                        _showSnackBar(
                                          'تم اعتماد وقبول الجمعية بنجاح ',
                                        );
                                        _loadData();
                                      })
                                      .catchError((error) {
                                        _showSnackBar(
                                          'حدث خطأ أثناء قبول الجمعية',
                                          isError: true,
                                        );
                                      });
                                },
                                child: const Text(
                                  'قبول واعتماد',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
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
