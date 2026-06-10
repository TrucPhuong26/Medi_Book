import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/theme_provider.dart';
import '../database/database_helper.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  bool showPassword = false;
  Future<void> changePassword() async {
    final controller = TextEditingController();
    bool hideNewPassword = true;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xff2A2A2A) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_reset, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Thay đổi mật khẩu',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Đặt kích thước cố định vừa vặn
                      ),
                    ),
                  ),
                ],
              ),
              content: TextField(
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                controller: controller,
                obscureText: hideNewPassword,
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Nhập mật khẩu mới',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setDialogState(() {
                        hideNewPassword = !hideNewPassword;
                      });
                    },
                    icon: Icon(
                      hideNewPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    String newPass = controller.text.trim();
                    // --- KIỂM TRA ĐÚNG BẰNG 6 KÝ TỰ (BAO GỒM CHỮ VÀ SỐ) ---
                    RegExp passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6}$');
                    if (!passwordRegExp.hasMatch(newPass)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Mật khẩu phải đúng 6 kí tự, bao gồm cả chữ và số!'),
                        ),
                      );
                      return;
                    }
                    // --- BẬT VÒNG XOAY LOADING ---
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (loadingContext) => const Center(child: CircularProgressIndicator()),
                    );
                    try {
                      String userEmail = LoginScreen.loggedInEmail.trim().toLowerCase();
                      // 1. CẬP NHẬT ĐỒNG BỘ LÊN FIREBASE CLOUD FIRESTORE
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userEmail)
                          .update({'password': newPass});
                      // 2. CẬP NHẬT XUỐNG CƠ SỞ DỮ LIỆU LOCAL SQLITE
                      await DatabaseHelper.instance.updateUserPassword(
                        LoginScreen.loggedInEmail,
                        newPass,
                      );
                      // Cập nhật biến tạm thời để hiển thị trên UI ngay lập tức
                      setState(() {
                        LoginScreen.loggedInPassword = newPass;
                      });
                      if (!mounted) return;
                      // --- ĐIỀU CHỈNH POP CHÍNH XÁC ---
                      Navigator.of(context).pop(); // Tắt Dialog Loading trước
                      Navigator.of(context).pop(); // Tắt Dialog nhập mật khẩu sau
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Đổi mật khẩu đồng bộ hệ thống thành công!'),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      Navigator.of(context).pop(); // Tắt Dialog Loading nếu dính lỗi mạng
                      print("❌ Lỗi cập nhật mật khẩu hệ thống: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Không thể cập nhật lên Server Cloud: $e'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Lưu',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void logout() {
    LoginScreen.clearUser();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final isDark = provider.themeMode == ThemeMode.dark;
    Color titleColor = isDark ? Colors.white : Colors.black;
    Color subtitleColor = isDark ? Colors.white70 : Colors.black87;
    Color cardBgColor = isDark ? const Color(0xff1E1E1E) : Colors.white;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xffF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Trang cá nhân', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // AVATAR SECTION
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.withOpacity(0.6), width: 3),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 55, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LoginScreen.loggedInName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: titleColor),
            ),
            const SizedBox(height: 4),
            Text(
              LoginScreen.loggedInEmail,
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 30),
            // EMAIL CARD
            Card(
              color: cardBgColor,
              elevation: isDark ? 0 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.1)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xffE8F1FF),
                  child: Icon(Icons.email, color: Colors.blue),
                ),
                title: Text('Email', style: TextStyle(color: titleColor, fontWeight: FontWeight.bold)),
                subtitle: Text(LoginScreen.loggedInEmail, style: TextStyle(color: subtitleColor)),
              ),
            ),
            const SizedBox(height: 12),
            // PASSWORD CARD
            Card(
              color: cardBgColor,
              elevation: isDark ? 0 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.1)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xffFFF3E0),
                  child: Icon(Icons.lock, color: Colors.orange),
                ),
                title: Text('Mật khẩu', style: TextStyle(color: titleColor, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  showPassword ? LoginScreen.loggedInPassword : '••••••••',
                  style: TextStyle(color: subtitleColor, letterSpacing: showPassword ? 0 : 2),
                ),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  icon: Icon(
                    showPassword ? Icons.visibility_off : Icons.visibility,
                    color: isDark ? Colors.white60 : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // CHANGE PASSWORD ACTION CARD
            Card(
              color: cardBgColor,
              elevation: isDark ? 0 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.1)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xffE8F5E9),
                  child: Icon(Icons.password, color: Colors.green),
                ),
                title: Text('Thay đổi mật khẩu', style: TextStyle(color: titleColor, fontWeight: FontWeight.bold)),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white60 : Colors.black54),
                onTap: changePassword,
              ),
            ),
            const SizedBox(height: 12),
            // DARK MODE SWITCH CARD
            Card(
              color: cardBgColor,
              elevation: isDark ? 0 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.1)),
              ),
              child: SwitchListTile(
                activeColor: Colors.blue,
                secondary: const CircleAvatar(
                  backgroundColor: Color(0xffF3E5F5),
                  child: Icon(Icons.dark_mode, color: Colors.deepPurple),
                ),
                title: Text('Chế độ tối', style: TextStyle(color: titleColor, fontWeight: FontWeight.bold)),
                value: provider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  provider.toggleTheme(value);
                },
              ),
            ),
            const SizedBox(height: 40),
            // LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF44336),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 1,
                ),
                onPressed: logout,
                icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}