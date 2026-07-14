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
}