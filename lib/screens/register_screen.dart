import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/database_helper.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;
  bool isLoading = false;
  bool isValidEmail(String email) {
    return RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
  }
  Future<void> register() async {
    setState(() => isLoading = true);
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();
      if (userDoc.exists) {
        setState(() => isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Email đã tồn tại'),
          ),
        );
        return;
      }
      await DatabaseHelper.instance.registerUser(name, email, password);
      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'name': name,
        'email': email,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text('Đăng kí thành công')),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }
  // Hàm tạo ô nhập liệu thích ứng theo chế độ sáng/tối
  InputDecoration customInput(String label, IconData icon, bool isDarkMode) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey.shade700),
      prefixIcon: Icon(icon, color: Colors.blue),
      filled: true,
      // Chế độ tối dùng màu xám đen đậm, chế độ sáng dùng xám trắng nhạt
      fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // Kiểm tra chế độ Dark Mode từ hệ thống
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      // Tự động chuyển nền đen khi qua Dark Mode
      backgroundColor: isDarkMode ? Colors.black : const Color(0xffF4F7FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        // Icon quay lại tự động đổi màu Trắng/Đen
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    size: 70,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tạo Tài Khoản',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    // Màu chữ tiêu đề theo chế độ
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 35),
                /// NAME
                TextFormField(
                  controller: nameController,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  decoration: customInput('Họ và tên', Icons.person, isDarkMode),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Họ và tên không được để trống';
                    if (value.trim().length < 3) return 'Tên quá ngắn';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                /// EMAIL
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  decoration: customInput('Email', Icons.email, isDarkMode),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email không được để trống';
                    if (!isValidEmail(value.trim())) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                /// PASSWORD
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  decoration: customInput('Mật khẩu', Icons.lock, isDarkMode).copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => hidePassword = !hidePassword),
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                        color: isDarkMode ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Mật khẩu không được để trống';
                    if (value.length != 6) return 'Mật khẩu phải đúng 6 kí tự bao gồm chữ và số';
                    if (!RegExp(r'[A-Za-z]').hasMatch(value)) return 'Mật khẩu phải có chữ';
                    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Mật khẩu phải có số';
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mật khẩu 6 kí tự bao gồm chữ và số',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) register();
                    },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Đăng kí',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}