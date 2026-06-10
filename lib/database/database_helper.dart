import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medibook.db');
    return _database!;
  }
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
  Future _createDB(Database db, int version) async {
    // 1. Tạo bảng users
    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      email TEXT,
      password TEXT
    )
    ''');
    // 2. Tạo bảng appointments
    await db.execute('''
    CREATE TABLE appointments(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userEmail TEXT,
      hospital TEXT,
      doctor TEXT,
      specialty TEXT,
      room TEXT,          
      date TEXT,
      time TEXT,
      symptom TEXT,
      status TEXT DEFAULT 'upcoming',
      stt INTEGER DEFAULT 0
    )
    ''');
  }
  // ================= UPDATE USER PASSWORD =================
  Future<int> updateUserPassword(String email, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }
  // ================= REGISTER =================
  Future<int> registerUser(String name, String email, String password) async {
    final db = await instance.database;
    return await db.insert(
      'users',
      {
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }
  // ================= LOGIN =================
  Future<bool> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty;
  }
  // ================= ADD APPOINTMENT =================
  Future<int> addAppointment({
    required String userEmail,
    required String hospital,
    required String doctor,
    required String specialty,
    required String room,
    required String date,
    required String time,
    required String symptoms,
    String status = 'upcoming',
    int stt = 0,
  }) async {
    final db = await database;
    return await db.insert(
      'appointments',
      {
        'userEmail': userEmail,
        'hospital': hospital,
        'doctor': doctor,
        'specialty': specialty,
        'room': room,
        'date': date,
        'time': time,
        'symptom': symptoms,
        'status': status,
        'stt': stt,
      },
    );
  }
  // ================= GET APPOINTMENTS ================
  Future<List<Map<String, dynamic>>> getAppointments(String userEmail) async {
    final db = await database;
    return await db.query(
      'appointments',
      where: 'userEmail = ?',
      whereArgs: [userEmail],
      orderBy: 'id DESC',
    );
  }
  //====================================================
  Future<List<Map<String, dynamic>>> getAppointmentsByUser(String userEmail) async {
    final db = await database;
    return await db.query(
      'appointments',
      where: 'userEmail = ?',
      whereArgs: [userEmail],
      orderBy: 'id DESC',
    );
  }
  // ================= DELETE =================
  Future<int> deleteAppointment(int id) async {
    final db = await database;
    return await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
// ================= CHECK DUPLICATE (CHỈ CHẶN NẾU LỊCH ĐANG UPCOMING) =================
  Future<bool> isAppointmentDuplicate(
      String email,
      String date,
      String time,
      ) async {
    final db = await database;
    final result = await db.query(
      'appointments',
      where: 'userEmail = ? AND date = ? AND time = ? AND status = ?',
      whereArgs: [
        email,
        date,
        time,
        'upcoming', // Chỉ những lịch hẹn sắp diễn ra mới tính là trùng
      ],
    );
    return result.isNotEmpty;
  }
  // ================= CHECK EMAIL =================
  Future<bool> checkEmailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }
  // ================= DELETE USER =================
  Future<int> deleteUserByEmail(String email) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
  }
  // ================= CẬP NHẬT NGÀY GIỜ VÀ STT MỚI SẠCH SẼ =================
  Future<int> updateAppointmentTime(dynamic id, String date, String time, int stt) async {
    final db = await database;
    if (id is int) {
      return await db.update(
        'appointments',
        {
          'date': date,
          'time': time,
          'stt': stt,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    return 0;
  }
  // ================= CẬP NHẬT TRẠNG THÁI VÀ RESET STT VỀ 0 =================
  Future<int> updateAppointmentStatus(dynamic id, String newStatus) async {
    final db = await database;
    if (id is int) {
      return await db.update(
        'appointments',
        {
          'status': newStatus,
          'stt': 0,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    return 0;
  }
  // ================= GET USER =================
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}