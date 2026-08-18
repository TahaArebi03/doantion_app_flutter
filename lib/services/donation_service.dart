import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/donation_model.dart';

class DonationService {
  final String _baseUrl = 'http://127.0.0.1:8000';
  final String token;

  DonationService(this.token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // جلب تبرعاتي
  Future<List<DonationModel>> getMyDonations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/donations/myDonations'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> donations = data['donations'] ?? [];
      return donations.map((d) => DonationModel.fromJson(d)).toList();
    }
    throw Exception('فشل جلب التبرعات');
  }

  // التبرع لمشروع
  Future<DonationModel> donateToProject(int projectId, double amount) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/donations/donate'),
      headers: _headers,
      body: jsonEncode({'project_id': projectId, 'amount': amount}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return DonationModel(
          id: 0,
          projectId: projectId,
          projectTitle: '',
          amount: amount,
          paymentMethod: 'wallet',
          status: 'success',
          createdAt: DateTime.now(),
        );
      }

      try {
        final data = jsonDecode(response.body);
        final donationData = data is Map && data.containsKey('donation')
            ? data['donation']
            : data is Map && data.containsKey('data') && data['data'] is Map
            ? data['data']['donation'] ?? data['data']
            : data;

        // if (donationData is Map) {
        //   return DonationModel.fromJson(donationData);
        // }

        return DonationModel(
          id: 0,
          projectId: projectId,
          projectTitle: '',
          amount: amount,
          paymentMethod: 'wallet',
          status: 'success',
          createdAt: DateTime.now(),
        );
      } catch (_) {
        return DonationModel(
          id: 0,
          projectId: projectId,
          projectTitle: '',
          amount: amount,
          paymentMethod: 'wallet',
          status: 'success',
          createdAt: DateTime.now(),
        );
      }
    }

    try {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? error['message'] ?? 'فشل التبرع');
    } catch (_) {
      throw Exception('فشل التبرع');
    }
  }
}
