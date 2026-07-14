import 'package:flutter/material.dart';

class MyDonationsScreen extends StatelessWidget {
  const MyDonationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل تبرعاتي')),
      body: const Center(child: Text('عرض سجل التبرعات السابقة')),
    );
  }
}
