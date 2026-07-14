import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/member_model.dart';
import '../models/user_model.dart';

class MemberService {
  final String _baseUrl = 'http://127.0.0.1:8000';
  final String token;

  MemberService(this.token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<List<MemberModel>> getMembers(int orgId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/member/list_members?organization_id=$orgId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> members = data['members'] ?? [];
      return members.map((m) => MemberModel.fromJson(m)).toList();
    } else {
      throw Exception('فشل جلب الأعضاء');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> users = data is List ? data : (data['users'] ?? []);
      return users.map((u) => UserModel.fromJson(u)).toList();
    } else {
      throw Exception('فشل جلب المستخدمين');
    }
  }

  Future<void> addMember(int userId, String role) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/member/add'),
      headers: _headers,
      body: jsonEncode({'user_id': userId, 'role': role}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('فشل إضافة العضو');
    }
  }

  Future<void> updateRole(int userId, String newRole) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/member/update-role'),
      headers: _headers,
      body: jsonEncode({'user_id': userId, 'role': newRole}),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل تحديث الدور');
    }
  }

  Future<void> removeMember(int userId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/member/remove'),
      headers: _headers,
      body: jsonEncode({'user_id': userId}),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل حذف العضو');
    }
  }
}