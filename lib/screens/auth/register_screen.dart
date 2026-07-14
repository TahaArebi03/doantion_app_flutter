import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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

  String _selectedRole = 'user'; // القيمة الافتراضية

  // حقول المنظمة الإضافية
  final _orgNameController = TextEditingController();
  final _orgDescController = TextEditingController();
  String _selectedOrgType = 'charity';

  bool _isLoading = false;

  // متغيرات اختيار الصورة المتوافقة مع الويب والموبايل
  XFile? _pickedXFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedXFile = pickedFile;
      });
    }
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == 'organization' && _pickedXFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار صورة إثبات الهوية للمنظمة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://127.0.0.1:8000/api/register');

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({'Accept': 'application/json'});
      request.fields['firstName'] = _firstNameController.text.trim();
      request.fields['lastName'] = _lastNameController.text.trim();
      request.fields['email'] = _emailController.text.trim();
      request.fields['password'] = _passwordController.text;
      request.fields['password_confirmation'] = _confirmPasswordController.text;
      request.fields['role'] = _selectedRole;

      if (_selectedRole == 'organization') {
        request.fields['name'] = _orgNameController.text.trim();
        request.fields['description'] = _orgDescController.text.trim();
        request.fields['type'] = _selectedOrgType;

        if (_pickedXFile != null) {
          final syncBytes = await _pickedXFile!.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'document_path',
              syncBytes,
              filename: _pickedXFile!.name,
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'تم إنشاء الحساب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              const SizedBox(height: 16),

              // حقول المنظمة (تظهر فقط عند اختيار حساب منظمة)
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
                  onChanged: (val) => setState(() => _selectedOrgType = val!),
                ),
                const SizedBox(height: 20),
                // اختيار صورة إثبات الهوية
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),

                  label: Text(
                    _pickedXFile == null
                        ? 'اختر صورة إثبات الهوية'
                        : 'تم اختيار الصورة: ${_pickedXFile!.name}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5631),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],

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
