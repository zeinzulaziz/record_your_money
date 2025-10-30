import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart';

abstract class StorageService {
  Future<void> init();
  Future<void> upsertTransactions(List<MoneyTransaction> items);
  Future<List<MoneyTransaction>> getAll();
  Future<void> deleteByIds(List<int> ids);
  Future<void> updateTransaction(MoneyTransaction item);
}

class InMemoryStorage implements StorageService {
  final List<MoneyTransaction> _items = [];

  @override
  Future<void> init() async {}

  @override
  Future<List<MoneyTransaction>> getAll() async => List.unmodifiable(_items);

  @override
  Future<void> upsertTransactions(List<MoneyTransaction> items) async {
    _items.addAll(items);
  }

  @override
  Future<void> deleteByIds(List<int> ids) async {
    _items.removeWhere((e) => e.id != null && ids.contains(e.id));
  }

  @override
  Future<void> updateTransaction(MoneyTransaction item) async {
    if (item.id == null) return;
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx >= 0) {
      _items[idx] = item;
    }
  }
}

class SqliteStorage implements StorageService {
  static const _dbName = 'moneymind.db';
  static const _table = 'transactions';
  Database? _db;

  @override
  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jenis_transaksi TEXT NOT NULL,
            kategori TEXT NOT NULL,
            tanggal TEXT NOT NULL,
            deskripsi TEXT NOT NULL,
            total INTEGER NOT NULL
          );
        ''');
      },
    );
  }

  @override
  Future<List<MoneyTransaction>> getAll() async {
    final db = _db!;
    final rows = await db.query(_table, orderBy: 'tanggal DESC, id DESC');
    return rows
        .map((m) => MoneyTransaction.fromMap(m))
        .toList(growable: false);
  }

  @override
  Future<void> upsertTransactions(List<MoneyTransaction> items) async {
    final db = _db!;
    final batch = db.batch();
    for (final t in items) {
      batch.insert(_table, t.toMap());
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteByIds(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = _db!;
    final idList = ids.map((e) => e.toString()).join(',');
    await db.delete(_table, where: 'id IN ($idList)');
  }

  @override
  Future<void> updateTransaction(MoneyTransaction item) async {
    if (item.id == null) return;
    final db = _db!;
    await db.update(
      _table,
      item.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }
}


