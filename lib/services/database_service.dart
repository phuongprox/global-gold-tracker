import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/transaction.dart' as model; // Sử dụng alias để tránh xung đột

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/tichchi.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Bảng transactions
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quantity REAL,
        price INTEGER,
        type TEXT,
        date TEXT
      )
    ''');

    // Bảng alerts
    await db.execute('''
      CREATE TABLE alerts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gold_type TEXT,
        target_price REAL,
        condition TEXT,
        is_active INTEGER,
        created_at TEXT
      )
    ''');
  }

  // Transaction operations - Sử dụng model.Transaction để tránh xung đột
  Future<int> insertTransaction(model.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', {
      'quantity': transaction.quantity,
      'price': transaction.price,
      'type': transaction.type,
      'date': transaction.date.toIso8601String(),
    });
  }

  Future<List<model.Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return model.Transaction(
        quantity: maps[i]['quantity'],
        price: maps[i]['price'],
        type: maps[i]['type'],
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTransaction(int id, model.Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      {
        'quantity': transaction.quantity,
        'price': transaction.price,
        'type': transaction.type,
        'date': transaction.date.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Alert operations
  Future<int> insertAlert(Map<String, dynamic> alert) async {
    final db = await database;
    return await db.insert('alerts', alert);
  }

  Future<List<Map<String, dynamic>>> getAlerts() async {
    final db = await database;
    return await db.query('alerts', where: 'is_active = ?', whereArgs: [1]);
  }

  Future<List<Map<String, dynamic>>> getAllAlerts() async {
    final db = await database;
    return await db.query('alerts', orderBy: 'created_at DESC');
  }

  Future<int> updateAlertStatus(int id, bool isActive) async {
    final db = await database;
    return await db.update(
      'alerts',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAlert(int id) async {
    final db = await database;
    return await db.delete('alerts', where: 'id = ?', whereArgs: [id]);
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('alerts');
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;

    // Tổng số lượng vàng đã mua
    final buyResult = await db.rawQuery(
        'SELECT SUM(quantity) as total FROM transactions WHERE type = "BUY"');
    final totalBuyQuantity = buyResult.first['total'] as double? ?? 0;

    // Tổng số lượng vàng đã bán
    final sellResult = await db.rawQuery(
        'SELECT SUM(quantity) as total FROM transactions WHERE type = "SELL"');
    final totalSellQuantity = sellResult.first['total'] as double? ?? 0;

    // Số lượng vàng còn lại
    final remainingQuantity =
        totalBuyQuantity + totalSellQuantity; // sell là số âm

    // Tổng chi phí
    final costResult = await db.rawQuery(
        'SELECT SUM(quantity * price) as total FROM transactions WHERE type = "BUY"');
    final totalCost = costResult.first['total'] as int? ?? 0;

    return {
      'totalBuyQuantity': totalBuyQuantity,
      'totalSellQuantity': totalSellQuantity.abs(),
      'remainingQuantity': remainingQuantity,
      'totalCost': totalCost,
      'transactionCount': await getTransactionCount(),
    };
  }

  Future<int> getTransactionCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM transactions');
    return result.first['count'] as int? ?? 0;
  }
}
