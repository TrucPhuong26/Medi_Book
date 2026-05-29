// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../database/database_helper.dart';
// import 'login_screen.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// class BookingScreen extends StatefulWidget {
//   final String? doctor;
//   final String? specialty;
//   final String? hospital;
//   const BookingScreen({
//     super.key,
//     this.doctor,
//     this.specialty,
//     this.hospital,
//   });
//   @override
//   State<BookingScreen> createState() => _BookingScreenState();
// }
// class _BookingScreenState extends State<BookingScreen> {
//   final _formKey = GlobalKey<FormState>();
//   // ================= CHỌN =================
//   String? selectedArea;
//   String? selectedHospital;
//   String? selectedSpecialty;
//   String? selectedDoctor;
//   DateTime? selectedDate;
//   String? selectedTime;
//   List<String> fullTimeslots = [];
//   bool isLoadingSlots = false;
//   // ================= CONTROLLER =================
//   final fullNameController = TextEditingController();
//   final cccdController = TextEditingController();
//   final phoneController = TextEditingController();
//   final symptomController = TextEditingController();
//   final birthController = TextEditingController();
//   // ================= DATA =================
//   final List<String> areas = ['Cần Thơ', 'TP.HCM'];
//   final Map<String, List<String>> hospitalsByArea = {
//     'Cần Thơ': ['BV Đa khoa Trung Ương Cần Thơ', 'BV Hoàn Mỹ Cửu Long'],
//     'TP.HCM': ['BV Chợ Rẫy', 'BV Đại học Y Dược'],
//   };
//   final List<String> specialties = ['Tim mạch', 'Da liễu', 'Thần kinh', 'Nha khoa'];
//   final List<Map<String, dynamic>> doctors = [
//     // TIM MẠCH
//     {'name': 'BS. Nguyễn Văn An', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Tim mạch', 'area': 'TP.HCM', 'room': 'Phòng 1',},
//     {'name': 'BS. Lê Hoàng Minh', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Tim mạch', 'area': 'TP.HCM', 'room': 'Phòng 2',},
//     {'name': 'BS. Trần Thị Kim', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Tim mạch', 'area': 'TP.HCM','room': 'Phòng 3',},
//     {'name': 'BS. Phạm Đức Long', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Tim mạch', 'area': 'TP.HCM','room': 'Phòng 4',},
//     {'name': 'BS. Võ Thành Nhân', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Tim mạch', 'area': 'Cần Thơ','room': 'Phòng 5',},
//     {'name': 'BS. Nguyễn Gia Hân', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Tim mạch', 'area': 'Cần Thơ','room': 'Phòng 6',},
//     {'name': 'BS. Lê Văn Phước', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Tim mạch', 'area': 'Cần Thơ','room': 'Phòng 7',},
//     {'name': 'BS. Trần Gia Bảo', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Tim mạch', 'area': 'Cần Thơ','room': 'Phòng 8',},
//     // DA LIỄU
//     {'name': 'BS. Trần Hải Yến', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Da liễu', 'area': 'TP.HCM','room': 'Phòng 9',},
//     {'name': 'BS. Võ Minh Tân', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Da liễu', 'area': 'TP.HCM','room': 'Phòng 10',},
//     {'name': 'BS. Lê Thị Bình', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Da liễu', 'area': 'TP.HCM','room': 'Phòng 11',},
//     {'name': 'BS. Dương Ngọc Hà', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Da liễu', 'area': 'TP.HCM','room': 'Phòng 12',},
//     {'name': 'BS. Hồ Thanh Vy', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Da liễu', 'area': 'Cần Thơ','room': 'Phòng 13',},
//     {'name': 'BS. Lâm Quốc Huy', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Da liễu', 'area': 'Cần Thơ','room': 'Phòng 14',},
//     {'name': 'BS. Hoàng Gia Bảo', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Da liễu', 'area': 'Cần Thơ','room': 'Phòng 15',},
//     {'name': 'BS. Nguyễn Mỹ Linh', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Da liễu', 'area': 'Cần Thơ','room': 'Phòng 16',},
//     // THẦN KINH
//     {'name': 'BS. Michael Trương', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Thần kinh', 'area': 'TP.HCM','room': 'Phòng 17',},
//     {'name': 'BS. Lý Quốc Bảo', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Thần kinh', 'area': 'TP.HCM','room': 'Phòng 18',},
//     {'name': 'BS. Đặng Minh Tâm', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Thần kinh', 'area': 'TP.HCM','room': 'Phòng 19',},
//     {'name': 'BS. Huỳnh Quốc Việt', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Thần kinh', 'area': 'TP.HCM','room': 'Phòng 20',},
//     {'name': 'BS. Trịnh Hoài Nam', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Thần kinh', 'area': 'Cần Thơ','room': 'Phòng 21',},
//     {'name': 'BS. Bùi Khánh Linh', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Thần kinh', 'area': 'Cần Thơ','room': 'Phòng 22',},
//     {'name': 'BS. Võ Minh Quân', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Thần kinh', 'area': 'Cần Thơ','room': 'Phòng 23',},
//     {'name': 'BS. Lý Minh Triết', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Thần kinh', 'area': 'Cần Thơ','room': 'Phòng 24',},
//     // NHA KHOA
//     {'name': 'BS. Trần Anh Khoa', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Nha khoa', 'area': 'TP.HCM','room': 'Phòng 25',},
//     {'name': 'BS. Nguyễn Thành Đạt', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Nha khoa', 'area': 'TP.HCM','room': 'Phòng 26',},
//     {'name': 'BS. Emily Trịnh', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Nha khoa', 'area': 'TP.HCM','room': 'Phòng 27',},
//     {'name': 'BS. Đỗ Minh Phúc', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Nha khoa', 'area': 'TP.HCM','room': 'Phòng 28',},
//     {'name': 'BS. Vương Đình Khôi', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Nha khoa', 'area': 'Cần Thơ','room': 'Phòng 29',},
//     {'name': 'BS. Đoàn Thanh Tùng', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Nha khoa', 'area': 'Cần Thơ','room': 'Phòng 30',},
//     {'name': 'BS. Khưu Anh Tú', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Nha khoa', 'area': 'Cần Thơ','room': 'Phòng 31',},
//     {'name': 'BS. Phạm Nhật Nam', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Nha khoa', 'area': 'Cần Thơ','room': 'Phòng 32',},
//   ];
//   final List<String> availableTimes = [
//     '08:00 SA',
//     '09:00 SA',
//     '10:00 SA',
//     '01:00 CH',
//     '02:00 CH',
//     '03:00 CH',
//   ];
//   // ================= INIT =================
//   @override
//   void initState() {
//     super.initState();
//     selectedDoctor = widget.doctor;
//     selectedSpecialty = widget.specialty;
//     selectedHospital = widget.hospital;
//     if (selectedHospital != null) {
//       hospitalsByArea.forEach((area, hospitals) {
//         if (hospitals.contains(selectedHospital)) {
//           selectedArea = area;
//         }
//       });
//     }
//   }
//   // ================= DATE =================
//   Future<void> pickDate() async {
//     final pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//       locale: const Locale('vi', 'VN'),
//     );
//     if (pickedDate != null) {
//       setState(() {
//         selectedDate = pickedDate;
//         selectedTime = null;
//       });
//       await fetchFullTimeslots();
//     }
//   }
//   Future<void> pickBirthDate() async {
//     final pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime(2000),
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now(),
//       locale: const Locale('vi', 'VN'),
//     );
//     if (pickedDate != null) {
//       birthController.text = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
//     }
//   }
//   // ================= ĐỒNG BỘ TOÀN BỘ LOGIC (FIX LỖI CÀI LẠI APP) =================
//   Future<void> fetchFullTimeslots() async {
//     if (selectedDate == null ||
//         selectedDoctor == null ||
//         selectedHospital == null) {
//       return;
//     }
//     setState(() {
//       isLoadingSlots = true;
//     });
//
//     // SỬA TẠI ĐÂY: Dùng DateFormat cho đồng bộ tuyệt đối với nút đặt lịch
//     String dateString = DateFormat('yyyy-MM-dd').format(selectedDate!);
//
//     try {
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('appointments')
//           .where('hospital', isEqualTo: selectedHospital)
//           .where('doctor', isEqualTo: selectedDoctor)
//           .where('date', isEqualTo: dateString)
//           .get();
//       Map<String, int> timeCounts = {};
//       for (var doc in querySnapshot.docs) {
//         final data = doc.data();
//         String status = (data['status'] ?? 'upcoming').toString();
//         // ================= BỎ QUA LỊCH KHÔNG CÒN HIỆU LỰC =================
//         if (status != 'upcoming') {
//           continue;
//         }
//         String time = data['time'] ?? '';
//         if (time.isNotEmpty) {
//           timeCounts[time] = (timeCounts[time] ?? 0) + 1;
//         }
//       }
//       List<String> updatedFullSlots = [];
//       timeCounts.forEach((time, count) {
//         // if (count >= 5) {
//         if (count >= 2) {
//           updatedFullSlots.add(time);
//         }
//       });
//       setState(() {
//         fullTimeslots = updatedFullSlots;
//       });
//
//     } catch (e) {
//       print("Lỗi fetch slot: $e");
//     }
//     setState(() {
//       isLoadingSlots = false;
//     });
//   }
//   // ================= CHECK TIME =================
//   bool isTimePassed(DateTime date, String timeString) {
//     DateTime now = DateTime.now();
//     if (date.year == now.year && date.month == now.month && date.day == now.day) {
//       try {
//         List<String> parts = timeString.split(':');
//         int hour = int.parse(parts[0]);
//         int minute = int.parse(parts[1].split(' ')[0]);
//         bool isCH = timeString.contains('CH');
//         if (isCH && hour < 12) hour += 12;
//         if (!isCH && hour == 12) hour = 0;
//         DateTime selectedDateTime = DateTime(
//           date.year,
//           date.month,
//           date.day,
//           hour,
//           minute,
//         );
//         return selectedDateTime.isBefore(now);
//       } catch (e) {
//         return false;
//       }
//     }
//     return false;
//   }
//   // ================= SAVE & CALCULATE STT =================
//   Future<int> getNextSequenceNumber(
//       String hospital,
//       String doctor,
//       String date,
//       String time,
//       ) async {
//     final query = await FirebaseFirestore.instance
//         .collection('appointments')
//         .where('hospital', isEqualTo: hospital)
//         .where('doctor', isEqualTo: doctor)
//         .where('date', isEqualTo: date)
//         .where('time', isEqualTo: time)
//         .get();
//     int validCount = 0;
//     for (var doc in query.docs) {
//       final data = doc.data();
//       String status = (data['status'] ?? 'upcoming').toString();
//       // ================= CHỈ ĐẾM UPCOMING =================
//       if (status == 'upcoming') {
//         validCount++;
//       }
//     }
//     return validCount + 1;
//   }
//
//   Future<bool> checkDuplicateOnFirebase(String email, String date, String time) async {
//     // SỬA TẠI ĐÂY: Chuẩn hóa email bằng cách viết thường và xóa khoảng trắng thừa
//     String cleanEmail = email.trim().toLowerCase();
//
//     final query = await FirebaseFirestore.instance
//         .collection('appointments')
//         .where('userEmail', isEqualTo: cleanEmail)
//         .where('date', isEqualTo: date)
//         .where('time', isEqualTo: time)
//         .where('status', isEqualTo: 'upcoming')
//         .get();
//     return query.docs.isNotEmpty;
//   }
//
//   Future<bool> checkDuplicateOnSQLite(String email, String date, String time) async {
//     return await DatabaseHelper.instance.isAppointmentDuplicate(email.trim().toLowerCase(), date, time);
//   }
//
//   // ================= LẤY PHÒNG KHÁM =================
//   String getSelectedDoctorRoom() {
//     final doctorData = doctors.firstWhere(
//           (doc) => doc['name'] == selectedDoctor,
//       orElse: () => {},
//     );
//     return doctorData['room'] ?? 'Chưa có phòng';
//   }
//
//   Future<void> bookAppointment(int sttNum) async {
//     String dateString = DateFormat('yyyy-MM-dd').format(selectedDate!);
//     String cleanEmail = LoginScreen.loggedInEmail.trim().toLowerCase();
//     try {
//       // Lưu SQLite tại thiết bị địa phương
//       await DatabaseHelper.instance.addAppointment(
//         userEmail: cleanEmail,
//         doctor: selectedDoctor ?? '',
//         specialty: selectedSpecialty ?? '',
//         hospital: selectedHospital ?? '',
//         room: getSelectedDoctorRoom(),
//         date: dateString,
//         time: selectedTime ?? '',
//         symptoms: symptomController.text.trim(),
//         stt: sttNum,
//       );
//       // Lưu Firebase tập trung và đính kèm trường số thứ tự 'stt'
//       await FirebaseFirestore.instance.collection('appointments').add({
//         'userEmail': cleanEmail,
//         'hospital': selectedHospital ?? '',
//         'doctor': selectedDoctor ?? '',
//         'specialty': selectedSpecialty ?? '',
//         'room': getSelectedDoctorRoom(),
//         'date': dateString,
//         'time': selectedTime ?? '',
//         'fullName': fullNameController.text.trim(),
//         'cccd': cccdController.text.trim(),
//         'birthDate': birthController.text.trim(),
//         'phone': phoneController.text.trim(),
//         'symptom': symptomController.text.trim(),
//         'stt': sttNum,
//         'status': 'upcoming',
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       print("Lỗi lưu DB: $e");
//     }
//     if (!mounted) return;
//     // Hiển thị dialog báo thành công kèm theo Số Thứ Tự rõ ràng
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.check_circle, color: Colors.green, size: 85),
//             const SizedBox(height: 15),
//             const Text(
//               'Đặt lịch thành công!',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 15),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.blue.shade200),
//               ),
//               child: Column(
//                 children: [
//                   const Text('SỐ THỨ TỰ KHÁM CỦA BẠN', style: TextStyle(fontSize: 13, color: Colors.blueGrey)),
//                   const SizedBox(height: 5),
//                   Text(
//                     'STT: $sttNum',
//                     style: const TextStyle(fontSize: 32,fontWeight: FontWeight.w900, color: Colors.blue),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               'Vui lòng đến trước giờ khám 15 phút.',
//               style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
//               textAlign: TextAlign.center,
//             )
//           ],
//         ),
//       ),
//     );
//     await Future.delayed(const Duration(seconds: 4));
//     if (!mounted) return;
//     Navigator.pop(context); // Đóng AlertDialog thành công
//     Navigator.pop(context); // Quay về màn hình trước đó
//   }
//   // ================= TEXTFIELD =================
//   Widget buildTextField({
//     required String title,
//     required TextEditingController controller,
//     String? hint,
//     int maxLines = 1,
//     VoidCallback? onTap,
//     bool readOnly = false,
//     TextInputType? keyboardType,
//     List<TextInputFormatter>? inputFormatters,
//     String? Function(String?)? customValidator,
//   }) {
//     bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 17,
//             fontWeight: FontWeight.bold,
//             color: isDarkMode ? Colors.white : Colors.black,
//           ),
//         ),
//         const SizedBox(height: 10),
//         TextFormField(
//           controller: controller,
//           maxLines: maxLines,
//           readOnly: readOnly,
//           onTap: onTap,
//           keyboardType: keyboardType,
//           inputFormatters: inputFormatters,
//           style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
//           decoration: InputDecoration(
//             hintText: hint,
//             filled: true,
//             fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           validator: customValidator ?? (value) {
//             if (value == null || value.trim().isEmpty) {
//               return 'Không được để trống';
//             }
//             return null;
//           },
//         ),
//         const SizedBox(height: 22),
//       ],
//     );
//   }
//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final filteredDoctors = doctors.where((doctor) {
//       final hospitalMatch = selectedHospital == null || doctor['hospital'] == selectedHospital;
//       final specialtyMatch = selectedSpecialty == null || doctor['specialty'] == selectedSpecialty;
//       return hospitalMatch && specialtyMatch;
//     }).toList();
//     bool fromDoctorCard = widget.doctor != null && widget.specialty != null && widget.hospital != null;
//     return Scaffold(
//       backgroundColor: isDarkMode ? Colors.black : const Color(0xffF5F7FB),
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         title: const Text('Đặt lịch khám'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ================= CARD BÁC SĨ =================
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xff4A90E2), Color(0xff357AE8)],
//                   ),
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: Row(
//                   children: [
//                     const CircleAvatar(
//                       radius: 35,
//                       backgroundColor: Colors.white,
//                       child: Icon(Icons.person, size: 35, color: Colors.blue),
//                     ),
//                     const SizedBox(width: 18),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             selectedHospital ?? 'Chưa chọn bệnh viện',
//                             style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             selectedSpecialty ?? 'Chưa chọn chuyên khoa',
//                             style: const TextStyle(color: Colors.white70, fontSize: 16),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             selectedDoctor ?? 'Chưa chọn bác sĩ',
//                             style: const TextStyle(color: Colors.white, fontSize: 18),
//                           ),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 30),
//               if (!fromDoctorCard) ...[
//                 // ================= DROPDOWNS CHỌN =================
//                 const Text('Bệnh viện', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 12),
//                 DropdownButtonFormField<String>(
//                   value: selectedArea,
//                   decoration: InputDecoration(
//                     hintText: 'Chọn khu vực',
//                     filled: true,
//                     fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
//                   ),
//                   items: areas.map<DropdownMenuItem<String>>((area) {
//                     return DropdownMenuItem<String>(value: area, child: Text(area));
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedArea = value;
//                       selectedHospital = null;
//                       selectedDoctor = null;
//                       selectedTime = null;
//                       fullTimeslots.clear();
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 15),
//                 DropdownButtonFormField<String>(
//                   value: selectedHospital,
//                   decoration: InputDecoration(
//                     hintText: 'Chọn bệnh viện',
//                     filled: true,
//                     fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
//                   ),
//                   items: selectedArea == null
//                       ? []
//                       : hospitalsByArea[selectedArea]!.map<DropdownMenuItem<String>>((hospital) {
//                     return DropdownMenuItem<String>(value: hospital, child: Text(hospital));
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedHospital = value;
//                       selectedDoctor = null;
//                       selectedTime = null;
//                       fullTimeslots.clear();
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 25),
//                 const Text('Chuyên khoa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 12),
//                 DropdownButtonFormField<String>(
//                   value: selectedSpecialty,
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
//                   ),
//                   items: specialties.map<DropdownMenuItem<String>>((specialty) {
//                     return DropdownMenuItem<String>(value: specialty, child: Text(specialty));
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedSpecialty = value;
//                       selectedDoctor = null;
//                       selectedTime = null;
//                       fullTimeslots.clear();
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 25),
//                 const Text('Bác sĩ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 12),
//                 DropdownButtonFormField<String>(
//                   value: selectedDoctor,
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
//                   ),
//                   items: filteredDoctors.map<DropdownMenuItem<String>>((doctor) {
//                     return DropdownMenuItem<String>(
//                       value: doctor['name'].toString(),
//                       child: Text(doctor['name'].toString()),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedDoctor = value;
//                       selectedTime = null;
//                     });
//                     fetchFullTimeslots();
//                   },
//                 ),
//                 const SizedBox(height: 30),
//               ],
//               // ================= NGÀY GIỜ KHÁM =================
//               const Text('Ngày giờ khám', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 15),
//               GestureDetector(
//                 onTap: () {
//                   if (selectedDoctor == null || selectedHospital == null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Vui lòng chọn Bệnh viện và Bác sĩ trước')),
//                     );
//                     return;
//                   }
//                   pickDate();
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(18),
//                   decoration: BoxDecoration(
//                     color: isDarkMode ? Colors.grey[850] : Colors.white,
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.calendar_month, color: Colors.blue),
//                       const SizedBox(width: 12),
//                       Text(
//                         selectedDate == null
//                             ? 'Chọn ngày khám'
//                             : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
//                         style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               if (isLoadingSlots)
//                 const Center(child: Padding(padding: EdgeInsets.all(10.0), child: CircularProgressIndicator()))
//               else
//                 Wrap(
//                   spacing: 12,
//                   runSpacing: 12,
//                   children: availableTimes.map((time) {
//                     bool isPassed = isTimePassed(selectedDate ?? DateTime.now(), time);
//                     bool isFull = fullTimeslots.contains(time);
//                     bool isSelected = selectedTime == time;
//                     bool isDisabled = isPassed || isFull;
//                     return InkWell(
//                       onTap: isDisabled
//                           ? null
//                           : () {
//                         setState(() {
//                           selectedTime = time;
//                         });
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? Colors.blue
//                               : isDisabled
//                               ? (isDarkMode ? Colors.grey[900] : Colors.grey[300])
//                               : Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: isFull ? Border.all(color: Colors.red.shade300, width: 1) : null,
//                         ),
//                         child: Text(
//                           isFull ? '$time (Full)' : time,
//                           style: TextStyle(
//                             color: isSelected
//                                 ? Colors.white
//                                 : isDisabled
//                                 ? Colors.grey.shade500
//                                 : Colors.black,
//                             decoration: isPassed ? TextDecoration.lineThrough : null,
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               const SizedBox(height: 35),
//               // ================= THÔNG TIN BỆNH NHÂN =================
//               const Text('Thông tin bệnh nhân', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 25),
//               buildTextField(
//                 title: 'Họ tên',
//                 controller: fullNameController,
//                 hint: 'Nhập đầy đủ họ và tên',
//                 keyboardType: TextInputType.text,
//                 inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ỹ\s]'))],
//                 customValidator: (value) {
//                   if (value == null || value.trim().isEmpty) return 'Vui lòng nhập họ tên';
//                   if (value.trim().length < 2) return 'Họ tên quá ngắn';
//                   return null;
//                 },
//               ),
//               buildTextField(
//                 title: 'CCCD',
//                 controller: cccdController,
//                 hint: 'Nhập 12 số CCCD',
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
//                 customValidator: (value) {
//                   if (value == null || value.trim().isEmpty) return 'Vui lòng nhập CCCD';
//                   if (value.trim().length != 12) return 'CCCD phải chính xác 12 số';
//                   return null;
//                 },
//               ),
//               buildTextField(
//                 title: 'Ngày sinh',
//                 controller: birthController,
//                 readOnly: true,
//                 onTap: pickBirthDate,
//                 hint: 'dd/mm/yyyy',
//               ),
//               buildTextField(
//                 title: 'Số điện thoại',
//                 controller: phoneController,
//                 hint: 'Nhập số điện thoại (10 số)',
//                 keyboardType: TextInputType.phone,
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
//                 customValidator: (value) {
//                   if (value == null || value.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
//                   String pattern = r'^(0[3|5|7|8|9])([0-9]{8})$';
//                   if (!RegExp(pattern).hasMatch(value.trim())) {
//                     return 'Số điện thoại không đúng định dạng (10 số)';
//                   }
//                   return null;
//                 },
//               ),
//               buildTextField(
//                 title: 'Triệu chứng',
//                 controller: symptomController,
//                 hint: 'Đau đầu, sốt, ho...',
//                 maxLines: 4,
//                 customValidator: (value) {
//                   if (value == null || value.trim().isEmpty) return 'Vui lòng nhập tình trạng triệu chứng';
//                   if (value.trim().length < 5) return 'Vui lòng mô tả rõ hơn một chút';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               // ================= BUTTON ĐẶT LỊCH (ĐỒNG BỘ ĐỊNH DẠNG TUYỆT ĐỐI) =================
//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//                   ),
//                   onPressed: () async {
//                     if (selectedHospital == null ||
//                         selectedSpecialty == null ||
//                         selectedDoctor == null ||
//                         selectedDate == null ||
//                         selectedTime == null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Vui lòng chọn đầy đủ thông tin')),
//                       );
//                       return;
//                     }
//                     if (!_formKey.currentState!.validate()) return;
//                     // Định dạng ngày đồng bộ toàn bộ app bằng intl
//                     String dateString = DateFormat('yyyy-MM-dd').format(selectedDate!);
//                     String email = LoginScreen.loggedInEmail;
//                     // Hiện hiệu ứng chờ xử lý
//                     showDialog(
//                       context: context,
//                       barrierDismissible: false,
//                       builder: (context) => const Center(child: CircularProgressIndicator()),
//                     );
//                     try {
//                       // 1. KIỂM TRA TRÙNG LỊCH TRƯỚC
//                       bool isDupLocal = await checkDuplicateOnSQLite(email, dateString, selectedTime!);
//                       bool isDupRemote = await checkDuplicateOnFirebase(email, dateString, selectedTime!);
//
//                       if (isDupLocal || isDupRemote) {
//                         Navigator.pop(context); // Tắt loading
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Bạn đã có lịch hẹn sắp tới vào khung giờ này rồi!'),
//                             backgroundColor: Colors.orange,
//                           ),
//                         );
//                         return; // Dừng hàm luôn
//                       }
//                       // 2. NẾU KHÔNG TRÙNG ➔ Lấy Số Thứ Tự kế tiếp trên Firebase
//                       int nextSTT = await getNextSequenceNumber(selectedHospital!, selectedDoctor!, dateString, selectedTime!);
//                       // 3. Nếu STT vượt quá giới hạn slot
//                       // if (nextSTT > 5) {
//                       if (nextSTT > 2) {
//                         Navigator.pop(context); // Tắt loading
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                               content: Text('Khung giờ này vừa mới đầy, vui lòng chọn khung giờ khác!'),
//                               backgroundColor: Colors.red
//                           ),
//                         );
//                         fetchFullTimeslots(); // Reload lại các nút giờ
//                         return;
//                       }
//                       // 4. Tiến hành lưu lịch
//                       Navigator.pop(context); // Tắt loading
//                       await bookAppointment(nextSTT);
//                     } catch (e) {
//                       Navigator.pop(context); // Tắt loading
//                       print("Lỗi khi đặt lịch: $e");
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Có lỗi xảy ra trong quá trình xử lý lịch hẹn.')),
//                       );
//                     }
//                   },
//                   child: const Text(
//                     'ĐẶT LỊCH',
//                     style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'login_screen.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
class BookingScreen extends StatefulWidget {
  final String? doctor;
  final String? specialty;
  final String? hospital;
  const BookingScreen({
    super.key,
    this.doctor,
    this.specialty,
    this.hospital,
  });
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}
class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();

  // ================= CHỌN =================
  String? selectedArea;
  String? selectedHospital;
  String? selectedSpecialty;
  String? selectedDoctor;
  DateTime? selectedDate;
  String? selectedTime;
  List<String> fullTimeslots = [];
  bool isLoadingSlots = false;

  // ================= CONTROLLER =================
  final fullNameController = TextEditingController();
  final cccdController = TextEditingController();
  final phoneController = TextEditingController();
  final symptomController = TextEditingController();
  final birthController = TextEditingController();

  // ================= DATA =================
  final List<String> areas = ['Cần Thơ', 'TP.HCM'];
  final Map<String, List<String>> hospitalsByArea = {
    'Cần Thơ': ['BV Đa khoa Trung Ương Cần Thơ', 'BV Hoàn Mỹ Cửu Long'],
    'TP.HCM': ['BV Chợ Rẫy', 'BV Đại học Y Dược'],
  };
  final List<String> specialties = [
    'Tim mạch',
    'Da liễu',
    'Thần kinh',
    'Nha khoa'
  ];
  final List<Map<String, dynamic>> doctors = [
    // TIM MẠCH
    {
      'name': 'BS. Nguyễn Văn An',
      'hospital': 'BV Chợ Rẫy',
      'specialty': 'Tim mạch',
      'area': 'TP.HCM',
      'room': 'Phòng 1',
    },
    {
      'name': 'BS. Lê Hoàng Minh',
      'hospital': 'BV Chợ Rẫy',
      'specialty': 'Tim mạch',
      'area': 'TP.HCM',
      'room': 'Phòng 2',
    },
    {
      'name': 'BS. Trần Thị Kim',
      'hospital': 'BV Đại học Y Dược',
      'specialty': 'Tim mạch',
      'area': 'TP.HCM',
      'room': 'Phòng 3',
    },
    {
      'name': 'BS. Phạm Đức Long',
      'hospital': 'BV Đại học Y Dược',
      'specialty': 'Tim mạch',
      'area': 'TP.HCM',
      'room': 'Phòng 4',
    },
    {
      'name': 'BS. Võ Thành Nhân',
      'hospital': 'BV Hoàn Mỹ Cửu Long',
      'specialty': 'Tim mạch',
      'area': 'Cần Thơ',
      'room': 'Phòng 5',
    },
    {
      'name': 'BS. Nguyễn Gia Hân',
      'hospital': 'BV Hoàn Mỹ Cửu Long',
      'specialty': 'Tim mạch',
      'area': 'Cần Thơ',
      'room': 'Phòng 6',
    },
    {
      'name': 'BS. Lê Văn Phước',
      'hospital': 'BV Đa khoa Trung Ương Cần Thơ',
      'specialty': 'Tim mạch',
      'area': 'Cần Thơ',
      'room': 'Phòng 7',
    },
    {
      'name': 'BS. Trần Gia Bảo',
      'hospital': 'BV Đa khoa Trung Ương Cần Thơ',
      'specialty': 'Tim mạch',
      'area': 'Cần Thơ',
      'room': 'Phòng 8',
    },
    // DA LIỄU
    {
      'name': 'BS. Trần Hải Yến',
      'hospital': 'BV Chợ Rẫy',
      'specialty': 'Da liễu',
      'area': 'TP.HCM',
      'room': 'Phòng 9',
    },
    {
      'name': 'BS. Võ Minh Tân',
      'hospital': 'BV Chợ Rẫy',
      'specialty': 'Da liễu',
      'area': 'TP.HCM',
      'room': 'Phòng 10',
    },
    {
      'name': 'BS. Lê Thị Bình',
      'hospital': 'BV Đại học Y Dược',
      'specialty': 'Da liễu',
      'area': 'TP.HCM',
      'room': 'Phòng 11',
    },
    {
      'name': 'BS. Dương Ngọc Hà',
      'hospital': 'BV Đại học Y Dược',
      'specialty': 'Da liễu',
      'area': 'TP.HCM',
      'room': 'Phòng 12',
    },
    {
      'name': 'BS. Hồ Thanh Vy',
      'hospital': 'BV Hoàn Mỹ Cửu Long',
      'specialty': 'Da liễu',
      'area': 'Cần Thơ',
      'room': 'Phòng 13',
    },
    {
      'name': 'BS. Lâm Quốc Huy',
      'hospital': 'BV Hoàn Mỹ Cửu Long',
      'specialty': 'Da liễu',
      'area': 'Cần Thơ',
      'room': 'Phòng 14',
    },
    {
      'name': 'BS. Hoàng Gia Bảo',
      'hospital': 'BV Đa khoa Trung Ương Cần Thơ',
      'specialty': 'Da liễu',
      'area': 'Cần Thơ',
      'room': 'Phòng 15',
    },
    {
      'name': 'BS. Nguyễn Mỹ Linh',
      'hospital': 'BV Đa khoa Trung Ương Cần Thơ',
      'specialty': 'Da liễu',
      'area': 'Cần Thơ',
      'room': 'Phòng 16',
    },
    // THẦN KINH
    {
      'name': 'BS. Michael Trương',
      'hospital': 'BV Chợ Rẫy',
      'specialty': 'Thần kinh',
      'area': 'TP.HCM',
      'room': 'Phòng 17',
    },
    {
      'name': 'BS. Lý Quốc Bảo',
      'hospital': 'BV Chợ Rẫy',
      'specialty': 'Thần kinh',
      'area': 'TP.HCM',
      'room': 'Phòng 18',
    },
    {
      'name': 'BS. Đặng Minh Tâm',
      'hospital': 'BV Đại học Y Dược',
      'specialty': 'Thần kinh',
      'area': 'TP.HCM',
      'room': 'Phòng 19',
    },
    {
      'name': 'BS. Huỳnh Quốc Việt',
      'hospital': 'BV Đại học Y Dược',
      'specialty': 'Thần kinh',
      'area': 'TP.HCM',
      'room': 'Phòng 20',
    },
    {
      'name': 'BS. Trịnh Hoài Nam',
      'hospital': 'BV Hoàn Mỹ Cửu Long',
      'specialty': 'Thần kinh',
      'area': 'Cần Thơ',
      'room': 'Phòng 21',
    },
    {
      'name': 'BS. Bùi Khánh Linh',
      'hospital': 'BV Hoàn Mỹ Cửu Long',
      'specialty': 'Thần kinh',
      'area': 'Cần Thơ',
      'room': 'Phòng 22',
    },
    {
      'name': 'BS. Võ Minh Quân',
      'hospital': 'BV Đa khoa Trung Ương Cần Thơ',
      'specialty': 'Thần kinh',
      'area': 'Cần Thơ',
      'room': 'Phòng 23',
    },
    {
      'name': 'BS. Lý Minh Triết',
      'hospital': 'BV Đa khoa Trung Ương Cần Thơ',
      'specialty': 'Thần kinh',
      'area': 'Cần Thơ',
      'room': 'Phòng 24',
    },
    // NHA KHOA
    {
      'name': 'BS. Trần Anh Khoa',
      'hospital': 'BV Chợ Rẫy',
      'specialty': 'Nha khoa',
      'area': 'TP.HCM',
      'room': 'Phòng 25',
    },
    {
      'name': 'BS. Nguyễn Thành Đạt',
      'hospital': 'BV Chợ Rẫy',
      'specialty': 'Nha khoa',
      'area': 'TP.HCM',
      'room': 'Phòng 26',
    },
    {
      'name': 'BS. Emily Trịnh',
      'hospital': 'BV Đại học Y Dược',
      'specialty': 'Nha khoa',
      'area': 'TP.HCM',
      'room': 'Phòng 27',
    },
    {
      'name': 'BS. Đỗ Minh Phúc',
      'hospital': 'BV Đại học Y Dược',
      'specialty': 'Nha khoa',
      'area': 'TP.HCM',
      'room': 'Phòng 28',
    },
    {
      'name': 'BS. Vương Đình Khôi',
      'hospital': 'BV Hoàn Mỹ Cửu Long',
      'specialty': 'Nha khoa',
      'area': 'Cần Thơ',
      'room': 'Phòng 29',
    },
    {
      'name': 'BS. Đoàn Thanh Tùng',
      'hospital': 'BV Hoàn Mỹ Cửu Long',
      'specialty': 'Nha khoa',
      'area': 'Cần Thơ',
      'room': 'Phòng 30',
    },
    {
      'name': 'BS. Khưu Anh Tú',
      'hospital': 'BV Đa khoa Trung Ương Cần Thơ',
      'specialty': 'Nha khoa',
      'area': 'Cần Thơ',
      'room': 'Phòng 31',
    },
    {
      'name': 'BS. Phạm Nhật Nam',
      'hospital': 'BV Đa khoa Trung Ương Cần Thơ',
      'specialty': 'Nha khoa',
      'area': 'Cần Thơ',
      'room': 'Phòng 32',
    },
  ];
  final List<String> availableTimes = [
    '08:00 SA',
    '09:00 SA',
    '10:00 SA',
    '01:00 CH',
    '02:00 CH',
    '03:00 CH',
  ];

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    selectedDoctor = widget.doctor;
    selectedSpecialty = widget.specialty;
    selectedHospital = widget.hospital;
    if (selectedHospital != null) {
      hospitalsByArea.forEach((area, hospitals) {
        if (hospitals.contains(selectedHospital)) {
          selectedArea = area;
        }
      });
    }
  }

  // ================= DATE =================
  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      locale: const Locale('vi', 'VN'),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        selectedTime = null;
      });
      await fetchFullTimeslots();
    }
  }

  Future<void> pickBirthDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
    );
    if (pickedDate != null) {
      birthController.text =
      '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
    }
  }

  // ================= ĐỒNG BỘ TOÀN BỘ LOGIC (FIX LỖI CÀI LẠI APP) =================
