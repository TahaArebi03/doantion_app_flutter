import 'package:flutter/material.dart';
import '../../models/organization_model.dart';
import '../../services/organization_service.dart';
import '../../widgets/organization_card.dart';
import '../organizations/organization_detail_screen.dart';

class MyFollowsScreen extends StatefulWidget {
  final String? token;

  const MyFollowsScreen({Key? key, this.token}) : super(key: key);

  @override
  State<MyFollowsScreen> createState() => _MyFollowsScreenState();
}

class _MyFollowsScreenState extends State<MyFollowsScreen> {
  List<Organization> _followed = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final service = OrganizationService(widget.token ?? '');
      _followed = await service.getFollowedOrganizations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل تحميل المفضلة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _followed.isEmpty
          ? const Center(child: Text('لا توجد جمعيات مفضلة'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _followed.length,
              itemBuilder: (context, index) {
                final org = _followed[index];
                return OrganizationCard(
                  organization: org,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrganizationDetailScreen(
                          organization: org,
                          token: widget.token,
                        ),
                      ),
                    );
                  },
                  onFollowToggle: () async {
                    try {
                      final service = OrganizationService(widget.token ?? '');
                      await service.unfollowOrganization(org.id);
                      await _fetchData();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('فشل: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  onJoinRequest: () async {
                    // مشابه للشاشة السابقة
                  },
                );
              },
            ),
    );
  }
}
