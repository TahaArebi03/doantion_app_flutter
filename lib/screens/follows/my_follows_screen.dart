import 'package:flutter/material.dart';

class MyFollowsScreen extends StatelessWidget {
  const MyFollowsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مفضلتي')),
      body: const Center(child: Text('قائمة المشاريع والجمعيات المفضلة')),
    );
  }
}