//   Future<void> fetchFullTimeslots() async {
//     if (selectedDate == null ||
//         selectedDoctor == null ||
//         selectedHospital == null) {
//       return;
//     }
//     setState(() {
//       isLoadingSlots = true;
//     });
//
//     String dateString = DateFormat('yyyy-MM-dd').format(selectedDate!);
//
//     try {
// // SỬA TẠI ĐÂY: Thêm GetOptions(source: Source.serverAndCache)
// // Để nếu không có mạng, nó vẫn lấy dữ liệu đã cache trước đó ra hiển thị, không bị crash.
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('appointments')
//           .where('hospital', isEqualTo: selectedHospital)
//           .where('doctor', isEqualTo: selectedDoctor)
//           .where('date', isEqualTo: dateString)
//           .get(const GetOptions(source: Source.serverAndCache));
//
//       Map<String, int> timeCounts = {};
//       for (var doc in querySnapshot.docs) {
//         final data = doc.data();
//         String status = (data['status'] ?? 'upcoming').toString();
//         if (status != 'upcoming') {
//           continue;
//         }
//         String time = data['time'] ?? '';
//         if (time.isNotEmpty) {
//           timeCounts[time] = (timeCounts[time] ?? 0) + 1;
//         }
//       }
//       List<String> updatedFullSlots = [];
//       timeCounts.forEach((time, count) {
//         if (count >= 2) { // Giữ nguyên max slot = 2
//           updatedFullSlots.add(time);
//         }
//       });
//       setState(() {
//         fullTimeslots = updatedFullSlots;
//       });
//     } catch (e) {
//       print("Lỗi fetch slot: $e");
//     }
//     setState(() {
//       isLoadingSlots = false;
//     });
//   }


