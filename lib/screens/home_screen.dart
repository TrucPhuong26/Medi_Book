import 'package:flutter/material.dart';
import 'appointments_screen.dart';
import 'booking_screen.dart';
import 'doctor_detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  String selectedSpecialty = 'Tất cả';
  String selectedArea = 'Tất cả';
  String selectedHospital = 'Tất cả';
  final searchController = TextEditingController();
  final List<String> areas = ['Tất cả', 'Cần Thơ', 'TP.HCM'];
  final List<Map<String, String>> hospitals = [
    {'name': 'BV Đa khoa Trung Ương Cần Thơ', 'area': 'Cần Thơ'},
    {'name': 'BV Hoàn Mỹ Cửu Long', 'area': 'Cần Thơ'},
    {'name': 'BV Chợ Rẫy', 'area': 'TP.HCM'},
    {'name': 'BV Đại học Y Dược', 'area': 'TP.HCM'},
  ];
  final List<Map<String, dynamic>> specialties = [
    {'name': 'Tất cả', 'icon': Icons.medical_services},
    {'name': 'Tim mạch', 'icon': Icons.favorite},
    {'name': 'Da liễu', 'icon': Icons.face},
    {'name': 'Thần kinh', 'icon': Icons.psychology},
    {'name': 'Nha khoa', 'icon': Icons.medical_services},
  ];
  final List<Map<String, dynamic>> doctors = [
    {'name': 'BS. Nguyễn Văn An', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Tim mạch', 'experience': '10 năm', 'rating': '4.9', 'price': '300.000đ', 'description': 'Chuyên gia tim mạch.', 'room': 'Phòng 1'},
    {'name': 'BS. Lê Hoàng Minh', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Tim mạch', 'experience': '8 năm', 'rating': '4.8', 'price': '250.000đ', 'description': 'Bác sĩ tim mạch nhiều kinh nghiệm.', 'room': 'Phòng 2'},
    {'name': 'BS. Trần Hải Yến', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Da liễu', 'experience': '7 năm', 'rating': '4.7', 'price': '220.000đ', 'description': 'Điều trị da liễu chuyên sâu.', 'room': 'Phòng 3'},
    {'name': 'BS. Võ Minh Tân', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Da liễu', 'experience': '9 năm', 'rating': '4.9', 'price': '280.000đ', 'description': 'Chuyên trị mụn và dị ứng.', 'room': 'Phòng 4'},
    {'name': 'BS. Michael Trương', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Thần kinh', 'experience': '12 năm', 'rating': '4.8', 'price': '450.000đ', 'description': 'Điều trị đau đầu và mất ngủ.', 'room': 'Phòng 5'},
    {'name': 'BS. Lý Quốc Bảo', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Thần kinh', 'experience': '14 năm', 'rating': '4.9', 'price': '500.000đ', 'description': 'Chuyên thần kinh chuyên sâu.', 'room': 'Phòng 6'},
    {'name': 'BS. Trần Anh Khoa', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Nha khoa', 'experience': '6 năm', 'rating': '4.7', 'price': '180.000đ', 'description': 'Nha khoa thẩm mỹ.', 'room': 'Phòng 7'},
    {'name': 'BS. Nguyễn Thành Đạt', 'hospital': 'BV Chợ Rẫy', 'specialty': 'Nha khoa', 'experience': '11 năm', 'rating': '4.9', 'price': '320.000đ', 'description': 'Implant chuyên sâu.', 'room': 'Phòng 8'},
    {'name': 'BS. Trần Thị Kim', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Tim mạch', 'experience': '15 năm', 'rating': '5.0', 'price': '500.000đ', 'description': 'Tim mạch can thiệp.', 'room': 'Phòng 9'},
    {'name': 'BS. Phạm Đức Long', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Tim mạch', 'experience': '9 năm', 'rating': '4.8', 'price': '350.000đ', 'description': 'Khám tim mạch tổng quát.', 'room': 'Phòng 10'},
    {'name': 'BS. Lê Thị Bình', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Da liễu', 'experience': '7 năm', 'rating': '4.8', 'price': '250.000đ', 'description': 'Điều trị da liễu.', 'room': 'Phòng 11'},
    {'name': 'BS. Dương Ngọc Hà', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Da liễu', 'experience': '10 năm', 'rating': '4.9', 'price': '300.000đ', 'description': 'Chuyên da thẩm mỹ.', 'room': 'Phòng 12'},
    {'name': 'BS. Đặng Minh Tâm', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Thần kinh', 'experience': '20 năm', 'rating': '4.9', 'price': '600.000đ', 'description': 'Điều trị thần kinh.', 'room': 'Phòng 13'},
    {'name': 'BS. Huỳnh Quốc Việt', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Thần kinh', 'experience': '13 năm', 'rating': '4.8', 'price': '480.000đ', 'description': 'Khám thần kinh.', 'room': 'Phòng 14'},
    {'name': 'BS. Emily Trịnh', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Nha khoa', 'experience': '5 năm', 'rating': '4.6', 'price': '150.000đ', 'description': 'Nha khoa thẩm mỹ.', 'room': 'Phòng 15'},
    {'name': 'BS. Đỗ Minh Phúc', 'hospital': 'BV Đại học Y Dược', 'specialty': 'Nha khoa', 'experience': '8 năm', 'rating': '4.8', 'price': '280.000đ', 'description': 'Niềng răng.', 'room': 'Phòng 16'},
    {'name': 'BS. Võ Thành Nhân', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Tim mạch', 'experience': '9 năm', 'rating': '4.7', 'price': '270.000đ', 'description': 'Tim mạch tổng quát.', 'room': 'Phòng 17'},
    {'name': 'BS. Nguyễn Gia Hân', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Tim mạch', 'experience': '11 năm', 'rating': '4.8', 'price': '320.000đ', 'description': 'Tim mạch chuyên sâu.', 'room': 'Phòng 18'},
    {'name': 'BS. Hồ Thanh Vy', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Da liễu', 'experience': '6 năm', 'rating': '4.7', 'price': '210.000đ', 'description': 'Da liễu tổng quát.', 'room': 'Phòng 19'},
    {'name': 'BS. Lâm Quốc Huy', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Da liễu', 'experience': '8 năm', 'rating': '4.8', 'price': '260.000đ', 'description': 'Điều trị mụn.', 'room': 'Phòng 20'},
    {'name': 'BS. Trịnh Hoài Nam', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Thần kinh', 'experience': '10 năm', 'rating': '4.8', 'price': '390.000đ', 'description': 'Khám thần kinh.', 'room': 'Phòng 21'},
    {'name': 'BS. Bùi Khánh Linh', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Thần kinh', 'experience': '12 năm', 'rating': '4.9', 'price': '420.000đ', 'description': 'Điều trị mất ngủ.', 'room': 'Phòng 22'},
    {'name': 'BS. Vương Đình Khôi', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Nha khoa', 'experience': '8 năm', 'rating': '4.8', 'price': '250.000đ', 'description': 'Implant.', 'room': 'Phòng 23'},
    {'name': 'BS. Đoàn Thanh Tùng', 'hospital': 'BV Hoàn Mỹ Cửu Long', 'specialty': 'Nha khoa', 'experience': '7 năm', 'rating': '4.7', 'price': '220.000đ', 'description': 'Răng sứ.', 'room': 'Phòng 24'},
    {'name': 'BS. Lê Văn Phước', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Tim mạch', 'experience': '10 năm', 'rating': '4.8', 'price': '300.000đ', 'description': 'Khám tim.', 'room': 'Phòng 25'},
    {'name': 'BS. Trần Gia Bảo', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Tim mạch', 'experience': '9 năm', 'rating': '4.7', 'price': '280.000đ', 'description': 'Tim mạch.', 'room': 'Phòng 26'},
    {'name': 'BS. Hoàng Gia Bảo', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Da liễu', 'experience': '5 năm', 'rating': '4.7', 'price': '200.000đ', 'description': 'Da liễu.', 'room': 'Phòng 27'},
    {'name': 'BS. Nguyễn Mỹ Linh', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Da liễu', 'experience': '7 năm', 'rating': '4.8', 'price': '240.000đ', 'description': 'Da chuyên sâu.', 'room': 'Phòng 28'},
    {'name': 'BS. Võ Minh Quân', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Thần kinh', 'experience': '11 năm', 'rating': '4.8', 'price': '430.000đ', 'description': 'Điều trị thần kinh.', 'room': 'Phòng 29'},
    {'name': 'BS. Lý Minh Triết', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Thần kinh', 'experience': '14 năm', 'rating': '4.9', 'price': '500.000đ', 'description': 'Mất ngủ và đau đầu.', 'room': 'Phòng 30'},
    {'name': 'BS. Khưu Anh Tú', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Nha khoa', 'experience': '6 năm', 'rating': '4.7', 'price': '190.000đ', 'description': 'Nha khoa.', 'room': 'Phòng 31'},
    {'name': 'BS. Phạm Nhật Nam', 'hospital': 'BV Đa khoa Trung Ương Cần Thơ', 'specialty': 'Nha khoa', 'experience': '9 năm', 'rating': '4.8', 'price': '270.000đ', 'description': 'Niềng răng.', 'room': 'Phòng 32'},
  ];
  String removeDiacritics(String str) {
    const withDiacritics = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    const withoutDiacritics = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
    for (int i = 0; i < withDiacritics.length; i++) {
      str = str.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return str.toLowerCase();
  }
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color dropdownTextColor = isDarkMode ? Colors.white : Colors.black;
    Color menuBgColor = isDarkMode ? const Color(0xff2C2C2C) : Colors.white;
    Color fieldBgColor = isDarkMode ? const Color(0xff1E1E1E) : Colors.white;
    Color cardBgColor = isDarkMode ? const Color(0xff2A2A2A) : Colors.white;

    final filteredHospitals = hospitals.where((hospital) {
      if (selectedArea == 'Tất cả') return true;
      return hospital['area'] == selectedArea;
    }).toList();

    final filteredDoctors = doctors.where((doctor) {
      final matchSpecialty = selectedSpecialty == 'Tất cả' || doctor['specialty'] == selectedSpecialty;
      bool matchHospital = true;
      if (selectedHospital != 'Tất cả') {
        matchHospital = doctor['hospital'] == selectedHospital;
      } else if (selectedArea != 'Tất cả') {
        final doctorHospital = hospitals.firstWhere(
              (h) => h['name'] == doctor['hospital'],
          orElse: () => {'name': '', 'area': ''},
        );
        matchHospital = doctorHospital['area'] == selectedArea;
      }

      final searchKeywordNormalized = removeDiacritics(searchController.text.trim());
      bool matchSearch = false;
      if (searchKeywordNormalized.isEmpty) {
        matchSearch = true;
      } else {
        final doctorNameNormalized = removeDiacritics(doctor['name'].toString());
        final words = doctorNameNormalized.split(' ');
        matchSearch = words.any((word) => word.startsWith(searchKeywordNormalized));
      }
      return matchSpecialty && matchHospital && matchSearch;
    }).toList();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('MediBook'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingScreen())),
            icon: const Icon(Icons.add_box_rounded),
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentsScreen())),
            icon: const Icon(Icons.calendar_month),
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          // Tính toán số cột hiển thị cho Grid dựa trên độ rộng màn hình thực tế
          int crossAxisCount = 2; // Mặc định cho điện thoại dọc
          if (width > 1200) {
            crossAxisCount = 5; // Màn hình PC lớn / Web
          } else if (width > 900) {
            crossAxisCount = 4; // Máy tính bảng ngang / PC nhỏ
          } else if (width > 600) {
            crossAxisCount = 3; // Máy tính bảng dọc / Điện thoại xoay ngang
          }
          // Kiểm tra xem màn hình có thuộc dạng màn hình rộng (Tablet/PC) không
          bool isWideScreen = width > 750;
          return SingleChildScrollView(
            child: Center(
              child: Container(
                // Giới hạn chiều rộng tối đa trên PC để giao diện không bị dàn trải quá mức
                constraints: const BoxConstraints(maxWidth: 1400),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PHẦN BANNER VÀ BỘ LỌC TÌM KIẾM
                    if (isWideScreen)
                    // Bố cục màn hình lớn (Xoay ngang / Tablet / PC): Chia làm 2 bên trái phải
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: _buildBanner()),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  _buildSearchField(fieldBgColor, dropdownTextColor),
                                  const SizedBox(height: 12),
                                  _buildAreaDropdown(fieldBgColor, menuBgColor, dropdownTextColor),
                                  const SizedBox(height: 12),
                                  _buildHospitalDropdown(fieldBgColor, menuBgColor, dropdownTextColor, filteredHospitals),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    else
                    // Bố cục điện thoại dọc: Xếp chồng từ trên xuống dưới
                      Column(
                        children: [
                          _buildBanner(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildSearchField(fieldBgColor, dropdownTextColor),
                          ),
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildAreaDropdown(fieldBgColor, menuBgColor, dropdownTextColor),
                          ),
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildHospitalDropdown(fieldBgColor, menuBgColor, dropdownTextColor, filteredHospitals),
                          ),
                        ],
                      ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Chuyên khoa', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: dropdownTextColor)),
                    ),
                    const SizedBox(height: 15),
                    // DANH SÁCH CHUYÊN KHOA (NẰM NGANG)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: specialties.length,
                        itemBuilder: (context, index) {
                          final specialty = specialties[index];
                          bool isSelected = selectedSpecialty == specialty['name'];
                          return GestureDetector(
                            onTap: () => setState(() => selectedSpecialty = specialty['name']),
                            child: Container(
                              width: 110,
                              margin: const EdgeInsets.only(left: 16),
                              decoration: BoxDecoration(color: isSelected ? Colors.blue : fieldBgColor, borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(specialty['icon'], size: 40, color: isSelected ? Colors.white : Colors.blue),
                                  const SizedBox(height: 10),
                                  Text(specialty['name'], style: TextStyle(color: isSelected ? Colors.white : dropdownTextColor, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Bác sĩ hàng đầu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: dropdownTextColor)),
                    ),
                    const SizedBox(height: 15),
                    // LƯỚI DANH SÁCH BÁC SĨ (RESPONSIVE GRID)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDoctors.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (context, index) {
                        final doctor = filteredDoctors[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorDetailScreen(
                                  name: doctor['name'],
                                  specialty: doctor['specialty'],
                                  experience: doctor['experience'],
                                  price: doctor['price'],
                                  description: doctor['description'],
                                  hospital: doctor['hospital'],
                                  room: doctor['room'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            color: cardBgColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const CircleAvatar(
                                            radius: 32,
                                            backgroundColor: Color(0xffe3f2fd),
                                            child: Icon(Icons.person, size: 32, color: Colors.blue)
                                        ),
                                        const SizedBox(height: 8),
                                        // Tên bác sĩ
                                        Text(
                                            doctor['name'],
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: dropdownTextColor)
                                        ),
                                        const SizedBox(height: 4),
                                        // Chuyên khoa
                                        Text(
                                            doctor['specialty'],
                                            style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500)
                                        ),
                                        const SizedBox(height: 2),
                                        // Bệnh viện
                                        Flexible(
                                          child: Text(
                                              doctor['hospital'],
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Colors.grey, fontSize: 11)
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center, // Đẩy kinh nghiệm gan nhau rating o giua
                                          children: [
                                            Flexible(
                                              child: Text(
                                                  doctor['experience'],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)
                                              ),
                                            ),
                              const SizedBox(width: 12),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.star, color: Colors.orange, size: 13),
                                                const SizedBox(width: 3),
                                                Text(
                                                    doctor['rating'],
                                                    style: TextStyle(color: dropdownTextColor, fontSize: 11, fontWeight: FontWeight.bold)
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  // Nút Đặt lịch
                                  SizedBox(
                                    width: double.infinity,
                                    height: 36,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BookingScreen(
                                              doctor: doctor['name'],
                                              specialty: doctor['specialty'],
                                              hospital: doctor['hospital'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Đặt lịch', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  // CÁC HÀM PHỤ TRỢ TÁCH BIỆT WIDGET ĐỂ CODE GỌN GÀNG HƠN
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xff4A90E2), Color(0xff357AE8)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Find Your Doctor', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Đặt lịch hẹn với các chuyên gia hàng đầu một cách dễ dàng', style: TextStyle(color: Colors.white70, fontSize: 15)),
              ],
            ),
          ),
          const Icon(Icons.local_hospital, color: Colors.white, size: 75),
        ],
      ),
    );
  }
  Widget _buildSearchField(Color fieldBgColor, Color textColor) {
    return TextField(
      controller: searchController,
      style: TextStyle(color: textColor),
      onChanged: (value) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm bác sĩ...',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: fieldBgColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    );
  }
  Widget _buildAreaDropdown(Color fieldBgColor, Color menuBgColor, Color dropdownTextColor) {
    return DropdownButtonFormField<String>(
      value: selectedArea,
      dropdownColor: menuBgColor,
      style: TextStyle(color: dropdownTextColor, fontSize: 15),
      iconEnabledColor: Colors.blue,
      decoration: InputDecoration(
        labelText: 'Chọn khu vực',
        labelStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: fieldBgColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
      items: areas.map((area) => DropdownMenuItem(
          value: area,
          child: Text(area, style: TextStyle(color: dropdownTextColor, fontSize: 15, fontWeight: FontWeight.w500))
      )).toList(),
      onChanged: (value) => setState(() {
        selectedArea = value!;
        selectedHospital = 'Tất cả';
      }),
    );
  }
  Widget _buildHospitalDropdown(Color fieldBgColor, Color menuBgColor, Color dropdownTextColor, List<Map<String, String>> filteredHospitals) {
    return DropdownButtonFormField<String>(
      value: selectedHospital,
      dropdownColor: menuBgColor,
      style: TextStyle(color: dropdownTextColor, fontSize: 15),
      iconEnabledColor: Colors.blue,
      decoration: InputDecoration(
        labelText: 'Chọn bệnh viện',
        labelStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: fieldBgColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
      items: [
        DropdownMenuItem(value: 'Tất cả', child: Text('Tất cả', style: TextStyle(color: dropdownTextColor, fontSize: 15, fontWeight: FontWeight.w500))),
        ...filteredHospitals.map((hospital) => DropdownMenuItem(
            value: hospital['name'],
            child: Text(hospital['name']!, style: TextStyle(color: dropdownTextColor, fontSize: 15, fontWeight: FontWeight.w500))
        )).toList(),
      ],
      onChanged: (value) => setState(() {
        selectedHospital = value!;
      }),
    );
  }
}