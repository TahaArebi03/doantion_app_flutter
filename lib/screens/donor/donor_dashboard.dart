import 'package:flutter/material.dart';
import '../projects/projects_screen.dart';
import '../organizations/organizations_screen.dart';
import '../follows/my_follows_screen.dart';
import '../../widgets/notification_badge.dart';
import '../donations/my_donations_screen.dart';
import '../../themes/app_theme.dart';
import '../organizations/my_organizations_screen.dart';

class DonorDashboard extends StatefulWidget {
  final String userToken;

  const DonorDashboard({Key? key, required this.userToken}) : super(key: key);

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ProjectsScreen(token: widget.userToken),
      OrganizationsScreen(token: widget.userToken),
      MyFollowsScreen(token: widget.userToken),
      MyOrganizationsScreen(token: widget.userToken), // جمعياتي
      MyDonationsScreen(token: widget.userToken),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          NotificationBadge(
            token: widget.userToken,
            onNotificationTap: () {
              // تحديث أي بيانات تحتاج تحديث عند تفاعل المستخدم مع الإشعارات
              setState(() {});
            },
          ),
        ],
      ),

      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGold,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'شركاء الخير',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'المفضلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            label: 'جمعياتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: 'سجل تبرعاتي',
          ),
        ],
      ),
    );
  }
}