//   Future<void> fetchFullTimeslots() async {
//     if (selectedDate == null ||
//         selectedDoctor == null ||
//         selectedHospital == null) {
//       return;
//     }
//     setState(() {
//       isLoadingSlots = true;
//     });
//
//     String dateString = DateFormat('yyyy-MM-dd').format(selectedDate!);
//
//     try {
//       // Ép thời gian chờ tối đa 1.5 giây. Nếu không có mạng, ép lấy trực tiếp từ CACHE để không treo UI.
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('appointments')
//           .where('hospital', isEqualTo: selectedHospital)
//           .where('doctor', isEqualTo: selectedDoctor)
//           .where('date', isEqualTo: dateString)
//           .get(const GetOptions(source: Source.serverAndCache))
//           .timeout(const Duration(milliseconds: 1500), onTimeout: () {
//         // Nếu hết thời gian chờ (mất mạng), ép buộc lấy từ Cache địa phương
//         return FirebaseFirestore.instance
//             .collection('appointments')
//             .where('hospital', isEqualTo: selectedHospital)
//             .where('doctor', isEqualTo: selectedDoctor)
//             .where('date', isEqualTo: dateString)
//             .get(const GetOptions(source: Source.cache));
//       });
//
//       Map<String, int> timeCounts = {};
//       for (var doc in querySnapshot.docs) {
//         final data = doc.data();
//         String status = (data['status'] ?? 'upcoming').toString();
//         if (status != 'upcoming') {
//           continue;
//         }
//         String time = data['time'] ?? '';
//         if (time.isNotEmpty) {
//           timeCounts[time] = (timeCounts[time] ?? 0) + 1;
//         }
//       }
//       List<String> updatedFullSlots = [];
//       timeCounts.forEach((time, count) {
//         if (count >= 2) {
//           updatedFullSlots.add(time);
//         }
//       });
//       setState(() {
//         fullTimeslots = updatedFullSlots;
//       });
//     } catch (e) {
//       print("Lỗi fetch slot: $e");
//     }
//     setState(() {
//       isLoadingSlots = false;
//     });
//   }

