import 'package:flutter/material.dart';
import '../../models/organization_model.dart';
import '../../themes/app_theme.dart';


class OrganizationDetailScreen extends StatelessWidget {
  final Organization organization;
  const OrganizationDetailScreen({super.key, required this.organization});

  @override
  Widget build(BuildContext context) {
    // نفترض أن الـ organization يحتوي على 'role' قادم من الـ API
    // يمكنك تعديل الموديل ليشمل role
    final String role = 'مدير مشاريع'; // هذا سيأتي من API في المستقبل

    return Scaffold(
      appBar: AppBar(title: Text('صلاحياتي في ${organization.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
              _buildPermissionButton(Icons.add_box, 'إضافة مشروع جديد', () {}),
            if (role == 'مدير' || role == 'مشرف')
              _buildPermissionButton(Icons.people, 'إدارة الأعضاء', () {}),
            if (role == 'مدير')
              _buildPermissionButton(Icons.settings, 'إعدادات الجمعية', () {}),
            _buildPermissionButton(
              Icons.payments,
              'عرض التقارير المالية',
              () {},
            ),
          ],
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
}
