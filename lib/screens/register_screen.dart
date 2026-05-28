import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // الحقول الأساسية لجميع الحسابات
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'user'; // القيمة الافتراضية (مستخدم عادي)

  // حقول المنظمة الإضافية (تظهر فقط لو اخترنا organization)
  final _orgNameController = TextEditingController();
  final _orgDescController = TextEditingController();
  String _selectedOrgType = 'charity'; // activist أو charity

  bool _isLoading = false;

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://127.0.0.1:8000/api/register');

    // تجهيز البيانات بناءً على شروط الـ Validate في الـ Laravel عندك
    Map<String, dynamic> requestBody = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _confirmPasswordController.text,
      'role': _selectedRole,
    };

    // لو الـ Role منظمة، ضيف الحقول الإضافية اللي يطلبها لارافيل
    if (_selectedRole == 'organization') {
      requestBody['name'] = _orgNameController.text.trim();
      requestBody['description'] = _orgDescController.text.trim();
      requestBody['type'] = _selectedOrgType;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // 201 تعني Created بنجاح في كودك
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // رجوعه لشاشة الـ Login بعد التسجيل
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'خطأ في البيانات'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر الاتصال بالسيرفر'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1E5631)),
        title: const Text(
          'إنشاء حساب جديد',
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
              // حقل الاسم الأول
              const Text(
                'الاسم الأول',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'الحقل مطلوب' : null,
              ),
              const SizedBox(height: 16),

              // حقل اسم العائلة
              const Text(
                'اللقب / اسم العائلة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'الحقل مطلوب' : null,
              ),
              const SizedBox(height: 16),

              // البريد الإلكتروني
              const Text(
                'البريد الإلكتروني',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'name@email.com',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) =>
                    val!.contains('@') ? null : 'بريد إلكتروني غير صحيح',
              ),
              const SizedBox(height: 16),

              // نوع الحساب (Role)
              const Text(
                'نوع الحساب',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'user',
                    child: Text('متبرع (مستخدم عادي)'),
                  ),
                  DropdownMenuItem(
                    value: 'organization',
                    child: Text('منظمة خيرية / جمعية'),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedRole = val!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 🔥 حقول إضافية تظهر فقط إذا اختار حساب "منظمة" عشان تطابق كود الـ Laravel
              if (_selectedRole == 'organization') ...[
                const Divider(height: 30, thickness: 2),
                const Text(
                  'اسم المنظمة',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _orgNameController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) =>
                      _selectedRole == 'organization' && val!.isEmpty
                      ? 'اسم المنظمة مطلوب'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'وصف المنظمة',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _orgDescController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) =>
                      _selectedRole == 'organization' && val!.isEmpty
                      ? 'الوصف مطلوب'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'نوع المنظمة',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedOrgType,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'charity',
                      child: Text('جمعية خيرية'),
                    ),
                    DropdownMenuItem(
                      value: 'activist',
                      child: Text('ناشط مدني'),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedOrgType = val!;
                    });
                  },
                ),
                const Divider(height: 30, thickness: 2),
              ],

              // كلمة المرور
              const Text(
                'كلمة المرور',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => val!.length >= 6
                    ? null
                    : 'كلمة المرور يجب أن لا تقل عن 6 أحرف',
              ),
              const SizedBox(height: 16),

              // تأكيد كلمة المرور
              const Text(
                'تأكيد كلمة المرور',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => val != _passwordController.text
                    ? 'كلمة المرور غير متطابقة'
                    : null,
              ),
              const SizedBox(height: 30),

              // زر التسجيل
              ElevatedButton(
                onPressed: _isLoading ? null : registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E5631),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'إنشاء الحساب',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
