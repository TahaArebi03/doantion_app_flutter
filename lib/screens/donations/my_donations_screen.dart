import 'package:flutter/material.dart';
import '../../models/donation_model.dart';
import '../../services/donation_service.dart';

class MyDonationsScreen extends StatefulWidget {
  final String? token;

  const MyDonationsScreen({Key? key, this.token}) : super(key: key);

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  List<DonationModel> _donations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final service = DonationService(widget.token ?? '');
      _donations = await service.getMyDonations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل تحميل التبرعات: $e'),
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
      appBar: AppBar(title: const Text('سجل تبرعاتي')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _donations.isEmpty
          ? const Center(child: Text('لا توجد تبرعات مسجلة'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _donations.length,
              itemBuilder: (context, index) {
                final donation = _donations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(donation.status),
                      child: Text(
                        donation.amount.toStringAsFixed(0),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(donation.projectTitle),
                    subtitle: Text(
                      'التاريخ: ${donation.createdAt.toLocal()}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${donation.amount.toStringAsFixed(2)} د.ل',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              donation.status,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getArabicStatus(donation.status),
                            style: TextStyle(
                              color: _getStatusColor(donation.status),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'completed' || status == 'approved') return Colors.green;
    if (status == 'pending') return Colors.orange;
    return Colors.red;
  }

  String _getArabicStatus(String status) {
    if (status == 'completed' || status == 'approved') return 'مكتمل';
    if (status == 'pending') return 'قيد الانتظار';
    return 'فاشل';
  }
}
