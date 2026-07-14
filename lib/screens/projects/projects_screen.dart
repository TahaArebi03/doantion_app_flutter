import 'package:flutter/material.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فرص التبرع')),
      body: const Center(child: Text('قائمة المشاريع المتاحة للتبرع')),
    );
  }
}
