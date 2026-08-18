import 'package:flutter/material.dart';
import '../../models/organization_model.dart';
import '../../services/organization_service.dart';
import '../../services/member_service.dart';
import '../../widgets/organization_card.dart';
import 'organization_detail_screen.dart';

class MyOrganizationsScreen extends StatefulWidget {
  final String? token;

  const MyOrganizationsScreen({Key? key, this.token}) : super(key: key);

  @override
  State<MyOrganizationsScreen> createState() => _MyOrganizationsScreenState();
}

class _MyOrganizationsScreenState extends State<MyOrganizationsScreen> {
  List<Organization> _organizations = [];
  bool _isLoading = true;
  bool _isLeaving = false;

  late OrganizationService _orgService;
  late MemberService _memberService;

  @override
  void initState() {
    super.initState();
    final token = widget.token ?? '';
    _orgService = OrganizationService(token);
    _memberService = MemberService(token);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      _organizations = await _orgService.getMyOrganizations();
    } catch (e) {
      _showSnackBar('فشل تحميل البيانات: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _leaveOrganization(Organization org) async {
    // تأكيد قبل مغادرة الجمعية
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد المغادرة'),
        content: Text('هل أنت متأكد من مغادرة جمعية "${org.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('مغادرة'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLeaving = true);
    try {
      // استخدام دالة removeMember من MemberService (تحتاج إلى معرف المستخدم)
      // بما أننا لا نملك معرف المستخدم مباشرة، نستخدم طريقة بديلة
      // سنفترض أن هناك مسار leaveOrganization في الـ API
      await _memberService.leaveOrganization(org.id);
      _showSnackBar('تمت مغادرة الجمعية بنجاح', Colors.green);
      await _fetchData(); // تحديث القائمة
    } catch (e) {
      _showSnackBar('فشل المغادرة: $e', Colors.red);
    } finally {
      setState(() => _isLeaving = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جمعياتي'),
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B4332)),
            )
          : _organizations.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_center_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'أنت لست عضواً في أي جمعية حالياً',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'يمكنك تصفح الجمعيات وتقديم طلب انضمام',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _organizations.length,
                itemBuilder: (context, index) {
                  final org = _organizations[index];
                  return _buildOrganizationCard(org);
                },
              ),
            ),
    );
  }

  Widget _buildOrganizationCard(Organization org) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD4AF37), width: 0.5),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrganizationDetailScreen(
                organization: org,
                token: widget.token,
              ),
            ),
          ).then((_) => _fetchData()); // تحديث عند العودة
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: org.image != null
                    ? NetworkImage(org.image!)
                    : null,
                child: org.image == null
                    ? Text(
                        org.name.isNotEmpty ? org.name[0] : 'ج',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4332),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      org.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      org.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'عضو',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${org.membersCount ?? 0} عضو',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.exit_to_app_outlined,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: _isLeaving
                              ? null
                              : () => _leaveOrganization(org),
                          tooltip: 'مغادرة الجمعية',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
