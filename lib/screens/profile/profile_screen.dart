import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrganizationProfileScreen extends StatefulWidget {
  final int organizationId;
  const OrganizationProfileScreen({
    Key? key,
    refinement,
    required this.organizationId,
  }) : super(key: key);

  @override
  _OrganizationProfileScreenState createState() =>
      _OrganizationProfileScreenState();
}

class _OrganizationProfileScreenState extends State<OrganizationProfileScreen> {
  Map<String, dynamic>? orgDetails;
  bool isLoading = true;
  String token = "TOKEN_HERE"; // استبدله بـ Token الخاص بالمستخدم

  @override
  void initState() {
    super.initState();
    fetchOrganizationDetails();
  }

  // جلب التفاصيل مع حالات العضوية والمتابعة (تستدعي دالة getOrganizationDetails في الباك اند)
  Future<void> fetchOrganizationDetails() async {
    try {
      var headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      var response = await http.get(
        Uri.parse(
          'https://your-domain.com/api/organizations/${widget.organizationId}/details',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          orgDetails = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // دالة المتابعة وإلغاء المتابعة الديناميكية
  Future<void> toggleFollow() async {
    bool isFollowed = orgDetails?['is_followed'] ?? false;
    String url = isFollowed
        ? 'https://your-domain.com/api/organizations/${widget.organizationId}/unfollow'
        : 'https://your-domain.com/api/organizations/${widget.organizationId}/follow';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          orgDetails?['is_followed'] = !isFollowed;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFollowed ? "تمت الإزالة من المفضلة" : "تمت الإضافة للمفضلة",
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  // دالة طلب الانضمام (تستدعي دالة volunteerRequest)
  Future<void> sendJoinRequest() async {
    try {
      var response = await http.post(
        Uri.parse(
          'https://your-domain.com/api/organizations/${widget.organizationId}/volunteer-request',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          orgDetails?['volunteer_status'] = 'pending';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إرسال طلب انضمامك للمدير بنجاح")),
        );
      } else {
        var errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'] ?? "فشل إرسال الطلب")),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFollowed = orgDetails?['is_followed'] ?? false;
    String volunteerStatus =
        orgDetails?['volunteer_status'] ??
        'none'; // none, pending, approved, rejected

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F4C5C),
          elevation: 0,
          title: Text(
            orgDetails?['name'] ?? 'تفاصيل الجمعية',
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (!isLoading)
              IconButton(
                icon: Icon(
                  isFollowed ? Icons.favorite : Icons.favorite_border,
                  color: Colors.redAccent,
                  size: 28,
                ),
                onPressed: toggleFollow,
              ),
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F4C5C)),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // هيدر احترافي بستايل بطاقة قطر الخيرية
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F4C5C),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.corporate_fare_rounded,
                              size: 50,
                              color: Color(0xFF0F4C5C),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            orgDetails?['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Chip(
                            label: Text(
                              orgDetails?['type'] ?? 'جمعية خيرية',
                              style: const TextStyle(color: Color(0xFF0F4C5C)),
                            ),
                            backgroundColor: const Color(0xFFE3A857),
                          ),
                        ],
                      ),
                    ),

                    // قسم نبذة عن الجمعية
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'نبذة عن شريك الخير',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F4C5C),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            orgDetails?['description'] ??
                                'لا يوجد تفاصيل إضافية.',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF4A5568),
                              height: 1.6,
                            ),
                          ),
                          const Divider(height: 40, thickness: 1),

                          // معلومات المالك المسؤول
                          const Text(
                            'إدارة الجمعية ورئيسها',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F4C5C),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              '${orgDetails?['owner']['firstName'] ?? ''} ${orgDetails?['owner']['lastName'] ?? ''}',
                            ),
                            subtitle: Text(orgDetails?['owner']['email'] ?? ''),
                          ),
                          const SizedBox(height: 40),

                          // الـ Logic الذكي للأزرار حسب الـ volunteer_status والـ is_member
                          _buildDynamicActionButton(volunteerStatus),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // دالة بناء الزر التفاعلي بناءً على الباك اند
  Widget _buildDynamicActionButton(String status) {
    if (status == 'approved' || orgDetails?['is_member'] == true) {
      // 1. المستخدم عضو رسمي ومقبول
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32), // لون أخضر مريح
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(
          Icons.dashboard_customize_rounded,
          color: Colors.white,
        ),
        label: const Text(
          'دخول لوحة تحكم العضو (لديك صلاحيات)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          // افتح له الصلاحيات أو الشاشة المخصصة للأعضاء
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("جاري فتح شاشة الأعضاء...")),
          );
        },
      );
    } else if (status == 'pending') {
      // 2. طلب الانضمام أُرسل وبانتظار موافقة المدير دالة approveVolunteer
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[400],
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.hourglass_top_rounded, color: Colors.white),
        label: const Text(
          'طلبك قيد الانتظار في الجمعية',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: null, // الزر معطل لأنه قيد الانتظار
      );
    } else if (status == 'rejected') {
      // 3. الطلب تم رفضه من المدير
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red[700]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'عذراً، تم رفض طلب انضمامك لهذه الجمعية من قبل الإدارة.',
                style: TextStyle(color: Colors.red[900]),
              ),
            ),
          ],
        ),
      );
    } else {
      // 4. مستخدم عادي زائر (الافتراضي none) يظهر له زر الانضمام
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(
            0xFFE3A857,
          ), // لون برتقالي/ذهبي احترافي يجذب الضغط
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text(
          'تقديم طلب انضمام للجمعية',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: sendJoinRequest,
      );
    }
  }
}
