import 'package:flutter/material.dart';
import 'booking_screen.dart';

class DoctorDetailScreen extends StatelessWidget {
  final String name;
  final String specialty;
  final String experience;
  // final String address;
  final String price;
  final String description;
  final String hospital;
  final String room; // 1. Bổ sung biến nhận số phòng khám từ HomeScreen

  const DoctorDetailScreen({
    super.key,
    required this.name,
    required this.specialty,
    required this.experience,
    // required this.address,
    required this.price,
    required this.description,
    required this.hospital,
    required this.room, // 2. Bắt buộc truyền vào khi gọi màn hình
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final List<String> workingTimes = [
      '08:00 AM',
      '09:00 AM',
      '10:00 AM',
      '01:00 PM',
      '02:00 PM',
      '03:00 PM',
    ];
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xffF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Chi tiết bác sĩ'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== Top Blue Card (Thông tin chính) =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    specialty,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Gom cụm các Tag thông tin nằm ngang để tối ưu hóa diện tích diện mạo
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoTag(Icons.star, '4.9', Colors.orange),
                      _buildInfoTag(Icons.work, experience, Colors.white),
                      _buildInfoTag(Icons.door_sliding, room, Colors.lightGreenAccent), // Thẻ số phòng trực quan phía trên
                    ],
                  ),
                ],
              ),
            ),
            // ===== Content (Thông tin chi tiết) =====
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giới thiệu',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildDetailItem(Icons.local_hospital, 'Bệnh viện công tác', hospital, isDarkMode),
                  const SizedBox(height: 15),
                  // // Đặt số phòng khám ngay dưới tên bệnh viện giúp người dùng dễ theo dõi lộ trình di chuyển
                  // _buildDetailItem(Icons.door_sliding, 'Phòng khám số', room, isDarkMode),
                  // const SizedBox(height: 15),
                  // _buildDetailItem(Icons.location_on, 'Địa chỉ khám', address, isDarkMode),
                  // const SizedBox(height: 15),
                  _buildDetailItem(Icons.monetization_on, 'Phí dịch vụ', price, isDarkMode),
                  const SizedBox(height: 30),
                  Text(
                    'Thời gian làm việc',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: workingTimes.map((time) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(
                              doctor: name,
                              specialty: specialty,
                              hospital: hospital,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Đặt lịch hẹn ngay',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget phụ trợ cho các nhãn icon ở trên đầu banner
  Widget _buildInfoTag(IconData icon, String text, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String content, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDarkMode ? Colors.white60 : Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}