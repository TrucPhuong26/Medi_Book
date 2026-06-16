import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import './login_screen.dart';
import './booking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:io';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});
  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}
class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> appointments = [];
  late TabController _tabController;
  final List<String> availableTimes = [
    '08:00 SA', '09:00 SA', '10:00 SA',
    '01:00 CH', '02:00 CH', '03:00 CH',
  ];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  String safe(Map<String, dynamic> map, String key) {
    return (map[key] ?? '').toString().trim();
  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initNotificationsAndLoad();
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  // ================= KHỞI TẠO THÔNG BÁO & TIMEZONE =================
  Future<void> _initNotificationsAndLoad() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
    await loadAppointments();
  }
  // ================= THIẾT LẬP THÔNG BÁO NHẮC TRƯỚC 30 PHÚT =================
  Future<void> _scheduleAllAppointmentNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    for (var appointment in appointments) {
      String currentStatus = safe(appointment, 'status');
      if (currentStatus.isEmpty) currentStatus = 'upcoming';
      if (currentStatus != 'upcoming') continue;
      final dateStr = safe(appointment, 'date');
      final timeStr = safe(appointment, 'time');
      final doctorName = safe(appointment, 'doctor');
      final hospitalName = safe(appointment, 'hospital');
      final int notificationId = appointment['id'] is int
          ? appointment['id']
          : (appointment['fbId'] ?? '').hashCode;
      if (dateStr.isEmpty || timeStr.isEmpty) continue;
      try {
        String cleanTime = timeStr;
        bool isPM = cleanTime.contains('CH');
        cleanTime = cleanTime.replaceAll('SA', '').replaceAll('CH', '').trim();
        List<String> timeParts = cleanTime.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        if (isPM && hour < 12) hour += 12;
        if (!isPM && hour == 12) hour = 0;
        String formattedHour = hour.toString().padLeft(2, '0');
        String formattedMinute = minute.toString().padLeft(2, '0');
        final appointmentDateTime = DateTime.parse("$dateStr $formattedHour:$formattedMinute:00");
        final notificationDateTime = appointmentDateTime.subtract(const Duration(minutes: 30));
        final now = DateTime.now();
        if (notificationDateTime.isAfter(now)) {
          final tz.TZDateTime tzNotificationTime = tz.TZDateTime.from(notificationDateTime, tz.local);
          const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'medibook_reminders_channel',
            'Nhắc lịch khám bệnh',
            channelDescription: 'Kênh gửi thông báo nhắc lịch hẹn khám Medibook trước 30 phút',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          );
          const NotificationDetails platformChannelSpecifics = NotificationDetails(
            android: androidPlatformChannelSpecifics,
          );
          await flutterLocalNotificationsPlugin.zonedSchedule(
            notificationId,
            '⏰ Nhắc nhở: Sắp đến giờ khám bệnh!',
            'Bạn có lịch hẹn với $doctorName tại $hospitalName vào lúc $timeStr hôm nay.',
            tzNotificationTime,
            platformChannelSpecifics,
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      } catch (e) {
        print("Lỗi khi lập lịch thông báo cho ID $notificationId: $e");
      }
    }
  }
  Future<void> loadAppointments() async {
    // 1. LOAD LOCAL SQLITE TRƯỚC ĐỂ MƯỢT UI
    final localData = await DatabaseHelper.instance.getAppointmentsByUser(
      LoginScreen.loggedInEmail,
    );
    setState(() {
      appointments = List<Map<String, dynamic>>.from(localData);
    });
    try {
      // 2. LẤY DỮ LIỆU TỪ FIREBASE (Sử dụng real-time từ Server để lấy hàng đợi chuẩn xác)
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userEmail', isEqualTo: LoginScreen.loggedInEmail)
          .get();
      final firebaseData = snapshot.docs.map((doc) {
        var data = doc.data();
        data['fbId'] = doc.id; // Đồng bộ key lưu trữ ID Firebase
        return data;
      }).toList();
      if (firebaseData.isNotEmpty) {
        setState(() {
          appointments = firebaseData;
        });
        // ================= AUTO QUÉT CHUYỂN TRẠNG THÁI HẾT HẠN (QUÁ 24H) =================
        List<Future<void>> expireUpdates = [];
        for (var item in firebaseData) {
          String status = safe(item, 'status');
          if (status.isEmpty) status = 'upcoming';
          if (status == 'upcoming') {
            String dateStr = safe(item, 'date');
            String timeStr = safe(item, 'time');
            if (isExpired(dateStr, timeStr)) {
              String? fbId = item['fbId'];
              if (fbId != null && fbId.isNotEmpty) {
                // Đưa vào mảng đợi để xử lý đồng bộ, không để chạy ngầm mất kiểm soát
                expireUpdates.add(FirebaseFirestore.instance
                    .collection('appointments')
                    .doc(fbId)
                    .update({'status': 'expired'}));
              }
              final db = await DatabaseHelper.instance.database;
              expireUpdates.add(db.update(
                'appointments',
                {'status': 'expired'},
                where: 'userEmail = ? AND date = ? AND time = ?',
                whereArgs: [LoginScreen.loggedInEmail, dateStr, timeStr],
              ));
            }
          }
        }
        // Chờ tất cả tiến trình quét hết hạn xong xuôi hoàn toàn
        if (expireUpdates.isNotEmpty) {
          await Future.wait(expireUpdates);
          // Cập nhật lại giao diện cục bộ sau khi quét hết hạn hoàn tất
          final updatedLocalData = await DatabaseHelper.instance.getAppointmentsByUser(
            LoginScreen.loggedInEmail,
          );
          setState(() {
            appointments = List<Map<String, dynamic>>.from(updatedLocalData);
          });
        }
      }
    } catch (e) {
      print("Lỗi tự động cập nhật trạng thái hết hạn: $e");
    }
    await _scheduleAllAppointmentNotifications();
  }
  // 1. HÀM CẬP NHẬT TRẠNG THÁI (ĐÃ TỐI ƯU: CHỈ ĐÔN STT KHI CÓ MẠNG THÀNH CÔNG)
  Future<void> _updateAppointmentStatus(
      dynamic sqliteId,
      String? firebaseId,
      String newStatus,
      String successMsg,
      Map<String, dynamic> appointmentItem,
      ) async {
    String? validFbId = (firebaseId == null || firebaseId.isEmpty) ? appointmentItem['fbId'] : firebaseId;
    try {
      // 1.1 XỬ LÝ TRÊN FIREBASE
      if (validFbId != null && validFbId.isNotEmpty) {
        String hospital = safe(appointmentItem, 'hospital');
        String specialty = safe(appointmentItem, 'specialty');
        String date = safe(appointmentItem, 'date');
        String time = safe(appointmentItem, 'time').trim().replaceAll(RegExp(r'\s+'), ' ');

        int myStt = appointmentItem['stt'] is int
            ? appointmentItem['stt']
            : int.tryParse(safe(appointmentItem, 'stt')) ?? 0;

        // Cập nhật trạng thái lịch hẹn của chính mình
        FirebaseFirestore.instance
            .collection('appointments')
            .doc(validFbId)
            .update({'status': newStatus})
            .then((_) async {
          print("Firebase: Đã cập nhật status sang [$newStatus] thành công trên Server!");

          // CHỈ KHI CẬP NHẬT LÊN SERVER THÀNH CÔNG VÀ LÀ LỆNH HỦY LỊCH THÌ MỚI ĐÔN STT NHAU
          if (newStatus == 'cancelled') {
            try {
              print("Hệ thống có mạng: Bắt đầu tính toán đôn dịch hàng đợi trên Server...");
              // Lấy danh sách trực tiếp từ Server để đảm bảo tính chính xác
              final queueSnapshot = await FirebaseFirestore.instance
                  .collection('appointments')
                  .where('hospital', isEqualTo: hospital)
                  .where('specialty', isEqualTo: specialty)
                  .where('date', isEqualTo: date)
                  .where('time', isEqualTo: time)
                  .get(const GetOptions(source: Source.server));

              List<Future<void>> clearQueueFutures = [];
              for (var doc in queueSnapshot.docs) {
                if (doc.id == validFbId) continue;
                String status = (doc.data()['status'] ?? 'upcoming').toString();
                if (status == 'cancelled' || status == 'completed' || status == 'archived' || status == 'expired') {
                  continue;
                }
                int currentStt = doc.data()['stt'] ?? 0;
                if (currentStt > myStt) {
                  clearQueueFutures.add(doc.reference.update({'stt': currentStt - 1}));
                }
              }
              if (clearQueueFutures.isNotEmpty) {
                await Future.wait(clearQueueFutures);
                print("Đã đôn STT của các người dùng phía sau thành công trên Server.");
              }
            } catch (queueError) {
              print("Lỗi đôn STT khi chạy trên server: $queueError");
            }
          }
        })
            .catchError((e) {
          // Khi máy offline, lệnh update status ở trên vẫn lọt vào đây hoặc nằm đợi ngầm,
          // nhưng vì không chạy vào block .then() nên hàng đợi STT của người sau hoàn toàn GIỮ NGUYÊN.
          print("Firebase ngầm: Đang đợi kết nối mạng để đồng bộ dữ liệu... ($e)");
        });
      }

      // 1.2 XỬ LÝ ĐỒNG BỘ TRÊN SQLITE LOCAL (Luôn luôn ăn ngay lập tức bất kể offline)
      try {
        final db = await DatabaseHelper.instance.database;
        if (sqliteId != null && sqliteId is int) {
          await DatabaseHelper.instance.updateAppointmentStatus(sqliteId, newStatus);
        } else {
          String dateStr = safe(appointmentItem, 'date');
          String timeStr = safe(appointmentItem, 'time');
          String emailStr = safe(appointmentItem, 'userEmail').isEmpty
              ? LoginScreen.loggedInEmail
              : safe(appointmentItem, 'userEmail');
          String hospitalStr = safe(appointmentItem, 'hospital');
          await db.update(
            'appointments',
            {'status': newStatus},
            where: 'userEmail = ? AND date = ? AND time = ? AND hospital = ?',
            whereArgs: [emailStr, dateStr, timeStr, hospitalStr],
          );
        }
      } catch (ex) {
        print("SQLite update lỗi: $ex");
      }

      // 1.3 REFRESH LẠI TOÀN BỘ DATA ĐỂ CẬP NHẬT UI TRÊN MÀN HÌNH NGAY LẬP TỨC
      await loadAppointments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(successMsg),
        ),
      );
    } catch (e) {
      print("Lỗi tổng quát khi cập nhật trạng thái: $e");
    }
  }
  //  2. XỬ LÝ HỦY LỊCH HẸN (GIAO DIỆN DIALOG)
  Future<void> deleteAppointment(dynamic sqliteId, String? firebaseId, Map<String, dynamic> item) async {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Hủy lịch hẹn', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
          content: Text('Bạn có chắc muốn hủy lịch này?', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Không'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Có', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      final int notificationId = sqliteId is int ? sqliteId : (firebaseId ?? '').hashCode;
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      await _updateAppointmentStatus(sqliteId, firebaseId, 'cancelled', 'Đã hủy lịch hẹn thành công', item);
    }
  }
  // 3. XỬ LÝ ẨN KHỎI LỊCH SỬ (GIAO DIỆN DIALOG)
  Future<void> archiveHistoryItem(dynamic sqliteId, String? firebaseId, Map<String, dynamic> item) async {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Ẩn lịch sử', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
          content: Text('Bạn muốn ẩn lịch hẹn cũ này khỏi giao diện hiển thị?', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Không'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade700),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ẩn đi', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      await _updateAppointmentStatus(sqliteId, firebaseId, 'archived', 'Đã ẩn lịch hẹn khỏi danh sách hiển thị', item);
    }
  }
  // 1. HÀM PHỤ DÙNG CHUNG (Gom toàn bộ logic phân tích thời gian phức tạp vào đây)
  DateTime? _parseAppointmentDateTime(dynamic dateInput, String? timeStr) {
    if (dateInput == null) return null;
    try {
      // Xử lý Giờ (SA/CH)
      String cleanTime = timeStr ?? "00:00";
      bool isPM = cleanTime.contains('CH');
      cleanTime = cleanTime.replaceAll('SA', '').replaceAll('CH', '').trim();

      List<String> timeParts = cleanTime.split(':');
      int hour = int.parse(timeParts[0].trim());
      int minute = int.parse(timeParts[1].trim());

      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      // Xử lý Ngày (Chấp nhận cả chuỗi String hoặc đối tượng DateTime truyền vào)
      DateTime parsedDate;
      if (dateInput is DateTime) {
        parsedDate = dateInput;
      } else {
        String dateStr = dateInput.toString().trim();
        if (dateStr.contains('/')) {
          List<String> dateParts = dateStr.split('/');
          parsedDate = DateTime(int.parse(dateParts[2].trim()), int.parse(dateParts[1].trim()), int.parse(dateParts[0].trim()));
        } else if (dateStr.contains('-') && dateStr.indexOf('-') == 2) {
          List<String> dateParts = dateStr.split('-');
          parsedDate = DateTime(int.parse(dateParts[2].trim()), int.parse(dateParts[1].trim()), int.parse(dateParts[0].trim()));
        } else {
          parsedDate = DateTime.parse(dateStr);
        }
      }

      return DateTime(parsedDate.year, parsedDate.month, parsedDate.day, hour, minute);
    } catch (e) {
      print("Lỗi phân tích thời gian: $e");
      return null;
    }
  }
  // 2. HÀM CHECK THỜI GIAN QUÁ HẠN ĐỂ BLOCK NÚT (Sử dụng hàm chung ở trên)
  bool _isTimePast(DateTime selectedDate, String timeStr) {
    final appointmentDateTime = _parseAppointmentDateTime(selectedDate, timeStr);
    if (appointmentDateTime == null) return false;

    return DateTime.now().isAfter(appointmentDateTime);
  }
  // 3. HÀM ĐÃ QUA GIỜ KHÁM (Dùng cho chuỗi ngày lấy từ Database)
  bool isPastAppointment(String? dateStr, String? timeStr) {
    final appointmentDateTime = _parseAppointmentDateTime(dateStr, timeStr);
    if (appointmentDateTime == null) return false;

    return DateTime.now().isAfter(appointmentDateTime);
  }
  // 5. POPUP CHỌN NGÀY VÀ GIỜ MỚI KHI THAY ĐỔI LỊCH KHÁM
  Future<void> editAppointment(dynamic sqliteId, String? firebaseId, String currentDate, String currentTime, Map<String, dynamic> fullAppointment) async {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    DateTime selectedDate = DateTime.tryParse(currentDate) ?? DateTime.now();
    if (selectedDate.isBefore(DateTime.now())) selectedDate = DateTime.now();
    String selectedTime = currentTime.trim();
    if (!availableTimes.contains(selectedTime)) {
      selectedTime = availableTimes.first;
    }
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            String dateDisplay = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
            return AlertDialog(
              backgroundColor: isDarkMode ? const Color(0xff2A2A2A) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_calendar, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Thay đổi lịch khám',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Chọn ngày khám mới:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setPopupState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                          color: isDarkMode ? Colors.white10 : Colors.blue.withOpacity(0.05),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(dateDisplay, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 15)),
                            const Icon(Icons.calendar_month, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('2. Chọn khung giờ mới:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    // Bọc Wrap vào SizedBox với double.infinity để tối ưu khoảng không gian dàn trải nút bấm
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        children: availableTimes.map((time) {
                          bool isSelected = selectedTime == time;
                          bool isPast = _isTimePast(selectedDate, time);
                          return InkWell(
                            onTap: isPast
                                ? null
                                : () {
                              setPopupState(() {
                                selectedTime = time;
                              });
                            },
                            child: Container(
                              // padding tối ưu lại một chút phòng khi chữ quá to ở màn hình nhỏ
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isPast
                                    ? (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100])
                                    : (isSelected ? Colors.blue : (isDarkMode ? Colors.white10 : Colors.grey[200])),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isPast
                                      ? (isDarkMode ? Colors.white12 : Colors.grey[300]!)
                                      : (isSelected ? Colors.blue : (isDarkMode ? Colors.white24 : Colors.grey[300]!)),
                                ),
                              ),
                              child: Text(
                                time,
                                style: TextStyle(
                                  color: isPast
                                      ? (isDarkMode ? Colors.white30 : Colors.grey[400])
                                      : (isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87)),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  decoration: isPast ? TextDecoration.lineThrough : TextDecoration.none,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy thay đổi', style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey[600])),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (_isTimePast(selectedDate, selectedTime)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Khung giờ được chọn không hợp lệ hoặc đã trôi qua!')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    await _saveUpdatedData(sqliteId, firebaseId, dateDisplay, selectedTime, fullAppointment);
                  },
                  child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // HÀM ĐỔI LỊCH: CHỈ CHO ĐỔI KHI ONLINE, OFFLINE CHẶN ĐỨNG BÁO KẾT NỐI INTERNET
  Future<void> _saveUpdatedData(dynamic sqliteId, String? firebaseId, String formattedDate, String formattedTime, Map<String, dynamic> fullAppointment) async {
    print("============= ĐÃ KÍCH HOẠT HÀM ĐỔI LỊCH THÀNH CÔNG =============");
    // BƯỚC 1: KIỂM TRA MẠNG KHẨN CẤP (OFFLINE THÌ KHÔNG CHO ĐỔI LỊCH)
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 2));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw const SocketException("NO_INTERNET");
      }
    } catch (_) {
      // Nếu không có mạng (hoặc quá 2 giây timeout), dừng hàm và hiện thông báo yêu cầu kết nối ngay
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Không có kết nối Internet! Vui lòng kết nối Wifi/4G để tiến hành đổi lịch khám mới.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
      return; // Chặn đứng tại đây, không chạy xuống code cập nhật dữ liệu phía dưới
    }
    // BƯỚC 2: XỬ LÝ ĐỔI LỊCH (CHỈ CHẠY KHI ĐÃ XÁC NHẬN CÓ MẠNG 100%)
    String? validFbId = (firebaseId == null || firebaseId.isEmpty) ? fullAppointment['fbId'] : firebaseId;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      String oldDate = safe(fullAppointment, 'date');
      String oldTime = safe(fullAppointment, 'time').trim().replaceAll(RegExp(r'\s+'), ' ');
      String hospital = safe(fullAppointment, 'hospital');
      String specialty = safe(fullAppointment, 'specialty');
      int oldStt = fullAppointment['stt'] is int
          ? fullAppointment['stt']
          : int.tryParse(safe(fullAppointment, 'stt')) ?? 0;
      String newTimeFormatted = formattedTime.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (!newTimeFormatted.contains('SA') && !newTimeFormatted.contains('CH')) {
        List<String> parts = newTimeFormatted.split(':');
        int hour = int.parse(parts[0]);
        newTimeFormatted = (hour >= 12) ? "$newTimeFormatted CH" : "$newTimeFormatted SA";
      }
      newTimeFormatted = newTimeFormatted.replaceAll(RegExp(r'\s+'), ' ');
      if (oldDate == formattedDate && oldTime == newTimeFormatted) {
        Navigator.pop(context);
        return;
      }
      // Đọc trực tiếp dữ liệu chính xác tuyệt đối từ SERVER đám mây
      final newSlotSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('hospital', isEqualTo: hospital)
          .where('specialty', isEqualTo: specialty)
          .where('date', isEqualTo: formattedDate)
          .where('time', isEqualTo: newTimeFormatted)
          .get(const GetOptions(source: Source.server));

      final validAppointmentsInNewSlot = newSlotSnapshot.docs.where((doc) {
        if (doc.id == validFbId) return false;
        String status = (doc.data()['status'] ?? 'upcoming').toString();
        return status == 'upcoming';
      }).toList();
      int currentNewSlotCount = validAppointmentsInNewSlot.length;
      const int maxSlot = 2;
      // Nếu online check thấy full thật thì báo đầy lịch
      if (currentNewSlotCount >= maxSlot) {
        throw Exception("SLOT_FULL");
      }
      int newStt = currentNewSlotCount + 1;
      // Đồng bộ trực tiếp lên Firebase (Vì đang có mạng nên cập nhật ngay)
      if (validFbId != null && validFbId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(validFbId)
            .update({
          'date': formattedDate,
          'time': newTimeFormatted,
          'stt': newStt,
        });
        // Đôn lịch khung giờ cũ
        final oldSlotSnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .where('hospital', isEqualTo: hospital)
            .where('specialty', isEqualTo: specialty)
            .where('date', isEqualTo: oldDate)
            .where('time', isEqualTo: oldTime)
            .get(const GetOptions(source: Source.server));

        List<Future<void>> updateQueueFutures = [];
        for (var doc in oldSlotSnapshot.docs) {
          if (doc.id == validFbId) continue;
          String status = (doc.data()['status'] ?? 'upcoming').toString();
          if (status == 'cancelled' || status == 'completed' || status == 'archived' || status == 'expired') {
            continue;
          }
          int currentStt = doc.data()['stt'] ?? 0;
          if (currentStt > oldStt) {
            updateQueueFutures.add(doc.reference.update({'stt': currentStt - 1}));
          }
        }
        if (updateQueueFutures.isNotEmpty) {
          await Future.wait(updateQueueFutures);
        }
      }
      // Cập nhật SQLite cục bộ dưới máy để đồng bộ giao diện người dùng
      final db = await DatabaseHelper.instance.database;
      if (sqliteId != null && sqliteId is int) {
        await DatabaseHelper.instance.updateAppointmentTime(sqliteId, formattedDate, newTimeFormatted, newStt);
      } else {
        String emailStr = safe(fullAppointment, 'userEmail').isEmpty
            ? LoginScreen.loggedInEmail
            : safe(fullAppointment, 'userEmail');

        await db.update(
          'appointments',
          {
            'date': formattedDate,
            'time': newTimeFormatted,
            'stt': newStt
          },
          where: 'userEmail = ? AND date = ? AND time = ? AND hospital = ? AND specialty = ?',
          whereArgs: [emailStr, oldDate, oldTime, hospital, specialty],
        );
      }
      Navigator.pop(context); // Tắt màn hình chờ
      await loadAppointments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text('Cập nhật lịch khám và đôn dịch số thứ tự thành công!')),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (e.toString().contains("SLOT_FULL")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Khung giờ $formattedTime ngày $formattedDate đã đầy 2/2 slot. Vui lòng chọn giờ khác!'),
          ),
        );
      } else {
        print("Lỗi hệ thống khi dồn STT hàng đợi: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi xảy ra trong quá trình đổi lịch và dồn hàng đợi')),
        );
      }
    }
  }
