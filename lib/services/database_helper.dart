import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/mock_data.dart';
import '../models/invoice_model.dart';
import '../models/maintenance_request_model.dart';
import '../models/room_member_model.dart';
import '../models/room_model.dart';

/// ============================================================================
/// SERVICE: Quản Lý Cơ Sở Dữ Liệu Cục Bộ SQLite (DatabaseHelper)
/// ============================================================================
/// Quản lý khởi tạo CSDL, nâng cấp phiên bản (Database Migration v3), và thực hiện
/// các câu lệnh CRUD cho 4 bảng dữ liệu chính:
/// 1. `rooms`: Danh sách phòng trọ
/// 2. `invoices`: Danh sách hóa đơn tính tiền
/// 3. `room_members`: Danh sách cư dân & số CCCD/CMND
/// 4. `maintenance_requests`: Yêu cầu bảo trì & sự cố thiết bị
/// ============================================================================
class DatabaseHelper {
  static const String _dbName = 'rental_management.db';
  static const int _dbVersion = 3;

  static Database? _database;

  /// Lấy đối tượng Database đơn thể (Singleton Pattern)
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Khởi tạo và kết nối cơ sở dữ liệu SQLite
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createTables(db);

        // Nạp dữ liệu mẫu ban đầu cho danh sách phòng
        for (var room in initialRooms) {
          await db.insert('rooms', room.toMap());
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createRoomMembersTable(db);
        }
        if (oldVersion < 3) {
          await _createMaintenanceRequestsTable(db);
        }
      },
    );
  }

  /// Tạo tất cả các bảng trong CSDL SQLite
  static Future<void> _createTables(Database db) async {
    // Bảng 1: Quản lý Phòng trọ
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rooms (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        base_price REAL NOT NULL,
        status TEXT NOT NULL,
        tenant_name TEXT,
        phone TEXT,
        contract_end TEXT,
        old_electricity INTEGER NOT NULL,
        old_water INTEGER NOT NULL,
        image_url TEXT,
        occupant_count INTEGER DEFAULT 1,
        check_in_date TEXT,
        check_out_date TEXT,
        deposit_amount REAL DEFAULT 0.0
      )
    ''');

    // Bảng 2: Quản lý Hóa đơn
    await db.execute('''
      CREATE TABLE IF NOT EXISTS invoices (
        id TEXT PRIMARY KEY,
        room_id TEXT NOT NULL,
        room_name TEXT NOT NULL,
        tenant_name TEXT NOT NULL,
        room_price REAL NOT NULL,
        old_elec INTEGER NOT NULL,
        new_elec INTEGER NOT NULL,
        elec_price REAL NOT NULL,
        old_water INTEGER NOT NULL,
        new_water INTEGER NOT NULL,
        water_price REAL NOT NULL,
        service_fee REAL NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL,
        paid_at TEXT
      )
    ''');

    // Bảng 3: Quản lý Thành viên & CCCD
    await _createRoomMembersTable(db);

    // Bảng 4: Quản lý Sự cố & Bảo trì
    await _createMaintenanceRequestsTable(db);
  }

  /// Tạo bảng lưu trữ thông tin Cư dân & CCCD/CMND
  static Future<void> _createRoomMembersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS room_members (
        id TEXT PRIMARY KEY,
        room_id TEXT NOT NULL,
        name TEXT NOT NULL,
        id_card TEXT NOT NULL,
        phone TEXT,
        date_of_birth TEXT,
        hometown TEXT,
        is_representative INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  /// Tạo bảng lưu trữ thông tin Sự cố & Bảo trì thiết bị
  static Future<void> _createMaintenanceRequestsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS maintenance_requests (
        id TEXT PRIMARY KEY,
        room_id TEXT NOT NULL,
        room_name TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        repair_cost REAL DEFAULT 0.0,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        completed_at TEXT
      )
    ''');
  }

  // ===========================================================================
  // 1. CÁC THAO TÁC CRUD TRÊN BẢNG ROOMS (PHÒNG TRỌ)
  // ===========================================================================

  /// Lấy toàn bộ danh sách phòng trọ
  static Future<List<Room>> getRooms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('rooms');
    return maps.map((map) => Room.fromMap(map)).toList();
  }

  /// Thêm mới phòng trọ
  static Future<void> insertRoom(Room room) async {
    final db = await database;
    await db.insert(
      'rooms',
      room.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Cập nhật thông tin phòng trọ
  static Future<void> updateRoom(Room room) async {
    final db = await database;
    await db.update(
      'rooms',
      room.toMap(),
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  /// Xóa phòng trọ & các dữ liệu liên quan
  /// (thành viên, hóa đơn, sự cố bảo trì) trong cùng một transaction để
  /// Dashboard không còn tính doanh thu/chi phí của phòng đã xóa.
  static Future<void> deleteRoom(String roomId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('room_members',
          where: 'room_id = ?', whereArgs: [roomId]);
      await txn.delete('invoices', where: 'room_id = ?', whereArgs: [roomId]);
      await txn.delete('maintenance_requests',
          where: 'room_id = ?', whereArgs: [roomId]);
      await txn.delete('rooms', where: 'id = ?', whereArgs: [roomId]);
    });
  }

  // ===========================================================================
  // 2. CÁC THAO TÁC CRUD TRÊN BẢNG INVOICES (HÓA ĐƠN)
  // ===========================================================================

  /// Lấy toàn bộ lịch sử hóa đơn (xắp xếp mới nhất lên đầu)
  static Future<List<Invoice>> getInvoices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('invoices', orderBy: 'created_at DESC');
    return maps.map((map) => Invoice.fromMap(map)).toList();
  }

  /// Thêm mới một hóa đơn
  static Future<void> insertInvoice(Invoice invoice) async {
    final db = await database;
    await db.insert(
      'invoices',
      invoice.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Cập nhật trạng thái thanh toán của hóa đơn
  static Future<void> updateInvoiceStatus(
      String invoiceId, InvoiceStatus status, DateTime? paidAt) async {
    final db = await database;
    await db.update(
      'invoices',
      {
        'status': status.name,
        'paid_at': paidAt?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  /// Xóa hóa đơn
  static Future<void> deleteInvoice(String invoiceId) async {
    final db = await database;
    await db.delete(
      'invoices',
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  // ===========================================================================
  // 3. CÁC THAO TÁC CRUD TRÊN BẢNG ROOM_MEMBERS (CƯ DÂN & CCCD)
  // ===========================================================================

  /// Lấy danh sách thành viên trong một phòng cụ thể
  static Future<List<RoomMember>> getRoomMembers(String roomId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'room_members',
      where: 'room_id = ?',
      whereArgs: [roomId],
      orderBy: 'is_representative DESC, created_at ASC',
    );
    return maps.map((map) => RoomMember.fromMap(map)).toList();
  }

  /// Thêm mới một thành viên CCCD
  static Future<void> insertRoomMember(RoomMember member) async {
    final db = await database;
    await db.insert(
      'room_members',
      member.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Cập nhật thông tin thành viên CCCD
  static Future<void> updateRoomMember(RoomMember member) async {
    final db = await database;
    await db.update(
      'room_members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  /// Xóa một thành viên khỏi phòng
  static Future<void> deleteRoomMember(String memberId) async {
    final db = await database;
    await db.delete(
      'room_members',
      where: 'id = ?',
      whereArgs: [memberId],
    );
  }

  /// Xóa toàn bộ thành viên của một phòng (Dùng khi trả phòng)
  static Future<void> deleteMembersForRoom(String roomId) async {
    final db = await database;
    await db.delete(
      'room_members',
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }

  // ===========================================================================
  // 4. CÁC THAO TÁC CRUD TRÊN BẢNG MAINTENANCE_REQUESTS (BẢO TRÌ SỰ CỐ)
  // ===========================================================================

  /// Lấy toàn bộ danh sách yêu cầu bảo trì (xắp xếp mới nhất lên đầu)
  static Future<List<MaintenanceRequest>> getMaintenanceRequests() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'maintenance_requests',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => MaintenanceRequest.fromMap(map)).toList();
  }

  /// Thêm mới báo cáo sự cố bảo trì
  static Future<void> insertMaintenanceRequest(MaintenanceRequest req) async {
    final db = await database;
    await db.insert(
      'maintenance_requests',
      req.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Cập nhật tiến độ & chi phí bảo trì
  static Future<void> updateMaintenanceRequest(MaintenanceRequest req) async {
    final db = await database;
    await db.update(
      'maintenance_requests',
      req.toMap(),
      where: 'id = ?',
      whereArgs: [req.id],
    );
  }

  /// Xóa yêu cầu bảo trì
  static Future<void> deleteMaintenanceRequest(String reqId) async {
    final db = await database;
    await db.delete(
      'maintenance_requests',
      where: 'id = ?',
      whereArgs: [reqId],
    );
  }
}