// ================= CHECK TIME =================
  bool isTimePassed(DateTime date, String timeString) {
    DateTime now = DateTime.now();
    if (date.year == now.year && date.month == now.month &&
        date.day == now.day) {
      try {
        List<String> parts = timeString.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1].split(' ')[0]);
        bool isCH = timeString.contains('CH');
        if (isCH && hour < 12) hour += 12;
        if (!isCH && hour == 12) hour = 0;
        DateTime selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );
        return selectedDateTime.isBefore(now);
      } catch (e) {
        return false;
      }
    }
    return false;
  }
// Thay thế hàm fetchFullTimeslots cũ của bạn bằng hàm này:
//   Future<void> fetchFullTimeslots() async {
//     if (selectedHospital == null || selectedSpecialty == null || selectedDate == null) {
//       return;
//     }
//
//     setState(() {
//       isLoadingSlots = true;
//     });
//
//     String dateString = DateFormat('yyyy-MM-dd').format(selectedDate!);
//
//     try {
//       // 🔥 ÉP BUỘC: Chỉ đọc danh sách từ SERVER với timeout 2 giây, không đọc Cache máy lúc này
//       final snapshot = await FirebaseFirestore.instance
//           .collection('appointments')
//           .where('hospital', isEqualTo: selectedHospital)
//           .where('specialty', isEqualTo: selectedSpecialty)
//           .where('date', isEqualTo: dateString)
//           .where('status', isEqualTo: 'upcoming') // Chỉ đếm những người THỰC SỰ đang active
//           .get(const GetOptions(source: Source.server)) // 💥 KHÔNG cho đọc từ Cache lúc này
//           .timeout(const Duration(seconds: 2));
//
//       Map<String, int> slotCounts = {};
//       for (var doc in snapshot.docs) {
//         String time = doc.data()['time'] ?? '';
//         if (time.isNotEmpty) {
//           slotCounts[time] = (slotCounts[time] ?? 0) + 1;
//         }
//       }
//
//       List<String> tempFullSlots = [];
//       slotCounts.forEach((time, count) {
//         if (count >= 2) {
//           tempFullSlots.add(time);
//         }
//       });
//
//       if (!mounted) return;
//       setState(() {
//         fullTimeslots = tempFullSlots;
//         isLoadingSlots = false;
//       });
//
//     } catch (e) {
//       print("Mất mạng hoặc timeout khi check danh sách giờ Full: $e");
//
//       if (!mounted) return;
//       setState(() {
//         isLoadingSlots = false;
//         // 💥 KHI OFFLINE: Giữ nguyên danh sách fullTimeslots cũ hoặc không tự ý xóa trống nó,
//         // Chặn đứng việc Firebase Cache tự động mở khóa giờ lung tung khi chưa lên mạng.
//       });
//     }
//   }

  Future<void> fetchFullTimeslots() async {
    if (selectedHospital == null || selectedSpecialty == null || selectedDate == null) {
      return;
    }

    setState(() {
      isLoadingSlots = true;
    });

    String dateString = DateFormat('yyyy-MM-dd').format(selectedDate!);
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      // 1. CỐ GẮNG ĐỌC TỪ SERVER TRƯỚC (Dành cho lúc có mạng)
      snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('hospital', isEqualTo: selectedHospital)
          .where('specialty', isEqualTo: selectedSpecialty)
          .where('date', isEqualTo: dateString)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 2));

    } catch (e) {
      print("Mất mạng hoặc timeout, tiến hành đọc từ CACHE máy Ly để xử lý lịch offline: $e");

      // 2. KHI OFFLINE (Bị timeout hoặc lỗi mạng): Ép buộc đọc từ Cache cục bộ của máy Ly
      try {
        snapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .where('hospital', isEqualTo: selectedHospital)
            .where('specialty', isEqualTo: selectedSpecialty)
            .where('date', isEqualTo: dateString)
            .get(const GetOptions(source: Source.cache));
      } catch (cacheError) {
        // Nếu ngay cả cache cũng lỗi thì giữ nguyên trạng thái cũ
        if (mounted) {
          setState(() { isLoadingSlots = false; });
        }
        return;
      }
    }

    // 3. XỬ LÝ ĐẾM SLOT (Áp dụng cho cả dữ liệu Server hoặc dữ liệu Cache offline)
    Map<String, int> slotCounts = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String status = data['status'] ?? 'upcoming';
      String time = data['time'] ?? '';

      // Kiểm tra xem document này có phải do chính máy Ly vừa bấm Hủy offline hay không
      bool isPending = doc.metadata.hasPendingWrites;

      if (time.isNotEmpty) {
        // BẢO VỆ SLOT KHI OFFLINE:
        // - Nếu lịch là 'upcoming' -> Chắc chắn tính slot.
        // - Nếu Ly vừa hủy offline ('cancelled') nhưng chưa lên Firebase (isPending == true) -> VẪN TÍNH ĐANG CHIẾM SLOT -> Giờ đó vẫn bị KHÓA.
        if (status == 'upcoming' || (status == 'cancelled' && isPending)) {
          slotCounts[time] = (slotCounts[time] ?? 0) + 1;
        }
      }
    }

    List<String> tempFullSlots = [];
    slotCounts.forEach((time, count) {
      if (count >= 2) {
        tempFullSlots.add(time); // Thêm vào danh sách khóa nếu >= 2 slot
      }
    });

    if (!mounted) return;
    setState(() {
      fullTimeslots = tempFullSlots; // Cập nhật lại UI, giờ đó sẽ tiếp tục bị khóa đỏ/ẩn đi
      isLoadingSlots = false;
    });
  }
