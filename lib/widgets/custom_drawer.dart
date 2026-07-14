import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String organizationName;
  final String currentSection;
  final ValueChanged<String> onSectionChanged;
  final VoidCallback onLogout;

  const CustomDrawer({Key? key, required this.organizationName, required this.currentSection, required this.onSectionChanged, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(organizationName),
            accountEmail: const Text('مدير الجمعية'),
            currentAccountPicture: const CircleAvatar(child: Icon(Icons.business)),
          ),
          ListTile(title: const Text('المشاريع'), onTap: () => onSectionChanged('projects')),
          ListTile(title: const Text('الأعضاء'), onTap: () => onSectionChanged('members')),
          const Spacer(),
          ListTile(title: const Text('تسجيل الخروج'), onTap: onLogout),
        ],
      ),
    );
  }
}