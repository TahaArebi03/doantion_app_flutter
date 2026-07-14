import 'package:flutter/material.dart';
// import '../../services/api_service.dart';
import '../../models/organization_model.dart';
import '../../widgets/organization_card.dart';
import 'organization_detail_screen.dart';

class OrganizationsScreen extends StatelessWidget {
  const OrganizationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('شركاء الخير')),
      // body: FutureBuilder<List<Organization>>(
      //   // future: ApiService.getOrganizations(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(child: CircularProgressIndicator());
      //     }
      //     if (snapshot.hasError) {
      //       return Center(child: Text('حدث خطأ: ${snapshot.error}'));
      //     }
      //     final orgs = snapshot.data!;
      //     return ListView.builder(
      //       padding: const EdgeInsets.all(16),
      //       itemCount: orgs.length,
      //       itemBuilder: (context, index) {
      //         final org = orgs[index];
      //         return OrganizationCard(
      //           organization: org,
      //           onTap: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (_) =>
      //                     OrganizationDetailScreen(organization: org),
      //               ),
      //             );
      //           },
      //         );
      //       },
      //     );
      //   },
      // ),
    );
  }
}
