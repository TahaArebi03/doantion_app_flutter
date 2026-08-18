import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../../services/project_service.dart';
import '../../services/wallet_service.dart';
import '../../services/donation_service.dart';
import '../../widgets/wallet_topup_dialog.dart';
import 'project_detail_screen.dart';
import '../../widgets/project_card.dart';

class ProjectsScreen extends StatefulWidget {
  final String? token;

  const ProjectsScreen({Key? key, this.token}) : super(key: key);

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<ProjectModel> _projects = [];
  bool _isLoading = true;
  double _walletBalance = 0.0;

  late ProjectService _projectService;
  late WalletService _walletService;
  late DonationService _donationService;

  @override
  void initState() {
    super.initState();
    final token = widget.token ?? '';
    _projectService = ProjectService(token: token);
    _walletService = WalletService(token);
    _donationService = DonationService(token);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final projects = await _projectService.getAllProjects();
      final wallet = await _walletService.getWallet();
      setState(() {
        _projects = projects;
        _walletBalance = wallet.balance;
      });
    } catch (e) {
      _showSnackBar('فشل تحميل البيانات: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshWallet() async {
    try {
      final wallet = await _walletService.getWallet();
      setState(() => _walletBalance = wallet.balance);
    } catch (e) {
      // ignore
    }
  }

  Future<void> _donate(ProjectModel project) async {
    // فتح حوار إدخال المبلغ
    final amount = await _showDonationDialog(context);
    if (amount == null || amount <= 0) return;

    if (amount > _walletBalance) {
      _showSnackBar('رصيدك غير كافٍ. يرجى شحن المحفظة.', Colors.orange);
      return;
    }

    try {
      await _donationService.donateToProject(project.id, amount);
      _showSnackBar('تم التبرع بنجاح!', Colors.green);
      await _fetchData(); // تحديث القائمة والرصيد
      await _refreshWallet();
    } catch (e) {
      _showSnackBar('فشل التبرع: $e', Colors.red);
    }
  }

  Future<double?> _showDonationDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مبلغ التبرع'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'المبلغ (د.ل)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              } else {
                _showSnackBar('أدخل مبلغاً صحيحاً', Colors.red);
              }
            },
            child: const Text('تبرع'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المشاريع'),
        actions: [
          // عرض رصيد المحفظة مع زر شحن
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: InkWell(
              onTap: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => WalletTopUpDialog(
                    token: widget.token!,
                    onSuccess: _refreshWallet,
                  ),
                );
                if (result == true) {
                  await _refreshWallet();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 18,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_walletBalance.toStringAsFixed(2)} د.ل',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
          ? const Center(child: Text('لا توجد مشاريع حالياً'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final project = _projects[index];
                return ProjectCard(
                  project: project,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProjectDetailScreen(project: project),
                      ),
                    );
                  },
                  onDonate: () => _donate(project),
                );
              },
            ),
    );
  }
}
