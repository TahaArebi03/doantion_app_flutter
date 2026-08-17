import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/invitation_model.dart';

class InvitationService {
  final String _baseUrl = 'http://127.0.0.1:8000';
  final String token;

  InvitationService(this.token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // --- للمتبرع ---
  // جلب الدعوات التي وصلتني
  Future<List<Invitation>> getMyInvitations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/invitations/myInvitations'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> invitations = data['invitations'] ?? [];
      return invitations.map((i) => Invitation.fromJson(i)).toList();
    }
    throw Exception('فشل جلب الدعوات');
  }

  // قبول دعوة
  Future<void> acceptInvitation(int invitationId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/invitations/acceptInvitation'),
      headers: _headers,
      body: jsonEncode({'invitation_id': invitationId}),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل قبول الدعوة');
    }
  }

  // رفض دعوة
  Future<void> rejectInvitation(int invitationId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/invitations/rejectInvitation'),
      headers: _headers,
      body: jsonEncode({'invitation_id': invitationId}),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل رفض الدعوة');
    }
  }

  // --- للمدير ---
  // جلب الدعوات التي أرسلتها جمعيتي
  Future<List<Invitation>> getSentInvitations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/invitations/sentInvitations'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> invitations = data['invitations'] ?? [];
      return invitations.map((i) => Invitation.fromJson(i)).toList();
    } else {
      // قراءة رسالة الخطأ من السيرفر
      final errorData = jsonDecode(response.body);
      final errorMessage =
          errorData['error'] ??
          errorData['message'] ??
          'فشل جلب الدعوات المرسلة';
      throw Exception(errorMessage);
    }
  }

  // إرسال دعوة لمستخدم
  Future<void> sendInvitation(
    int userId,
    String role, {
    int? organizationId,
  }) async {
    final body = {
      'user_id': userId,
      'role': role,
      if (organizationId != null) 'organization_id': organizationId,
    };

    print('📤 Sending invitation: $body');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/invitations/sendInvitation'),
      headers: _headers,
      body: jsonEncode(body),
    );

    print('📨 Response status: ${response.statusCode}');
    print('📨 Response body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'فشل إرسال الدعوة';

      try {
        if (response.body.isNotEmpty) {
          final error = jsonDecode(response.body);
          errorMessage =
              error['message'] ??
              error['error'] ??
              error['errors']?.toString() ??
              'فشل إرسال الدعوة';
        }
      } catch (e) {
        print('❌ Error parsing response: $e');
      }

      throw Exception('$errorMessage (${response.statusCode})');
    }
  }

  // إلغاء / حذف دعوة (للمدير فقط قبل الرد)
  Future<void> cancelInvitation(int invitationId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/invitations/cancelInvitation/$invitationId'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'فشل حذف الدعوة');
    }
  }
}
