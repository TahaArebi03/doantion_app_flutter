import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AdminService {
  static const String _devBaseUrl = 'http://127.0.0.1:8000';
  static const String _emulatorBaseUrl = 'http://10.0.2.2:8000';

  String get _baseUrl => kIsWeb ? _devBaseUrl : _emulatorBaseUrl;

  Map<String, String> _headers(String adminToken) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $adminToken',
  };

  Future<List<dynamic>> getPendingOrganizations({
    required String adminToken,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/organizations/pending'),
      headers: _headers(adminToken),
    );
    return _parseListResponse(response, 'organizations');
  }

  Future<List<dynamic>> getApprovedOrganizations({
    required String adminToken,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/organizations/approved'),
      headers: _headers(adminToken),
    );
    return _parseListResponse(response, 'organizations');
  }

  Future<List<dynamic>> getRejectedOrganizations({
    required String adminToken,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/organizations/rejected'),
      headers: _headers(adminToken),
    );
    return _parseListResponse(response, 'organizations');
  }

  Future<Map<String, dynamic>> approveOrganization({
    required String adminToken,
    required int id,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/admin/organization/$id/approve'),
      headers: _headers(adminToken),
    );
    return _parseJsonResponse(response);
  }

  Future<Map<String, dynamic>> pendingOrganization({
    required String adminToken,
    required int id,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/admin/organization/$id/pending'),
      headers: _headers(adminToken),
    );
    return _parseJsonResponse(response);
  }

  Future<Map<String, dynamic>> rejectOrganization({
    required String adminToken,
    required int id,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/admin/organization/$id/reject'),
      headers: _headers(adminToken),
    );
    return _parseJsonResponse(response);
  }

  Future<List<dynamic>> getUsers({required String adminToken}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/users'),
      headers: _headers(adminToken),
    );
    return _parseListResponse(response, 'users');
  }

  Future<Map<String, dynamic>> getOrganizationDetails({
    required String adminToken,
    required int id,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/organization/$id/details'),
      headers: _headers(adminToken),
    );
    return _parseJsonResponse(response);
  }

  Future<Map<String, dynamic>> deleteOrganization({
    required String adminToken,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/admin/organization/$id'),
      headers: _headers(adminToken),
    );
    return _parseJsonResponse(response);
  }

  Future<Map<String, dynamic>> getUserDetails({
    required String adminToken,
    required int id,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/users/$id/details'),
      headers: _headers(adminToken),
    );
    return _parseJsonResponse(response);
  }

  Future<Map<String, dynamic>> deleteUser({
    required String adminToken,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/admin/users/$id/delete'),
      headers: _headers(adminToken),
    );
    return _parseJsonResponse(response);
  }

  Future<Map<String, dynamic>> makeAdmin({
    required String adminToken,
    required int id,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/admin/users/$id/make-admin'),
      headers: _headers(adminToken),
    );
    return _parseJsonResponse(response);
  }

  Future<List<dynamic>> getDonations({required String adminToken}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/donations'),
      headers: _headers(adminToken),
    );
    return _parseListResponse(response, 'donations');
  }

  Future<Map<String, dynamic>> logout({required String adminToken}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/admin/logout'),
      headers: _headers(adminToken),
    );
    return _parseJsonResponse(response);
  }

  List<dynamic> _parseListResponse(http.Response response, String key) {
    if (response.statusCode != 200) {
      throw Exception(
        'Request failed: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map<String, dynamic>) {
      return List<dynamic>.from(decoded[key] ?? []);
    }
    return [];
  }

  Map<String, dynamic> _parseJsonResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception(
        'Request failed: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {'message': decoded.toString()};
  }
}
