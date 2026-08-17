import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/join_request_model.dart';

class JoinRequestService {
  final String _baseUrl = 'http://127.0.0.1:8000';
  final String token;

  JoinRequestService(this.token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // --- للمتبرع ---
  // جلب طلباتي (التي قدمتها)
  Future<List<JoinRequest>> getMyRequests() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/join-requests/myRequests'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> requests = data['requests'] ?? [];
      return requests.map((r) => JoinRequest.fromJson(r)).toList();
    }
    throw Exception('فشل جلب طلباتي');
  }

  // تقديم طلب انضمام لجمعية
  Future<void> sendRequest(int organizationId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/join-requests/sendRequest'),
      headers: _headers,
      body: jsonEncode({'organization_id': organizationId}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('فشل تقديم الطلب');
    }
  }

  // التحقق من حالة طلبي لجمعية معينة
  // Future<String?> getRequestStatus(int organizationId) async {
  //   final response = await http.get(
  //     Uri.parse(
  //       '$_baseUrl/api/join-requests/request-status?organization_id=$organizationId',
  //     ),
  //     headers: _headers,
  //   );
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return data['status'];
  //   }
  //   return null;
  // }

  // --- للمدير ---
  // جلب الطلبات المعلقة لجمعيتي
  Future<List<JoinRequest>> getPendingRequestsForOrganization(
    int organizationId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/api/join-requests/pendingRequests?organization_id=$organizationId',
      ),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> requests = data['requests'] ?? [];
      return requests.map((r) => JoinRequest.fromJson(r)).toList();
    }
    throw Exception('فشل جلب الطلبات المعلقة');
  }

  // قبول طلب
  Future<void> approveRequest(int requestId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/join-requests/approveRequest'),
      headers: _headers,
      body: jsonEncode({'request_id': requestId}),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل قبول الطلب');
    }
  }

  // رفض طلب
  Future<void> rejectRequest(int requestId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/join-requests/rejectRequest'),
      headers: _headers,
      body: jsonEncode({'request_id': requestId}),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل رفض الطلب');
    }
  }

  // حالة الطلب لجمعية معينة
  Future<String?> getRequestStatus(int organizationId) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/api/join-requests/getRequestStatus?organization_id=$organizationId',
      ),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'];
    }
    return null;
  }
}
