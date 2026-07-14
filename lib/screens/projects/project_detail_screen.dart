import 'package:flutter/material.dart';
import '../../models/project_model.dart'; // تأكد من استيراد النموذج

class ProjectDetailScreen extends StatelessWidget {
  final ProjectModel project; // تغيير من Map إلى ProjectModel

  const ProjectDetailScreen({Key? key, required this.project})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخراج القيم من الكائن مباشرة
    final String title = project.title;
    final String description = project.description;
    final double goal = project.goal_amount;
    final double balance = project.balance;
    final double remaining = goal - balance;
    final String status = project.status;
    final List<String> images = project.images;

    // حساب النسبة المئوية
    double progress = goal > 0 ? (balance / goal) : 0.0;
    if (progress > 1.0) progress = 1.0;
    final int percent = (progress * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F4), // نفس خلفية التطبيق
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- صورة الغلاف (إن وجدت) ---
            if (images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  images.first,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 60),
                  ),
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1B4332).withOpacity(0.1),
                      const Color(0xFFD4AF37).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.assignment_outlined,
                    size: 60,
                    color: Color(0xFF1B4332),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // --- العنوان ---
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 8),

            // --- الحالة (Chip) ---
            Chip(
              label: Text(
                _getArabicStatus(status),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: _getStatusColor(status),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            const SizedBox(height: 16),

            // --- الوصف ---
            const Text(
              'نبذة عن المشروع:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description.isNotEmpty ? description : 'لا يوجد وصف متاح.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),

            // --- شريط التقدم والنسبة ---
            const Text(
              'نسبة الإنجاز:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                Text(
                  '${balance.toStringAsFixed(0)} د.ل / ${goal.toStringAsFixed(0)} د.ل',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFFD4AF37),
              minHeight: 10,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 24),

            // --- البطاقات المالية ---
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    title: 'المبلغ المستهدف',
                    value: '${goal.toStringAsFixed(0)} د.ل',
                    icon: Icons.flag,
                    color: const Color(0xFF1B4332),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    title: 'المبلغ المتبرع به',
                    value: '${balance.toStringAsFixed(0)} د.ل',
                    icon: Icons.attach_money,
                    color: const Color(0xFF2A9D8F),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    title: 'المتبقي',
                    value: '${remaining.toStringAsFixed(0)} د.ل',
                    icon: Icons.timeline,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- صور إضافية (اختياري) ---
            if (images.length > 1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'صور إضافية:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length - 1,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              images[index + 1],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لبطاقة المعلومات المالية
  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFD4AF37), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دوال مساعدة للحالة (نفس التي في الصفحة الرئيسية)
  Color _getStatusColor(String status) {
    if (status == 'active') return Colors.green;
    if (status == 'completed') return Colors.blue;
    return Colors.red;
  }

  String _getArabicStatus(String status) {
    if (status == 'active') return 'نشط حالياً';
    if (status == 'completed') return 'مكتمل / ناجح';
    return 'ملغي';
  }
}