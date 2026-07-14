import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';

class ProjectService {
  final String _baseUrl = 'http://127.0.0.1:8000';
  final String? _token;

  // منشئ مع توكن اختياري
  ProjectService({String? token}) : _token = token;

  // هيدرز – تستخدم التوكن المخزن إن لم يُمرر
  Map<String, String> _headers([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final t = token ?? _token;
    if (t != null) {
      headers['Authorization'] = 'Bearer $t';
    }
    return headers;
  }

  // 1. جلب كل المشاريع
  Future<List<ProjectModel>> getAllProjects() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/projects/all'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => ProjectModel.fromJson(item)).toList();
    } else {
      throw Exception('فشل في جلب كل المشاريع');
    }
  }

  // 2. جلب مشاريع جمعية معينة
  Future<List<ProjectModel>> getProjectsForOrganization(int orgId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/projects/$orgId/organization'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => ProjectModel.fromJson(item)).toList();
    } else {
      throw Exception('فشل في جلب مشاريع هذه الجمعية');
    }
  }

  // 3. عرض تفاصيل مشروع
  Future<ProjectModel> showProjectDetail(int projectId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/project/$projectId/show'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProjectModel.fromJson(data['project']);
    } else {
      throw Exception('فشل في جلب تفاصيل المشروع');
    }
  }

  // 4. إنشاء مشروع (يتطلب توكن)
  Future<ProjectModel> createProject({
    required String adminToken,
    required String title,
    required String description,
    required double goalAmount,
    String status = 'active',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/project/create'),
      headers: _headers(adminToken),
      body: jsonEncode({
        'title': title,
        'description': description,
        'goal_amount': goalAmount,
        'status': status,
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ProjectModel.fromJson(data['project']);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'فشل في إنشاء المشروع');
    }
  }

  // 5. تحديث مشروع
  Future<ProjectModel> updateProject({
    required String adminToken,
    required int projectId,
    required String title,
    required String description,
    required double goalAmount,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/project/$projectId/update'),
      headers: _headers(adminToken),
      body: jsonEncode({
        'title': title,
        'description': description,
        'goal_amount': goalAmount,
        'status': status,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProjectModel.fromJson(data['project']);
    } else {
      throw Exception('فشل في تحديث بيانات المشروع');
    }
  }

  // 6. حذف مشروع
  Future<bool> deleteProject({
    required String adminToken,
    required int projectId,
  }) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/project/$projectId/delete'),
      headers: _headers(adminToken),
    );
    return response.statusCode == 200;
  }
}