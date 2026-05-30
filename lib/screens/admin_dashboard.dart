import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminDashboard extends StatefulWidget {
  final String adminToken;

  const AdminDashboard({Key? key, required this.adminToken}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // القسم الحالي المحدد في القائمة الجانبية
  String _currentSection = 'pending_orgs';

  List<dynamic> _dataList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(); // جلب البيانات عند فتح الصفحة أول مرة
  }

  // دالة ديناميكية لجلب البيانات بناءً على القسم المحدد ومسارات لارافيل
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    String endpoint = '';
    switch (_currentSection) {
      case 'pending_orgs':
        endpoint = '/api/admin/organizations/pending';
        break;
      case 'all_users':
        endpoint = '/api/admin/users';
        break;
      case 'all_orgs':
        endpoint = '/api/admin/organizations/approved';
        break;
      case 'all_donations':
        endpoint = '/api/admin/donations';
        break;
      case 'rejected_orgs':
        endpoint = '/api/admin/organizations/rejected';
        break;
    }

    final url = Uri.parse('http://127.0.0.1:8000$endpoint');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.adminToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // لارافيل يرجع في المصفوفة بأسماء مختلفة بناءً على الـ Endpoint
          if (_currentSection == 'pending_orgs' ||
              _currentSection == 'all_orgs') {
            _dataList = data['organizations'] ?? [];
          } else if (_currentSection == 'all_users') {
            _dataList = data['users'] ?? [];
          } else if (_currentSection == 'all_donations') {
            _dataList = data['donations'] ?? [];
          } else if (_currentSection == 'rejected_orgs') {
            _dataList = data['organizations'] ?? [];
          }
          _isLoading = false;
        });
      } else {
        _showSnackBar('فشل في جلب البيانات من السيرفر', Colors.red);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar('خطأ في الاتصال بالسيرفر', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  // دالة معالجة قبول أو رفض المنظمات المعلقة
  Future<void> _handleOrganizationAction(int id, String action) async {
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/admin/organizations/$id/$action',
    );
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.adminToken}',
        },
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showSnackBar(
          responseData['message'] ?? 'تمت العملية بنجاح',
          Colors.green,
        );
        setState(() {
          _dataList.removeWhere((org) => org['id'] == id);
        });
      } else {
        _showSnackBar('حدث خطأ ما أثناء معالجة الطلب', Colors.red);
      }
    } catch (e) {
      _showSnackBar('تعذر الاتصال بالسيرفر', Colors.red);
    }
  }

  // دالة ترقية مستخدم عادي ليكون أدمن (بناءً على مسار لارافيل الأخير عندك)
  Future<void> _makeUserAdmin(int id) async {
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/admin/users/$id/make-admin',
    );
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.adminToken}',
        },
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showSnackBar(
          responseData['message'] ?? 'تم ترقية المستخدم إلى أدمن',
          Colors.green,
        );
        _fetchData(); // إعادة تحديث القائمة
      }
    } catch (e) {
      _showSnackBar('تعذر الاتصال بالسيرفر', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: color,
      ),
    );
  }

  // تحديد عنوان الـ AppBar بناءً على القسم النشط
  String _getAppBarTitle() {
    switch (_currentSection) {
      case 'pending_orgs':
        return 'الطلبات المعلقة للمنظمات';
      case 'all_users':
        return 'إدارة مستخدمي النظام';
      case 'all_orgs':
        return 'المنظمات المعتمدة';
      case 'all_donations':
        return 'سجل التبرعات والحملات';
      case 'rejected_orgs':
        return 'المنظمات المرفوضة';
      default:
        return 'لوحة تحكم الأدمن';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E5631),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),

      // 👈 إضافة القائمة الجانبية الاحترافية للتنقل بين مسارات لارافيل
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1E5631)),
              accountName: Text(
                'لوحة التحكم للأدمن',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text('تطبيق التبرعات والمساعدات'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 40,
                  color: Color(0xFF1E5631),
                ),
              ),
            ),
            _buildDrawerItem(
              'pending_orgs',
              'طلبات المنظمات المعلقة',
              Icons.pending_actions,
            ),
            _buildDrawerItem(
              'all_orgs',
              'المنظمات المعتمدة',
              Icons.corporate_fare,
            ),
            _buildDrawerItem('rejected_orgs', 'المنظمات المرفوضة', Icons.block),
            _buildDrawerItem(
              'all_users',
              'المستخدمين والمتبرعين',
              Icons.people,
            ),
            _buildDrawerItem(
              'all_donations',
              'إحصائيات وسجل التبرعات',
              Icons.volunteer_activism,
            ),
            const Divider(),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E5631)),
            )
          : _dataList.isEmpty
          ? const Center(
              child: Text(
                'لا توجد بيانات لعرضها حالياً',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _dataList.length,
              itemBuilder: (context, index) {
                final item = _dataList[index];
                // عرض الكارد بناءً على القسم المفتوح حالياً
                if (_currentSection == 'pending_orgs') {
                  return _buildPendingOrgCard(item);
                } else if (_currentSection == 'all_orgs') {
                  return _buildApprovedOrgCard(item);
                } else if (_currentSection == 'all_users') {
                  return _buildUserCard(item);
                } else if (_currentSection == 'rejected_orgs') {
                  return _buildRejectedOrgCard(item);
                } else {
                  return _buildDonationCard(item);
                }
              },
            ),
    );
  }

  // ويدجت لبناء خيارات الـ Drawer بستايل متفاعل يوضح الخيار النشط
  Widget _buildDrawerItem(String section, String title, IconData icon) {
    bool isSelected = _currentSection == section;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF1E5631) : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF1E5631) : Colors.black87,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF1E5631).withOpacity(0.1),
      onTap: () {
        Navigator.pop(context); // إغلاق الـ Drawer
        setState(() {
          _currentSection = section;
        });
        _fetchData(); // جلب بيانات القسم الجديد
      },
    );
  }

  // 1. كارد المنظمات المعلقة (مع أزرار القبول والرفض)
  Widget _buildPendingOrgCard(dynamic org) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  org['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: const Text('معلقة'),
                  backgroundColor: Colors.orange.shade100,
                  labelStyle: TextStyle(color: Colors.orange.shade800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              org['description'] ?? 'لا يوجد وصف متاح',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      _handleOrganizationAction(org['id'], 'reject'),
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  label: const Text(
                    'رفض',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () =>
                      _handleOrganizationAction(org['id'], 'approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5631),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('قبول وثوقية المنظمة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2. كارد المنظمات المعتمدة المقبولة سابقاً
  Widget _buildApprovedOrgCard(dynamic org) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF1E5631),
          child: Icon(Icons.business, color: Colors.white),
        ),
        title: Text(
          org['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(org['email'] ?? org['description'] ?? ''),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }

  // 3. كارد المستخدمين (مع زر الترقية لأدمن)
  Widget _buildUserCard(dynamic user) {
    bool isAdmin = user['role'] == 'admin';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isAdmin
                ? Colors.amber.shade700
                : Colors.blue.shade700,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
            '${user['firstName']} ${user['lastName']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'الدور الحالي: ${user['role']} \nالإيميل: ${user['email']}',
          ),
          isThreeLine: true,
          trailing: isAdmin
              ? const Chip(label: Text('أدمن'), backgroundColor: Colors.amber)
              : ElevatedButton(
                  onPressed: () => _makeUserAdmin(user['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('ترقية لأدمن'),
                ),
        ),
      ),
    );
  }

  // 4. كارد إحصائيات التبرعات
  Widget _buildDonationCard(dynamic donation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.favorite, color: Colors.white),
        ),
        title: Text(
          'تبرع بقيمة: \$${donation['amount'] ?? donation['value']}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        subtitle: Text(
          'بواسطة المستخدم رقم: ${donation['user_id']} \nالتاريخ: ${donation['created_at']?.toString().substring(0, 10) ?? ''}',
        ),
      ),
    );
  }

  // rejected_orgs
  Widget _buildRejectedOrgCard(dynamic org) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  org['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: const Text('مرفوضة'),
                  backgroundColor: Colors.red.shade100,
                  labelStyle: TextStyle(color: Colors.red.shade800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              org['description'] ?? 'لا يوجد وصف متاح',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