// SỬA TẠI ĐÂY: Hàm tính STT thông minh, ưu tiên lấy từ Cache/Local trước để không bị nghẽn mạng
//   Future<int> getNextSequenceNumber(String hospital,
//       String doctor,
//       String date,
//       String time,) async {
//     try {
// // Lấy dữ liệu kết hợp từ Server và Cache local (nếu mất mạng sẽ lấy ngay từ cache)
//       final query = await FirebaseFirestore.instance
//           .collection('appointments')
//           .where('hospital', isEqualTo: hospital)
//           .where('doctor', isEqualTo: doctor)
//           .where('date', isEqualTo: date)
//           .where('time', isEqualTo: time)
//           .get(const GetOptions(source: Source.serverAndCache));
//
//       int validCount = 0;
//       for (var doc in query.docs) {
//         final data = doc.data();
//         String status = (data['status'] ?? 'upcoming').toString();
//         if (status == 'upcoming') {
//           validCount++;
//         }
//       }
//       return validCount + 1;
//     } catch (e) {
// // Nếu lỗi hoặc không có gì, trả về 1 làm STT đầu tiên
//       return 1;
//     }
//   }
  Future<int> getNextSequenceNumber(String hospital, String doctor, String date, String time) async {
    try {
      // Đặt timeout 1 giây. Nếu mất mạng, hệ thống nhảy ngay sang đọc Cache để tính STT, tránh quay vòng vô tận.
      final query = await FirebaseFirestore.instance
          .collection('appointments')
          .where('hospital', isEqualTo: hospital)
          .where('doctor', isEqualTo: doctor)
          .where('date', isEqualTo: date)
          .where('time', isEqualTo: time)
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 1), onTimeout: () {
        return FirebaseFirestore.instance
            .collection('appointments')
            .where('hospital', isEqualTo: hospital)
            .where('doctor', isEqualTo: doctor)
            .where('date', isEqualTo: date)
            .where('time', isEqualTo: time)
            .get(const GetOptions(source: Source.cache));
      });

      int validCount = 0;
      for (var doc in query.docs) {
        final data = doc.data();
        String status = (data['status'] ?? 'upcoming').toString();
        if (status == 'upcoming') {
          validCount++;
        }
      }
      return validCount + 1;
    } catch (e) {
      print("Lỗi lấy STT từ mạng, tự động gán STT 1 cục bộ: $e");
      return 1;
    }
  }
