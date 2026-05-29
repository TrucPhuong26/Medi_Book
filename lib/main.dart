//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_localizations/flutter_localizations.dart'; // THÊM DÒNG NÀY
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'providers/theme_provider.dart';
// import 'screens/login_screen.dart';
// import 'package:firebase_core/firebase_core.dart'; // Thêm dòng này
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // Khởi tạo Firebase
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => ThemeProvider(),
//       child: Consumer<ThemeProvider>(
//         builder: (context, provider, child) {
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             themeMode: provider.themeMode,
//             // ===== THÊM PHẦN NÀY ĐỂ FIX LỖI MÀN HÌNH ĐỎ =====
//             localizationsDelegates: const [
//               GlobalMaterialLocalizations.delegate,
//               GlobalWidgetsLocalizations.delegate,
//               GlobalCupertinoLocalizations.delegate,
//             ],
//             supportedLocales: const [
//               Locale('vi', 'VN'), // Tiếng Việt
//               Locale('en', 'US'), // Tiếng Anh (dự phòng)
//             ],
//             locale: const Locale('vi', 'VN'), // Đặt ngôn ngữ mặc định là Việt Nam
//             // ================= LIGHT =================
//             theme: ThemeData(
//               brightness: Brightness.light,
//               primarySwatch: Colors.blue,
//               scaffoldBackgroundColor:
//               const Color(0xffF5F7FB),
//               cardColor: Colors.white,
//               appBarTheme: const AppBarTheme(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//             // ================= DARK =================
//             darkTheme: ThemeData(
//               brightness: Brightness.dark,
//               primarySwatch: Colors.blue,
//               // Nền ngoài màu đen
//               scaffoldBackgroundColor: const Color(0xff000000),
//               // Ép các Card mặc định vẫn màu trắng (theo yêu cầu của bạn)
//               cardColor: Colors.white,
//               // Cấu hình chữ chung cho toàn app khi ở Dark Mode
//               textTheme: const TextTheme(
//                 bodyLarge: TextStyle(color: Colors.white),
//                 bodyMedium: TextStyle(color: Colors.white),
//                 titleLarge: TextStyle(color: Colors.white),
//               ),
//               appBarTheme: const AppBarTheme(
//                 backgroundColor: Color(0xff1E88E5),
//                 foregroundColor: Colors.white,
//               ),
//             ),
//             home: const LoginScreen(),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔥 ĐÃ THÊM DÒNG NÀY ĐỂ CẤU HÌNH OFFLINE

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Firebase
  await Firebase.initializeApp();

  // 2. 🔥 CẤU HÌNH FIRESTORE CHẠY OFFLINE KHI MẤT WIFI/4G
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // Bật lưu cache offline dưới thiết bị
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Không giới hạn dung lượng bộ nhớ đệm
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: provider.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi', 'VN'), // Tiếng Việt
              Locale('en', 'US'), // Tiếng Anh (dự phòng)
            ],
            locale: const Locale('vi', 'VN'), // Đặt ngôn ngữ mặc định là Việt Nam

            // ================= LIGHT =================
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: const Color(0xffF5F7FB),
              cardColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            // ================= DARK =================
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: const Color(0xff000000),
              cardColor: Colors.white,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white),
                titleLarge: TextStyle(color: Colors.white),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xff1E88E5),
                foregroundColor: Colors.white,
              ),
            ),
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}