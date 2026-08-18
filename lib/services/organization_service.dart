import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/organization_model.dart';

class OrganizationService {
  final String _baseUrl = 'http://127.0.0.1:8000';
  final String token;

  OrganizationService(this.token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<Organization> getOrganizationInfo() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/organization/show'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Organization.fromJson(data);
    } else {
      // محاولة بديلة (اختياري)
      final altResponse = await http.get(
        Uri.parse('$_baseUrl/api/member/list_organizations_for_user'),
        headers: _headers,
      );
      if (altResponse.statusCode == 200) {
        final altData = jsonDecode(altResponse.body);
        final orgs = altData['organizations'] ?? [];
        if (orgs.isNotEmpty) {
          return Organization.fromJson(orgs.first);
        }
      }
      throw Exception('فشل في جلب بيانات الجمعية');
    }
  }

  Future<List<Organization>> getAllOrganizations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/organization/all'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> orgs = data['organizations'] ?? data;
      return orgs.map((o) => Organization.fromJson(o)).toList();
    }
    throw Exception('فشل في جلب قائمة الجمعيات');
  }

  Future<List<Organization>> getMyOrganizations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/member/my-organizations'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> orgs = data['organizations'] ?? [];
      return orgs.map((o) => Organization.fromJson(o)).toList();
    }
    throw Exception('فشل جلب جمعياتي');
  }

  // جلب الجمعيات المفضلة
  Future<List<Organization>> getFollowedOrganizations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/organizations/followed'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> orgs = data['organizations'] ?? [];
      return orgs.map((o) => Organization.fromJson(o)).toList();
    }
    throw Exception('فشل جلب المفضلة');
  }

  // متابعة جمعية
  Future<void> followOrganization(int organizationId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/organizations/follow'),
      headers: _headers,
      body: jsonEncode({'organization_id': organizationId}),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل متابعة الجمعية');
    }
  }

  // إلغاء متابعة جمعية
  Future<void> unfollowOrganization(int organizationId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/organizations/unfollow'),
      headers: _headers,
      body: jsonEncode({'organization_id': organizationId}),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل إلغاء متابعة الجمعية');
    }
  }
}