// SỬA TẠI ĐÂY: Check trùng trên Firebase từ Cache để không bị treo khi offline
//   Future<bool> checkDuplicateOnFirebase(String email, String date,
//       String time) async {
//     try {
//       String cleanEmail = email.trim().toLowerCase();
//       final query = await FirebaseFirestore.instance
//           .collection('appointments')
//           .where('userEmail', isEqualTo: cleanEmail)
//           .where('date', isEqualTo: date)
//           .where('time', isEqualTo: time)
//           .where('status', isEqualTo: 'upcoming')
//           .get(const GetOptions(
//           source: Source.serverAndCache)); // Không await mạng vô tận
//       return query.docs.isNotEmpty;
//     } catch (e) {
//       return false; // Nếu offline hoàn toàn và cache chưa có, tạm thời cho qua để check SQLite gánh
//     }
//   }
  Future<bool> checkDuplicateOnFirebase(String email, String date, String time) async {
    try {
      String cleanEmail = email.trim().toLowerCase();
      // Thêm giới hạn chờ 1 giây để bảo vệ tiến trình không bị nghẽn mạng
      final query = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userEmail', isEqualTo: cleanEmail)
          .where('date', isEqualTo: date)
          .where('time', isEqualTo: time)
          .where('status', isEqualTo: 'upcoming')
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 1), onTimeout: () {
        return FirebaseFirestore.instance
            .collection('appointments')
            .where('userEmail', isEqualTo: cleanEmail)
            .where('date', isEqualTo: date)
            .where('time', isEqualTo: time)
            .where('status', isEqualTo: 'upcoming')
            .get(const GetOptions(source: Source.cache));
      });
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  Future<bool> checkDuplicateOnSQLite(String email, String date,
      String time) async {
    return await DatabaseHelper.instance.isAppointmentDuplicate(
        email.trim().toLowerCase(), date, time);
  }

// ================= LẤY PHÒNG KHÁM =================
  String getSelectedDoctorRoom() {
    final doctorData = doctors.firstWhere(
          (doc) => doc['name'] == selectedDoctor,
      orElse: () => {},
    );
    return doctorData['room'] ?? 'Chưa có phòng';
  }

