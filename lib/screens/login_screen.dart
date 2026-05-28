import 'dart:convert';
import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // دالة الاتصال بالـ Laravel API
  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // 💡 ملاحظة: استبدل الـ IP بـ IP الجهاز بتاعك لو تجرب من جهاز حقيقي، أو 10.0.2.2 لو ايموليتر أندرويد
    final String apiUrl = kIsWeb
        ? 'http://127.0.0.1:8000/api/login'
        : 'http://10.0.2.2:8000/api/login';
    final url = Uri.parse(apiUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String token = responseData['token'];
        String role = responseData['user']['role'];

        // 🔥 نجح الدخول: هنا تخزن الـ Token في الـ Shared Preferences
        print('Logged in successfully! Token: $token');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
            backgroundColor: Colors.green,
          ),
        );

        // الانتقال للشاشة الرئيسية (مثال)
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        // فشل الدخول (بيانات خطأ أو حساب المنظمة pending)
        showError(responseData['message'] ?? 'Invalid credentials');
      }
    } catch (e) {
      showError('تعذر الاتصال بالسيرفر، تأكد من تشغيل الـ Wamp والـ Artisan');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ), // نفس الخلفية الرمادية الفاتحة في صورتك
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(
          color: Color(0xFF1E5631),
        ), // اللون الأخضر الداكن
        title: const Text(
          'تسجيل الدخول',
          style: TextStyle(
            color: Color(0xFF1E5631),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // لوقو أو أيقونة ترحيبية بروح التطبيق
              const Icon(
                Icons.volunteer_activism,
                size: 80,
                color: Color(0xFF1E5631),
              ),
              const SizedBox(height: 24),
              const Text(
                'مرحباً بك مجدداً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 40),

              // حقل البريد الإلكتروني (نفس ستايل حقول الكارد في صورتك)
              const Text(
                'البريد الإلكتروني',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'e.g. name@email.com',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (val) => val!.contains('@')
                    ? null
                    : 'الرجاء إدخال بريد إلكتروني صحيح',
              ),
              const SizedBox(height: 20),

              // حقل كلمة المرور
              const Text(
                'كلمة المرور',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '******',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (val) =>
                    val!.length >= 6 ? null : 'كلمة المرور قصيرة جداً',
              ),

              const SizedBox(height: 40),

              // زر التأكيد (زي زر الـ Confirm الأخضر العريض اللي لوطى في صورتك)
              ElevatedButton(
                onPressed: _isLoading ? null : loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF1E5631,
                  ), // الأخضر الداكن بتاعك
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ), // حواف دائرية بالكامل
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'دخول',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // رابط التحويل لشاشة التسجيل
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ليس لديك حساب؟ ',
                    style: TextStyle(color: Color(0xFF2D3142)),
                  ),
                  TextButton(
                    onPressed: () {
                      // حننتقلوا لشاشة الـ Register اللي حنديروها توا
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'أنشئ حساباً الآن',
                      style: TextStyle(
                        color: Color(0xFF1E5631),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
