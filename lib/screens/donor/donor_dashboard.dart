import 'package:flutter/material.dart';
import '../projects/projects_screen.dart';
import '../organizations/organizations_screen.dart';
import '../follows/my_follows_screen.dart';
// import '../organization/my_organizations_screen.dart';
import '../donations/my_donations_screen.dart';
import '../../themes/app_theme.dart';

class DonorDashboard extends StatefulWidget {
  final String userToken;

  const DonorDashboard({Key? key, required this.userToken}) : super(key: key);

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ProjectsScreen(),
    const OrganizationsScreen(),
    const MyFollowsScreen(),
    // const MyOrganizationsScreen(),
    const MyDonationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            label: 'فرص التبرع',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'شركاء الخير',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'مفضلتي',
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
