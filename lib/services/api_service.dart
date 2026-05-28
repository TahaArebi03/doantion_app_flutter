import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8000/api'
      : 'http://10.0.2.2:8000/api';

  Future login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),

      body: {'email': email, 'password': password},
    );

    return jsonDecode(response.body);
  }
}
