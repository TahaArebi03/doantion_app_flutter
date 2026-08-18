import 'package:flutter/material.dart';
import '../../models/organization_model.dart';
import '../../services/organization_service.dart';
import '../../services/join_request_service.dart';
import '../../widgets/organization_card.dart';
import 'organization_detail_screen.dart';

class OrganizationsScreen extends StatefulWidget {
  final String? token;

  const OrganizationsScreen({Key? key, this.token}) : super(key: key);

  @override
  State<OrganizationsScreen> createState() => _OrganizationsScreenState();
}

class _OrganizationsScreenState extends State<OrganizationsScreen> {
  List<Organization> _organizations = [];
  bool _isLoading = true;

  late OrganizationService _orgService;
  late JoinRequestService _requestService;

  @override
  void initState() {
    super.initState();
    final token = widget.token ?? '';
    _orgService = OrganizationService(token);
    _requestService = JoinRequestService(token);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      _organizations = await _orgService.getAllOrganizations();
    } catch (e) {
      if (mounted) {
        _showSnackBar('فشل تحميل البيانات: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('شركاء الخير')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _organizations.isEmpty
          ? const Center(child: Text('لا توجد جمعيات مسجلة'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _organizations.length,
              itemBuilder: (context, index) {
                final org = _organizations[index];
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
                      if (org.isFollowed) {
                        await _orgService.unfollowOrganization(org.id);
                      } else {
                        await _orgService.followOrganization(org.id);
                      }
                      await _fetchData();
                    } catch (e) {
                      _showSnackBar('فشل: $e', Colors.red);
                    }
                  },
                  onJoinRequest: () async {
                    try {
                      final status = await _requestService.getRequestStatus(
                        org.id,
                      );
                      if (status == 'pending') {
                        _showSnackBar('لديك طلب معلق بالفعل', Colors.orange);
                        return;
                      }
                      await _requestService.sendRequest(org.id);
                      _showSnackBar('تم تقديم الطلب', Colors.green);
                      await _fetchData();
                    } catch (e) {
                      _showSnackBar('فشل: $e', Colors.red);
                    }
                  },
                );
              },
            ),
    );
  }
}
