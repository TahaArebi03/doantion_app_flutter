import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminDonationsScreen extends StatefulWidget {
  final String adminToken;

  const AdminDonationsScreen({super.key, required this.adminToken});

  @override
  State<AdminDonationsScreen> createState() => _AdminDonationsScreenState();
}

class _AdminDonationsScreenState extends State<AdminDonationsScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _donations = [];
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
      final result = await _adminService.getDonations(
        adminToken: widget.adminToken,
      );
      if (mounted) {
        setState(() {
          _donations = result;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // دالة مساعدة لتنسيق النصوص البرمجية للتواريخ بشكل مبسط
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'تاريخ غير محدد';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}/${date.month}/${date.day} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr.split('T').first; // حل احتياطي لعرض التاريخ فقط
    }
  }

  @override
  Widget build(BuildContext context) {
    // الهوية اللونية الموحدة للمشروع
    const Color primaryIslamicColor = Color(0xFF1B4332);
    const Color goldAccent = Color(0xFFD4AF37);
    const Color moneyGreen = Color(0xFF2A9D8F);

    return Directionality(
      textDirection: TextDirection.rtl, // دعم كامل للغة العربية
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F8F4), // الخلفية العاجية الدافئة
        appBar: AppBar(
          title: const Text(
            'سجل التبرعات والصدقات',
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
                  valueColor: AlwaysStoppedAnimation<Color>(primaryIslamicColor),
                ),
              )
            : _donations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volunteer_activism_rounded, size: 70, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد عمليات تبرع مسجلة حالياً',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _donations.length,
                    itemBuilder: (context, index) {
                      final donation = _donations[index];
                      final double amount = double.tryParse(donation['amount']?.toString() ?? '0') ?? 0.0;
                      
                      // جلب تفاصيل إضافية إن كانت متوفرة بالـ API
                      final String donorName = donation['donor_name'] ?? donation['user']?['name'] ?? 'متبرع كريم';
                      final String orgName = donation['organization_name'] ?? donation['organization']?['name'] ?? 'جهة عامة / أوقاف';

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        shadowColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: goldAccent.withOpacity(0.15), width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // أيقونة صدقة/تبرع دائرية
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: moneyGreen.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: moneyGreen,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              // تفاصيل العملية المالية
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      donorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF2B2D42),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'إلى: $orgName',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // التاريخ والوقت
                                    Row(
                                      children: [
                                        Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDate(donation['created_at']?.toString()),
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // شارة المبلغ المالي الفخمة (Badge)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: moneyGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${amount.toStringAsFixed(0)} ر.س', // قمنا بإلغاء الكسور الطويلة المزعجة بصرياً
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
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