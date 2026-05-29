// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lottie/lottie.dart';
// import '../database/database_helper.dart';
// import 'home_screen.dart';
// import 'register_screen.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   static String loggedInEmail = '';
//   static String loggedInPassword = '';
//   static String loggedInName = '';
//
//   static void clearUser() {
//     loggedInEmail = '';
//     loggedInPassword = '';
//     loggedInName = '';
//   }
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool hidePassword = true;
//   bool isLoading = false;
//   bool isValidEmail(String email) {
//     return RegExp(
//       r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//     ).hasMatch(email);
//   }
//   Future<void> login() async {
//     setState(() => isLoading = true);
//     final email = emailController.text.trim();
//     final password = passwordController.text.trim();
//     try {
//       bool success = await DatabaseHelper.instance.loginUser(email, password);
//       String? name;
//       if (success) {
//         final user = await DatabaseHelper.instance.getUserByEmail(email);
//         name = user?['name'];
//       } else {
//         final userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(email)
//             .get();
//         if (userDoc.exists && userDoc.data()?['password'] == password) {
//           success = true;
//           name = userDoc.data()?['name'];
//           await DatabaseHelper.instance.registerUser(
//             name ?? 'User',
//             email,
//             password,
//           );
//         }
//       }
//       if (success) {
//         LoginScreen.loggedInEmail = email;
//         LoginScreen.loggedInPassword = password;
//         LoginScreen.loggedInName = name ?? 'Patient User';
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(backgroundColor: Colors.green, content: Text('Đăng nhập thành công')),
//         );
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
//       } else {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(backgroundColor: Colors.red, content: Text('Email hoặc Password không hợp lệ')),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(backgroundColor: Colors.orange, content: Text('Lỗi: ${e.toString()}')),
//       );
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }
//   InputDecoration customInput(String label, IconData icon, bool isDarkMode) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: TextStyle(
//         color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
//         fontWeight: FontWeight.w500,
//       ),
//       prefixIcon: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 14),
//         child: Icon(icon, color: Colors.blue, size: 22),
//       ),
//       filled: true,
//       fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
//       contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(20),
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(20),
//         borderSide: const BorderSide(color: Colors.blue, width: 2),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(20),
//         borderSide: BorderSide(color: isDarkMode ? Colors.transparent : Colors.grey.shade300, width: isDarkMode ? 0 : 0.5),
//       ),
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     return Scaffold(
//       backgroundColor: isDarkMode ? Colors.black : const Color(0xffF4F7FC),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 30),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Thay vì dùng Center bọc ngoài, ta quản lý khoảng cách đỉnh đầu bằng khoảng này
//                 const SizedBox(height: 10),
//                 // Sử dụng Transform.translate để nhích nhẹ biểu tượng Lottie lên trên một chút (trục Y: -15)
//                 Transform.translate(
//                   offset: const Offset(0, -8),
//                   child: Lottie.asset(
//                     'assets/animations/splash_loading.json',
//                     width: 290,
//                     height: 290,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//                 // Co hẹp khoảng cách giữa hình và chữ "Chào Mừng Trở Lại" xuống còn 5px
//                 const SizedBox(height: 2),
//                 Text(
//                   'Chào Mừng Trở Lại',
//                   style: TextStyle(
//                     fontSize: 34,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 0.5,
//                     color: isDarkMode ? Colors.white : Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Đăng nhập để tiếp tục',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
//                   ),
//                 ),
//                 // Khoảng cách từ chữ xuống ô nhập liệu Email
//                 const SizedBox(height: 30),
//                 TextFormField(
//                   controller: emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16),
//                   decoration: customInput('Email', Icons.email, isDarkMode),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) return 'Email không được để trống';
//                     if (!isValidEmail(value.trim())) return 'Email không hợp lệ';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: passwordController,
//                   obscureText: hidePassword,
//                   style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16),
//                   decoration: customInput('Mật khẩu', Icons.lock, isDarkMode).copyWith(
//                     suffixIcon: Padding(
//                       padding: const EdgeInsets.only(right: 12),
//                       child: IconButton(
//                         onPressed: () => setState(() => hidePassword = !hidePassword),
//                         icon: Icon(
//                           hidePassword ? Icons.visibility_off : Icons.visibility,
//                           color: isDarkMode ? Colors.white54 : Colors.grey,
//                           size: 22,
//                         ),
//                       ),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) return 'Mật khẩu không được để trống';
//                     if (value.length < 6) return 'Tối thiểu 6 kí tự';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 35),
//                 Container(
//                   width: double.infinity,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xff4A90E2), Color(0xff357AE8)],
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xff357AE8).withOpacity(0.4),
//                         spreadRadius: 1,
//                         blurRadius: 12,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.transparent,
//                       shadowColor: Colors.transparent,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                     ),
//                     onPressed: isLoading ? null : () {
//                       if (_formKey.currentState!.validate()) login();
//                     },
//                     child: isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text(
//                       'Đăng nhập',
//                       style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const RegisterScreen()),
//                     );
//                   },
//                   child: Text(
//                     'Tạo tài khoản',
//                     style: TextStyle(
//                       color: isDarkMode ? Colors.blue.shade300 : Colors.blue,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20), // Tạo một khoảng đệm an toàn phía dưới cùng tránh lỗi tràn màn hình
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../database/database_helper.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static String loggedInEmail = '';
  static String loggedInPassword = '';
  static String loggedInName = '';

  static void clearUser() {
    loggedInEmail = '';
    loggedInPassword = '';
    loggedInName = '';
  }
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;
  bool isLoading = false;

  bool isValidEmail(String email) {
    return RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
  }

  Future<void> login() async {
    setState(() => isLoading = true);
    // Chuẩn hóa email về chữ thường để tránh lệch ký tự hoa/thường khi tra cứu
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    try {
      // BƯỚC 1: ƯU TIÊN KIỂM TRA ĐĂNG NHẬP DƯỚI SQLITE LOCAL TRƯỚC (Hoạt động hoàn hảo khi offline)
      bool success = await DatabaseHelper.instance.loginUser(email, password);
      String? name;

      if (success) {
        final user = await DatabaseHelper.instance.getUserByEmail(email);
        name = user?['name'];
      } else {
        // BƯỚC 2: NẾU LOCAL KHÔNG CÓ, TIẾN HÀNH KIỂM TRA TRÊN CLOUD FIREBASE
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(email)
              .get(const GetOptions(source: Source.serverAndCache)); // Ưu tiên kiểm tra linh hoạt

          if (userDoc.exists && userDoc.data()?['password'] == password) {
            success = true;
            name = userDoc.data()?['name'];

            // Đồng bộ ngược tài khoản này xuống SQLite local để lần sau không cần mạng vẫn vào được
            await DatabaseHelper.instance.registerUser(
              name ?? 'User',
              email,
              password,
            );
          }
        } on FirebaseException catch (fbEx) {
          // Bắt riêng lỗi mất kết nối mạng của Firebase để hiển thị thông báo tiếng Việt thân thiện
          if (fbEx.code == 'unavailable') {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.orange,
                content: Text('Không có kết nối internet. Vui lòng kiểm tra Wifi/4G hoặc đăng nhập bằng tài khoản đã lưu trên máy!'),
              ),
            );
            return; // Ngắt hàm luôn, không chạy tiếp xuống báo sai mật khẩu
          }
          rethrow; // Nếu là các lỗi Firebase khác thì ném ra ngoài cho catch lớn xử lý
        }
      }

      // BƯỚC 3: XỬ LÝ ĐIỀU HƯỚNG KHI KẾT QUẢ ĐĂNG NHẬP HOÀN TẤT
      if (success) {
        LoginScreen.loggedInEmail = email;
        LoginScreen.loggedInPassword = password;
        LoginScreen.loggedInName = name ?? 'Patient User';

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text('Đăng nhập thành công')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.red, content: Text('Email hoặc Mật khẩu không hợp lệ')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.orange, content: Text('Lỗi hệ thống: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration customInput(String label, IconData icon, bool isDarkMode) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Icon(icon, color: Colors.blue, size: 22),
      ),
      filled: true,
      fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: isDarkMode ? Colors.transparent : Colors.grey.shade300, width: isDarkMode ? 0 : 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xffF4F7FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Transform.translate(
                  offset: const Offset(0, -8),
                  child: Lottie.asset(
                    'assets/animations/splash_loading.json',
                    width: 290,
                    height: 290,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chào Mừng Trở Lại',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đăng nhập để tiếp tục',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16),
                  decoration: customInput('Email', Icons.email, isDarkMode),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email không được để trống';
                    if (!isValidEmail(value.trim())) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16),
                  decoration: customInput('Mật khẩu', Icons.lock, isDarkMode).copyWith(
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton(
                        onPressed: () => setState(() => hidePassword = !hidePassword),
                        icon: Icon(
                          hidePassword ? Icons.visibility_off : Icons.visibility,
                          color: isDarkMode ? Colors.white54 : Colors.grey,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Mật khẩu không được để trống';
                    if (value.length < 6) return 'Tối thiểu 6 kí tự';
                    return null;
                  },
                ),
                const SizedBox(height: 35),
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff4A90E2), Color(0xff357AE8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff357AE8).withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: isLoading ? null : () {
                      if (_formKey.currentState!.validate()) login();
                    },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Đăng nhập',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: Text(
                    'Tạo tài khoản',
                    style: TextStyle(
                      color: isDarkMode ? Colors.blue.shade300 : Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}