import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/member_model.dart';
import '../models/user_model.dart';
import '../models/join_request_model.dart';
import '../models/invitation_model.dart';

class MemberService {
  final String _baseUrl = 'http://127.0.0.1:8000';
  final String token;
  final http.Client _client;

  MemberService(this.token, {http.Client? client})
    : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<List<MemberModel>> getMembers(int orgId) async {
    final response = await _client.get(
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
    final response = await _client.get(
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
    await inviteMember(userId, role);
  }

  Future<void> inviteMember(
    int userId,
    String role, {
    int? organizationId,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/member/invite'),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'role': role,
        if (organizationId != null) 'organization_id': organizationId,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      final errorMessage =
          responseData['error'] ??
          responseData['message'] ??
          'فشل إرسال الدعوة';
      throw Exception(errorMessage);
    }
  }

  Future<void> updateRole(int userId, String newRole) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/member/update-role'),
      headers: _headers,
      body: jsonEncode({'user_id': userId, 'role': newRole}),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل تحديث الدور');
    }
  }

  Future<void> removeMember(int userId) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/member/remove'),
      headers: _headers,
      body: jsonEncode({'user_id': userId}),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل حذف العضو');
    }
  }

  Future<void> removeInvitation(int invitationId) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/member/remove-invitation'),
      headers: _headers,
      body: jsonEncode({'invitation_id': invitationId}),
    );

    if (response.statusCode == 200) return;

    final errorData = jsonDecode(response.body);
    throw Exception(
      errorData['error'] ?? errorData['message'] ?? 'فشل حذف الدعوة',
    );
  }

  // ------------------- طلبات الانضمام (المستخدم يطلب) -------------------
  Future<List<JoinRequest>> getPendingRequestsForOrganization() async {
    // خاصة بالمدير: جلب الطلبات المعلقة لجمعيته
    final response = await _client.get(
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
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/member/approve-request'),
      headers: _headers,
      body: jsonEncode({'request_id': requestId}),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل قبول الطلب');
    }
  }

  Future<void> rejectRequest(int requestId) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/member/reject-request'),
      headers: _headers,
      body: jsonEncode({'request_id': requestId}),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل رفض الطلب');
    }
  }

  // خاصة بالمستخدم: جلب طلباتي (التي قدمتها)
  Future<List<Invitation>> getSentInvitations({int? organizationId}) async {
    final uri = Uri.parse(
      '$_baseUrl/api/member/invitations${organizationId != null ? '?organization_id=$organizationId' : ''}',
    );
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> invitations = data['invitations'] ?? [];
      return invitations.map((i) => Invitation.fromJson(i)).toList();
    } else {
      throw Exception('فشل في جلب الدعوات المرسلة');
    }
  }

  Future<List<JoinRequest>> getMyRequests() async {
    final response = await _client.get(
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
    final response = await _client.post(
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
    final response = await _client.get(
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
    final response = await _client.get(
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
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/member/accept-invitation'),
      headers: _headers,
      body: jsonEncode({'invitation_id': invitationId}),
    );
    if (response.statusCode != 200) throw Exception('فشل قبول الدعوة');
  }

  Future<void> rejectInvitation(int invitationId) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/member/reject-invitation'),
      headers: _headers,
      body: jsonEncode({'invitation_id': invitationId}),
    );
    if (response.statusCode != 200) throw Exception('فشل رفض الدعوة');
  }
}