// ================= KIỂM TRA ĐIỀU KIỆN ĐƯỢC ĐỔI LỊCH (TRƯỚC 24H) =================
  bool canEdit(String? dateStr, String? timeStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      String cleanTime = timeStr ?? "00:00";
      bool isPM = cleanTime.contains('CH');
      cleanTime = cleanTime.replaceAll('SA', '').replaceAll('CH', '').trim();
      List<String> timeParts = cleanTime.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      String formattedHour = hour.toString().padLeft(2, '0');
      String formattedMinute = minute.toString().padLeft(2, '0');
      final appointmentDateTime = DateTime.parse("$dateStr $formattedHour:$formattedMinute:00");
      final now = DateTime.now();
      return appointmentDateTime.difference(now).inHours >= 24;
    } catch (e) {
      print("Lỗi phân tích ngày giờ canEdit: $e");
      return false;
    }
  }
  // 4. HÀM TỰ ĐỘNG HẾT HẠN SAU 1 NGÀY
  bool isExpired(String? dateStr, String? timeStr) {
    final appointmentDateTime = _parseAppointmentDateTime(dateStr, timeStr);
    if (appointmentDateTime == null) return false;

    final expiredTime = appointmentDateTime.add(const Duration(days: 1));
    return DateTime.now().isAfter(expiredTime);
  }
  String getHospitalAddress(String hospital) {
    switch (hospital) {
      case 'BV Chợ Rẫy': return '201B Nguyễn Chí Thanh, Q5, TP.HCM';
      case 'BV Đại học Y Dược': return '215 Hồng Bàng, Q5, TP.HCM';
      case 'BV Hoàn Mỹ Cửu Long': return '20 Võ Nguyên Giáp, Cần Thơ';
      case 'BV Đa khoa TW Cần Thơ':
      case 'BV Đa khoa Trung Ương Cần Thơ': return '315 Nguyễn Văn Linh, Cần Thơ';
      default: return 'Đang cập nhật';
    }
  }
  Widget buildInfoItem(IconData icon, Color color, String text, bool isDarkMode, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: maxLines == 1 ? TextOverflow.ellipsis : TextOverflow.clip,
            style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.white70 : Colors.black87),
          ),
        ),
      ],
    );
  }
  // ================= DANH SÁCH RENDERING PHÂN CHIA TAB =================
  Widget buildAppointmentList(List<Map<String, dynamic>> filteredList, bool isHistoryTab, bool isDarkMode, bool isLandscape) {
    if (filteredList.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/empty_appointment.json',
                        width: isLandscape ? 140 : 220,
                        height: isLandscape ? 140 : 220,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        isHistoryTab ? 'Không có lịch sử khám' : 'Chưa có lịch hẹn nào',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isHistoryTab
                            ? 'Bạn chưa có lịch hẹn nào đã hết hạn, đã hủy hoặc hoàn thành.'
                            : 'Bạn chưa đặt bất kỳ lịch khám nào.\nHãy đặt lịch để theo dõi sức khỏe nhé!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      if (!isHistoryTab) ...[
                        const SizedBox(height: 25),
                        SizedBox(
                          width: 195,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 2,
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const BookingScreen()),
                              );
                              await loadAppointments();
                            },
                            icon: const Icon(Icons.add_circle_outline, size: 20),
                            label: const Text('Đặt lịch ngay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final appointment = filteredList[index];
        final dateStr = safe(appointment, 'date');
        final timeStr = safe(appointment, 'time');
        final status = safe(appointment, 'status').isEmpty ? 'upcoming' : safe(appointment, 'status');
        final sqliteId = appointment['id'];
        final firebaseId = appointment['fbId'];
        final symptoms = safe(appointment, 'symptom');
        final editable = (status == 'upcoming') && canEdit(dateStr, timeStr);
        final String sttValue = appointment['stt'] != null ? appointment['stt'].toString() : '--';
        String patientName = safe(appointment, 'fullName');
        if (patientName.isEmpty) {
          patientName = safe(appointment, 'userEmail');
        }
        Color statusBgColor = Colors.green.withOpacity(0.1);
        Color statusTextColor = Colors.green;
        String statusLabel = 'Sắp tới';
        if (status == 'cancelled') {
          statusBgColor = Colors.red.withOpacity(0.1);
          statusTextColor = Colors.red;
          statusLabel = 'Đã hủy';
        } else if (status == 'completed') {
          statusBgColor = Colors.green.withOpacity(0.1);
          statusTextColor = Colors.green;
          statusLabel = 'Đã khám';
        } else if (status == 'expired') {
          statusBgColor = Colors.orange.withOpacity(0.1);
          statusTextColor = Colors.orange;
          statusLabel = 'Hết hạn';
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: Card(
            color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
            elevation: isDarkMode ? 0 : 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDarkMode ? Colors.white12 : Colors.grey.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: const Icon(Icons.person, color: Colors.blue, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              safe(appointment, 'doctor'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  safe(appointment, 'specialty'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDarkMode ? Colors.white54 : Colors.grey,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    safe(appointment, 'room').isEmpty ? 'Phòng: --' : 'P. ${safe(appointment, "room")}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.purple,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (status == 'upcoming') ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Text(
                                'STT: $sttValue',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildInfoItem(Icons.assignment_ind, Colors.purple, 'Bệnh nhân: $patientName', isDarkMode),
                            const SizedBox(height: 6),
                            buildInfoItem(Icons.local_hospital, Colors.red, safe(appointment, 'hospital'), isDarkMode),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildInfoItem(Icons.calendar_today, Colors.orange, 'Ngày: $dateStr', isDarkMode),
                            const SizedBox(height: 6),
                            buildInfoItem(Icons.access_time, Colors.green, 'Giờ: $timeStr', isDarkMode),
                            if (editable) ...[
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => editAppointment(sqliteId, firebaseId, dateStr, timeStr, appointment),
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.edit_calendar, color: Colors.blue, size: 15),
                                      SizedBox(width: 4),
                                      Text(
                                        'Đổi ngày/giờ',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildInfoItem(
                    Icons.location_on,
                    Colors.blue,
                    getHospitalAddress(safe(appointment, 'hospital')),
                    isDarkMode,
                    maxLines: 3,
                  ),
                  if (symptoms.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      '📌 Triệu chứng: $symptoms',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  // ================= ĐỔI THIẾT KẾ NÚT CHO TỪNG LOẠI TAB VÀ TRẠNG THÁI =================
                  if (!isHistoryTab) ...[
                    Row(
                      children: [
                        // NẾU ĐÃ QUA GIỜ KHÁM: Chỉ hiện duy nhất 1 nút "Đã khám xong" full chiều rộng
                        if (isPastAppointment(dateStr, timeStr))
                          Expanded(
                            child: Container(
                              height: 40,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => _updateAppointmentStatus(sqliteId, firebaseId, 'completed', 'Xác nhận đã hoàn thành ca khám!', appointment),
                                icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                label: const Text('Đã khám xong', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                          )
                        // NẾU CHƯA QUA GIỜ KHÁM: Chỉ hiện nút "Hủy lịch hẹn"
                        else
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: const Color(0xffF44336),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => deleteAppointment(sqliteId, firebaseId, appointment),
                                icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                                label: const Text('Hủy lịch hẹn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: isDarkMode ? Colors.white12 : Colors.grey.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => archiveHistoryItem(sqliteId, firebaseId, appointment),
                        icon: Icon(Icons.visibility_off, color: isDarkMode ? Colors.white70 : Colors.black87, size: 18),
                        label: Text(
                          'Ẩn lịch sử hiển thị',
                          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  DateTime getAppointmentDateTime(Map<String, dynamic> item) {
    try {
      String dateStr = safe(item, 'date');
      String timeStr = safe(item, 'time');
      bool isPM = timeStr.contains('CH');
      timeStr = timeStr
          .replaceAll('SA', '')
          .replaceAll('CH', '')
          .trim();
      List<String> parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      DateTime date = DateTime.parse(dateStr);
      return DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
    } catch (e) {
      return DateTime(2100); // fallback
    }
  }
  // ================= UI CHÍNH PHÂN TAB SẮP TỚI & LỊCH SỬ MỚI =================
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    // Tự động lấy Email người dùng hiện tại từ danh sách appointments sẵn có của bạn
    String loggedInUserEmail = '';
    if (appointments.isNotEmpty) {
      loggedInUserEmail = safe(appointments.first, 'userEmail');
    }
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xffF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Lịch hẹn của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      // Sử dụng StreamBuilder để lắng nghe Firebase cập nhật số thứ tự Real-time
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userEmail', isEqualTo: loggedInUserEmail) // Lọc đúng lịch của máy đang bật
            .snapshots(),
        builder: (context, snapshot) {
          // Nếu đang tải dữ liệu từ Firebase lần đầu
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }
          // Tự động nạp dữ liệu mới mỗi khi trên Server có biến động nhảy số
          List<Map<String, dynamic>> realtimeAppointments = [];
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              data['fbId'] = doc.id; // Giữ nguyên ID để các nút Hủy/Đổi lịch chạy đúng
              realtimeAppointments.add(data);
            }
          } else {
            // Bọc hờ nếu Firebase trống thì dùng tạm list cũ của bạn
            realtimeAppointments = appointments;
          }
          // --- logic lọc Sắp tới ---
          final upcomingAppointments = realtimeAppointments.where((item) {
            String status = safe(item, 'status');
            if (status.isEmpty) {
              status = 'upcoming';
            }
            return status == 'upcoming';
          }).toList()
            ..sort((a, b) {
              DateTime dateA = getAppointmentDateTime(a);
              DateTime dateB = getAppointmentDateTime(b);
              return dateA.compareTo(dateB);
            });
          // --- logic lọc Lịch sử ---
          final pastAppointments = realtimeAppointments.where((item) {
            String status = safe(item, 'status');
            if (status.isEmpty) {
              status = 'upcoming';
            }
            if (status == 'archived') {
              return false;
            }
            return (status == 'completed' || status == 'cancelled' || status == 'expired');
          }).toList()
            ..sort((a, b) {
              DateTime dateA = getAppointmentDateTime(a);
              DateTime dateB = getAppointmentDateTime(b);
              return dateB.compareTo(dateA); // lịch sử mới nhất lên đầu
            });
          // Trả về giao diện Tab chuẩn của bạn kết hợp số lượng nhảy tự động
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  color: Colors.blue,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    tabs: [
                      Tab(text: 'Sắp tới (${upcomingAppointments.length})'),
                      Tab(text: 'Lịch sử (${pastAppointments.length})'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      buildAppointmentList(upcomingAppointments, false, isDarkMode, isLandscape),
                      buildAppointmentList(pastAppointments, true, isDarkMode, isLandscape),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}