// SỬA TẠI ĐÂY: KHÔNG dùng `await` khi add vào Firebase.
// // Việc bỏ `await` giúp Firebase đẩy lệnh này vào hàng đợi ngầm (Queue) và chạy tiếp code UI lập tức.
//   Future<void> bookAppointment(int sttNum) async {
//     String dateString = DateFormat('yyyy-MM-dd').format(selectedDate!);
//     String cleanEmail = LoginScreen.loggedInEmail.trim().toLowerCase();
//
//     try {
// // 1. Lưu SQLite tại thiết bị địa phương trước (Luôn thành công dù offline)
//       await DatabaseHelper.instance.addAppointment(
//         userEmail: cleanEmail,
//         doctor: selectedDoctor ?? '',
//         specialty: selectedSpecialty ?? '',
//         hospital: selectedHospital ?? '',
//         room: getSelectedDoctorRoom(),
//         date: dateString,
//         time: selectedTime ?? '',
//         symptoms: symptomController.text.trim(),
//         stt: sttNum,
//       );
//
// // 2. Lưu Firebase tập trung: BỎ `await` ở dòng này để chạy bất đồng bộ ngầm
//       FirebaseFirestore.instance.collection('appointments').add({
//         'userEmail': cleanEmail,
//         'hospital': selectedHospital ?? '',
//         'doctor': selectedDoctor ?? '',
//         'specialty': selectedSpecialty ?? '',
//         'room': getSelectedDoctorRoom(),
//         'date': dateString,
//         'time': selectedTime ?? '',
//         'fullName': fullNameController.text.trim(),
//         'cccd': cccdController.text.trim(),
//         'birthDate': birthController.text.trim(),
//         'phone': phoneController.text.trim(),
//         'symptom': symptomController.text.trim(),
//         'stt': sttNum,
//         'status': 'upcoming',
//         'createdAt': FieldValue.serverTimestamp(),
//         // Sẽ tự đồng bộ thời gian khi lên mạng
//       }).then((value) {
//         print("Đã đồng bộ lên Firebase thành công!");
//       }).catchError((error) {
//         print("Lỗi lưu Firebase ngầm (sẽ tự thử lại): $error");
//       });
//     } catch (e) {
//       print("Lỗi lưu DB local: $e");
//     }
//
//     if (!mounted) return;
//
// // Hiển thị dialog báo thành công kèm theo Số Thứ Tự rõ ràng (Hiển thị ngay lập tức)
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) =>
//           AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20)),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.check_circle, color: Colors.green, size: 85),
//                 const SizedBox(height: 15),
//                 const Text(
//                   'Đặt lịch thành công!',
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 15),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 20, vertical: 10),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.blue.shade200),
//                   ),
//                   child: Column(
//                     children: [
//                       const Text('SỐ THỨ TỰ KHÁM CỦA BẠN', style: TextStyle(
//                           fontSize: 13, color: Colors.blueGrey)),
//                       const SizedBox(height: 5),
//                       Text(
//                         'STT: $sttNum',
//                         style: const TextStyle(fontSize: 32,
//                             fontWeight: FontWeight.w900,
//                             color: Colors.blue),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   'Vui lòng đến trước giờ khám 15 phút.',
//                   style: TextStyle(fontSize: 13,
//                       color: Colors.grey,
//                       fontStyle: FontStyle.italic),
//                   textAlign: TextAlign.center,
//                 )
//               ],
//             ),
//           ),
//     );
//     await Future.delayed(const Duration(seconds: 4));
//     if (!mounted) return;
//     Navigator.pop(context); // Đóng AlertDialog thành công
//     Navigator.pop(context); // Quay về màn hình trước đó
//   }
  // SỬA LẠI HÀM: Chặn đứng khi Offline, bắt buộc có mạng mới cho Đặt lịch mới
  Future<void> bookAppointment(int sttNum) async {
    // -------------------------------------------------------------------------
    // BƯỚC KIỂM TRA MẠNG (CHECK OFFLINE) KHẨN CẤP
    // -------------------------------------------------------------------------
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 2));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw const SocketException("NO_INTERNET");
      }
    } catch (_) {
      // Nếu không có mạng (hoặc kết nối quá 2 giây bị timeout), dừng hàm và báo lỗi ngay lập tức
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
                  'Không có kết nối Internet! Vui lòng kết nối Wifi/4G để tiến hành đặt lịch khám mới.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
      return; // Chặn đứng tại đây, không cho chạy xuống code lưu dữ liệu phía dưới nữa
    }

    // -------------------------------------------------------------------------
    // CODE LƯU DỮ LIỆU CŨ (CHỈ CHẠY KHI ĐÃ XÁC NHẬN CÓ MẠNG)
    // -------------------------------------------------------------------------
    String dateString = DateFormat('yyyy-MM-dd').format(selectedDate!);
    String cleanEmail = LoginScreen.loggedInEmail.trim().toLowerCase();

    try {
      // 1. Lưu SQLite tại thiết bị địa phương trước
      await DatabaseHelper.instance.addAppointment(
        userEmail: cleanEmail,
        doctor: selectedDoctor ?? '',
        specialty: selectedSpecialty ?? '',
        hospital: selectedHospital ?? '',
        room: getSelectedDoctorRoom(),
        date: dateString,
        time: selectedTime ?? '',
        symptoms: symptomController.text.trim(),
        stt: sttNum,
      );

      // 2. Lưu Firebase tập trung
      FirebaseFirestore.instance.collection('appointments').add({
        'userEmail': cleanEmail,
        'hospital': selectedHospital ?? '',
        'doctor': selectedDoctor ?? '',
        'specialty': selectedSpecialty ?? '',
        'room': getSelectedDoctorRoom(),
        'date': dateString,
        'time': selectedTime ?? '',
        'fullName': fullNameController.text.trim(),
        'cccd': cccdController.text.trim(),
        'birthDate': birthController.text.trim(),
        'phone': phoneController.text.trim(),
        'symptom': symptomController.text.trim(),
        'stt': sttNum,
        'status': 'upcoming',
        'createdAt': FieldValue.serverTimestamp(),
      }).then((value) {
        print("Đã đồng bộ lên Firebase thành công!");
      }).catchError((error) {
        print("Lỗi lưu Firebase: $error");
      });
    } catch (e) {
      print("Lỗi lưu DB local: $e");
    }

    if (!mounted) return;

    // Hiển thị dialog báo thành công kèm theo Số Thứ Tự rõ ràng
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 85),
            const SizedBox(height: 15),
            const Text(
              'Đặt lịch thành công!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  const Text('SỐ THỨ TỰ KHÁM CỦA BẠN', style: TextStyle(fontSize: 13, color: Colors.blueGrey)),
                  const SizedBox(height: 5),
                  Text(
                    'STT: $sttNum',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Vui lòng đến trước giờ khám 15 phút.',
              style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    Navigator.pop(context); // Đóng AlertDialog thành công
    Navigator.pop(context); // Quay về màn hình trước đó
  }

// ================= TEXTFIELD =================
  Widget buildTextField({
    required String title,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    VoidCallback? onTap,
    bool readOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? customValidator,
  }) {
    bool isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          validator: customValidator ?? (value) {
            if (value == null || value
                .trim()
                .isEmpty) {
              return 'Không được để trống';
            }
            return null;
          },
        ),
        const SizedBox(height: 22),
      ],
    );
  }

// ================= UI =================
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    final filteredDoctors = doctors.where((doctor) {
      final hospitalMatch = selectedHospital == null ||
          doctor['hospital'] == selectedHospital;
      final specialtyMatch = selectedSpecialty == null ||
          doctor['specialty'] == selectedSpecialty;
      return hospitalMatch && specialtyMatch;
    }).toList();
    bool fromDoctorCard = widget.doctor != null && widget.specialty != null &&
        widget.hospital != null;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xffF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Đặt lịch khám'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
// ================= CARD BÁC SĨ =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff4A90E2), Color(0xff357AE8)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 35, color: Colors.blue),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedHospital ?? 'Chưa chọn bệnh viện',
                            style: const TextStyle(color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            selectedSpecialty ?? 'Chưa chọn chuyên khoa',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedDoctor ?? 'Chưa chọn bác sĩ',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              if (!fromDoctorCard) ...[
// ================= DROPDOWNS CHỌN =================
                const Text('Bệnh viện', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedArea,
                  decoration: InputDecoration(
                    hintText: 'Chọn khu vực',
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none),
                  ),
                  items: areas.map<DropdownMenuItem<String>>((area) {
                    return DropdownMenuItem<String>(value: area, child: Text(
                        area));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedArea = value;
                      selectedHospital = null;
                      selectedDoctor = null;
                      selectedTime = null;
                      fullTimeslots.clear();
                    });
                  },
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedHospital,
                  decoration: InputDecoration(
                    hintText: 'Chọn bệnh viện',
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none),
                  ),
                  items: selectedArea == null
                      ? []
                      : hospitalsByArea[selectedArea]!.map<
                      DropdownMenuItem<String>>((hospital) {
                    return DropdownMenuItem<String>(
                        value: hospital, child: Text(hospital));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedHospital = value;
                      selectedDoctor = null;
                      selectedTime = null;
                      fullTimeslots.clear();
                    });
                  },
                ),
                const SizedBox(height: 25),
                const Text('Chuyên khoa', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedSpecialty,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none),
                  ),
                  items: specialties.map<DropdownMenuItem<String>>((specialty) {
                    return DropdownMenuItem<String>(
                        value: specialty, child: Text(specialty));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSpecialty = value;
                      selectedDoctor = null;
                      selectedTime = null;
                      fullTimeslots.clear();
                    });
                  },
                ),
                const SizedBox(height: 25),
                const Text('Bác sĩ', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedDoctor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none),
                  ),
                  items: filteredDoctors.map<DropdownMenuItem<String>>((
                      doctor) {
                    return DropdownMenuItem<String>(
                      value: doctor['name'].toString(),
                      child: Text(doctor['name'].toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDoctor = value;
                      selectedTime = null;
                    });
                    fetchFullTimeslots();
                  },
                ),
                const SizedBox(height: 30),
              ],
