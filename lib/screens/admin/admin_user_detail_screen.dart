import 'package:flutter/material.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final int userId;
  const AdminUserDetailScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3, // بياناته، تبرعاته، جمعياته
        child: Scaffold(
          appBar: AppBar(
            title: const Text('ملف بيانات المستخدم'),
            bottom: const TabBar(
              indicatorColor: Color(0xFFD4AF37),
              tabs: [
                Tab(text: 'البيانات الأساسية'),
                Tab(text: 'سجل تبرعاته'),
                Tab(text: 'الجمعيات التابع لها'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildGeneralInfo(context),
              _buildUserDonations(),
              _buildUserOrgs(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFF1B4332),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('الاسم'),
                  subtitle: Text('صلاح الدين الأيوبي'),
                ),
                ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text('البريد'),
                  subtitle: Text('salah@mail.com'),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                  ),
                  onPressed: () {}, // ترقية لأدمن makeAdmin
                  child: const Text(
                    'ترقية إلى مشرف الأدمن',
                    style: TextStyle(color: Color(0xFF1B4332)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () {}, // حذف المستخدم deleteUser
                  child: const Text('حذف حساب المستخدم نهائياً'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserDonations() {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) => const Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          title: Text('تبرع لمشروع كفالة الأيتام'),
          subtitle: Text('تاريخ: 2026-07-04'),
          trailing: Text(
            '200 د.ل',
            style: TextStyle(
              color: Color(0xFF2A9D8F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserOrgs() {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) => const Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: Icon(Icons.star, color: Color(0xFFD4AF37)),
          title: Text('جمعية غراس الخيرية'),
          subtitle: Text('الدور: متطوع / كفيل معتمد'),
        ),
      ),
    );
  }
}
