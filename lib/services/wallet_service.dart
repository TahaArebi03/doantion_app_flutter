import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallet_model.dart';

class WalletService {
  final String _baseUrl = 'http://127.0.0.1:8000';
  final String token;

  WalletService(this.token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // جلب رصيد المحفظة
  Future<WalletModel> getWallet() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/wallet/show'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WalletModel.fromJson(data['wallet']);
    }
    throw Exception('فشل جلب رصيد المحفظة');
  }

  // شحن المحفظة
  Future<WalletModel> topUpWallet(double amount) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/wallet/top-up'),
      headers: _headers,
      body: jsonEncode({'amount': amount}),
    );

    // قراءة الجسم
    final responseBody = response.body;

    // إذا كان الجسم فارغاً أو غير صالح
    if (responseBody.isEmpty) {
      throw Exception('استجابة فارغة من الخادم');
    }

    // محاولة تحليل JSON
    dynamic data;
    try {
      data = jsonDecode(responseBody);
    } catch (e) {
      throw Exception('استجابة غير صالحة من الخادم: $responseBody');
    }

    if (response.statusCode == 200) {
      // تحقق من وجود حقل 'wallet'
      if (data is Map<String, dynamic> && data.containsKey('wallet')) {
        return WalletModel.fromJson(data['wallet']);
      } else {
        // قد يكون الرد يحتوي على رسالة نجاح ولكن بدون wallet
        throw Exception(data['message'] ?? 'تم الشحن ولكن لم يتم تحديث الرصيد');
      }
    } else {
      // خطأ من الخادم
      final errorMessage =
          data['error'] ?? data['message'] ?? 'فشل شحن المحفظة';
      throw Exception(errorMessage);
    }
  }
}
