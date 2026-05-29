class Doctor {
  final String name;
  final String specialty;
  final String experience;
  final String address;     // Thêm địa chỉ
  final String price;       // Thêm giá
  final String description; // Thêm mô tả
  final String room;

  Doctor({
    required this.name,
    required this.specialty,
    required this.experience,
    required this.address,
    required this.price,
    required this.description,
    required this.room,
  });
}