import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/member_model.dart';
import '../models/user_model.dart';
import '../models/join_request_model.dart';
import '../models/invitation_model.dart';

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

  // ------------------- طلبات الانضمام (المستخدم يطلب) -------------------
  Future<List<JoinRequest>> getPendingRequestsForOrganization() async {
    // خاصة بالمدير: جلب الطلبات المعلقة لجمعيته
    final response = await http.get(
      Uri.parse('$_baseUrl/api/member/pending-requests'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> requests = data['requests'] ?? [];
      return requests.map((r) => JoinRequest.fromJson(r)).toList();
    } else {
      throw Exception('فشل في جلب الطلبات');
    }
  }

  Future<void> approveRequest(int requestId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/member/approve-request'),
      headers: _headers,
      body: jsonEncode({'request_id': requestId}),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل قبول الطلب');
    }
  }

  Future<void> rejectRequest(int requestId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/member/reject-request'),
      headers: _headers,
      body: jsonEncode({'request_id': requestId}),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل رفض الطلب');
    }
  }

  // خاصة بالمستخدم: جلب طلباتي (التي قدمتها)
  Future<List<JoinRequest>> getMyRequests() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/member/my-requests'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> requests = data['requests'] ?? [];
      return requests.map((r) => JoinRequest.fromJson(r)).toList();
    } else {
      throw Exception('فشل في جلب طلباتي');
    }
  }

  // تقديم طلب انضمام لجمعية
  Future<void> submitJoinRequest(int organizationId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/member/join-request'),
      headers: _headers,
      body: jsonEncode({'organization_id': organizationId}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('فشل تقديم الطلب');
    }
  }

  // التحقق من حالة طلب المستخدم لجمعية معينة
  Future<String?> getUserRequestStatus(int organizationId) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/api/member/request-status?organization_id=$organizationId',
      ),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'];
    } else {
      return null;
    }
  }

  // ------------------- دعوات الجمعية (الجمعية تدعو المستخدم) -------------------
  Future<List<Invitation>> getMyInvitations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/member/invitations'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> invitations = data['invitations'] ?? [];
      return invitations.map((i) => Invitation.fromJson(i)).toList();
    } else {
      throw Exception('فشل في جلب الدعوات');
    }
  }

  Future<void> acceptInvitation(int invitationId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/member/accept-invitation'),
      headers: _headers,
      body: jsonEncode({'invitation_id': invitationId}),
    );
    if (response.statusCode != 200) throw Exception('فشل قبول الدعوة');
  }

  Future<void> rejectInvitation(int invitationId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/member/reject-invitation'),
      headers: _headers,
      body: jsonEncode({'invitation_id': invitationId}),
    );
    if (response.statusCode != 200) throw Exception('فشل رفض الدعوة');
  }
}