// ================= NGÀY GIỜ KHÁM =================
              const Text('Ngày giờ khám',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  if (selectedDoctor == null || selectedHospital == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(
                          'Vui lòng chọn Bệnh viện và Bác sĩ trước')),
                    );
                    return;
                  }
                  pickDate();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        selectedDate == null
                            ? 'Chọn ngày khám'
                            : '${selectedDate!.day}/${selectedDate!
                            .month}/${selectedDate!.year}',
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isLoadingSlots)
                const Center(child: Padding(padding: EdgeInsets.all(10.0),
                    child: CircularProgressIndicator()))
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: availableTimes.map((time) {
                    bool isPassed = isTimePassed(
                        selectedDate ?? DateTime.now(), time);
                    bool isFull = fullTimeslots.contains(time);
                    bool isSelected = selectedTime == time;
                    bool isDisabled = isPassed || isFull;
                    return InkWell(
                      onTap: isDisabled
                          ? null
                          : () {
                        setState(() {
                          selectedTime = time;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue
                              : isDisabled
                              ? (isDarkMode ? Colors.grey[900] : Colors
                              .grey[300])
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isFull ? Border.all(
                              color: Colors.red.shade300, width: 1) : null,
                        ),
                        child: Text(
                          isFull ? '$time (Full)' : time,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isDisabled
                                ? Colors.grey.shade500
                                : Colors.black,
                            decoration: isPassed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 35),
// ================= THÔNG TIN BỆNH NHÂN =================
              const Text('Thông tin bệnh nhân',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              buildTextField(
                title: 'Họ tên',
                controller: fullNameController,
                hint: 'Nhập đầy đủ họ và tên',
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ỹ\s]'))
                ],
                customValidator: (value) {
                  if (value == null || value
                      .trim()
                      .isEmpty) return 'Vui lòng nhập họ tên';
                  if (value
                      .trim()
                      .length < 2) return 'Họ tên quá ngắn';
                  return null;
                },
              ),
              buildTextField(
                title: 'CCCD',
                controller: cccdController,
                hint: 'Nhập 12 số CCCD',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12)
                ],
                customValidator: (value) {
                  if (value == null || value
                      .trim()
                      .isEmpty) return 'Vui lòng nhập CCCD';
                  if (value
                      .trim()
                      .length != 12) return 'CCCD phải chính xác 12 số';
                  return null;
                },
              ),
              buildTextField(
                title: 'Ngày sinh',
                controller: birthController,
                readOnly: true,
                onTap: pickBirthDate,
                hint: 'dd/mm/yyyy',
              ),
              buildTextField(
                title: 'Số điện thoại',
                controller: phoneController,
                hint: 'Nhập số điện thoại (10 số)',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ],
                customValidator: (value) {
                  if (value == null || value
                      .trim()
                      .isEmpty) return 'Vui lòng nhập số điện thoại';
                  String pattern = r'^(0[3|5|7|8|9])([0-9]{8})$';
                  if (!RegExp(pattern).hasMatch(value.trim())) {
                    return 'Số điện thoại không đúng định dạng (10 số)';
                  }
                  return null;
                },
              ),
              buildTextField(
                title: 'Triệu chứng',
                controller: symptomController,
                hint: 'Đau đầu, sốt, ho...',
                maxLines: 4,
                customValidator: (value) {
                  if (value == null || value
                      .trim()
                      .isEmpty) return 'Vui lòng nhập tình trạng triệu chứng';
                  if (value
                      .trim()
                      .length < 5) return 'Vui lòng mô tả rõ hơn một chút';
                  return null;
                },
              ),
              const SizedBox(height: 20),
// ================= BUTTON ĐẶT LỊCH (ĐÃ TỐI ƯU HOÀN TOÀN OFFLINE) =================
//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(18)),
//                   ),
//                   onPressed: () async {
//                     if (selectedHospital == null ||
//                         selectedSpecialty == null ||
//                         selectedDoctor == null ||
//                         selectedDate == null ||
//                         selectedTime == null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text(
//                             'Vui lòng chọn đầy đủ thông tin')),
//                       );
//                       return;
//                     }
//                     if (!_formKey.currentState!.validate()) return;
//
//                     String dateString = DateFormat('yyyy-MM-dd').format(
//                         selectedDate!);
//                     String email = LoginScreen.loggedInEmail;
//
// // Hiện hiệu ứng chờ xử lý
//                     showDialog(
//                       context: context,
//                       barrierDismissible: false,
//                       builder: (context) =>
//                       const Center(child: CircularProgressIndicator()),
//                     );
//
//                     try {
// // 1. KIỂM TRA TRÙNG LỊCH (Local SQLite & Firebase Cache kết hợp nhanh)
//                       bool isDupLocal = await checkDuplicateOnSQLite(
//                           email, dateString, selectedTime!);
//                       bool isDupRemote = await checkDuplicateOnFirebase(
//                           email, dateString, selectedTime!);
//
//                       if (isDupLocal || isDupRemote) {
//                         Navigator.pop(context); // Tắt loading
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                                 'Bạn đã có lịch hẹn sắp tới vào khung giờ này rồi!'),
//                             backgroundColor: Colors.orange,
//                           ),
//                         );
//                         return;
//                       }
//
// // 2. NẾU KHÔNG TRÙNG ➔ Lấy STT kế tiếp (Kết hợp Cache mượt mà khi mất mạng)
//                       int nextSTT = await getNextSequenceNumber(
//                           selectedHospital!, selectedDoctor!, dateString,
//                           selectedTime!);
//
// // 3. Nếu STT vượt quá giới hạn slot (max = 2)
//                       if (nextSTT > 2) {
//                         Navigator.pop(context); // Tắt loading
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                               content: Text(
//                                   'Khung giờ này vừa mới đầy, vui lòng chọn khung giờ khác!'),
//                               backgroundColor: Colors.red
//                           ),
//                         );
//                         fetchFullTimeslots(); // Tải lại giao diện các nút giờ
//                         return;
//                       }
//
// // 4. Tiến hành lưu lịch (Bên trong hàm này Firebase đã bỏ await nên chạy tích tắc)
//                       Navigator.pop(
//                           context); // Tắt loading trước khi show dialog thành công
//                       await bookAppointment(nextSTT);
//                     } catch (e) {
//                       if (mounted) Navigator.pop(
//                           context); // Tắt loading nếu crash
//                       print("Lỗi khi đặt lịch: $e");
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text(
//                             'Có lỗi xảy ra trong quá trình xử lý lịch hẹn.')),
//                       );
//                     }
//                   },
//                   child: const Text(
//                     'ĐẶT LỊCH',
//                     style: TextStyle(color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               )
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () async {
                    if (selectedHospital == null ||
                        selectedSpecialty == null ||
                        selectedDoctor == null ||
                        selectedDate == null ||
                        selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng chọn đầy đủ thông tin')),
                      );
                      return;
                    }
                    if (!_formKey.currentState!.validate()) return;

                    String dateString = DateFormat('yyyy-MM-dd').format(selectedDate!);
                    String email = LoginScreen.loggedInEmail;

                    // Hiện hiệu ứng chờ xử lý
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      // 1. KIỂM TRA TRÙNG LỊCH (Local SQLite & Firebase Cache đã bọc timeout cực mượt)
                      bool isDupLocal = await checkDuplicateOnSQLite(email, dateString, selectedTime!);
                      bool isDupRemote = await checkDuplicateOnFirebase(email, dateString, selectedTime!);

                      if (isDupLocal || isDupRemote) {
                        Navigator.pop(context); // Tắt loading lập tức
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bạn đã có lịch hẹn sắp tới vào khung giờ này rồi!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      // 2. Lấy STT kế tiếp (Bảo vệ bằng Timeout, mất mạng nhảy ngay về Cache tính STT)
                      int nextSTT = await getNextSequenceNumber(selectedHospital!, selectedDoctor!, dateString, selectedTime!);

                      // 3. Nếu STT vượt quá giới hạn slot (max = 2)
                      if (nextSTT > 2) {
                        Navigator.pop(context); // Tắt loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Khung giờ này vừa mới đầy, vui lòng chọn khung giờ khác!'),
                              backgroundColor: Colors.red
                          ),
                        );
                        fetchFullTimeslots();
                        return;
                      }

                      // 4. Tiến hành lưu lịch (SQLite lưu trước, Firebase chạy ngầm tự đồng bộ sau)
                      Navigator.pop(context); // Tắt loading trước khi show hiển thị thành công
                      await bookAppointment(nextSTT);
                    } catch (e) {
                      if (mounted) Navigator.pop(context); // Tắt loading nếu văng lỗi
                      print("Lỗi khi đặt lịch: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Có lỗi xảy ra trong quá trình xử lý lịch hẹn.')),
                      );
                    }
                  },
                  child: const Text(
                    'ĐẶT LỊCH',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

