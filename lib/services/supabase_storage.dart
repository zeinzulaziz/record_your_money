import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';
import 'storage.dart';
import '../secrets.dart';

class SupabaseStorage implements StorageService {
  static const String _table = 'transactions';
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    await Supabase.initialize(url: kSupabaseUrl, anonKey: kSupabaseAnonKey);
    _initialized = true;
  }

  @override
  Future<List<MoneyTransaction>> getAll() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    dynamic data;
    if (uid == null) {
      data = await client
          .from(_table)
          .select()
          .order('tanggal', ascending: false)
          .order('id', ascending: false);
    } else {
      data = await client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .order('tanggal', ascending: false)
          .order('id', ascending: false);
    }
    return (data as List)
        .map((e) => MoneyTransaction.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }

  @override
  Future<void> upsertTransactions(List<MoneyTransaction> items) async {
    if (items.isEmpty) return;
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    await client.from(_table).insert(items.map((e) {
      final m = e.toMap();
      if (uid != null) m['user_id'] = uid;
      return m;
    }).toList());
  }

  @override
  Future<void> deleteByIds(List<int> ids) async {
    if (ids.isEmpty) return;
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    var q = client.from(_table).delete();
    if (uid != null) q = q.eq('user_id', uid);
    await q.inFilter('id', ids);
  }

  @override
  Future<void> updateTransaction(MoneyTransaction item) async {
    if (item.id == null) return;
    final client = Supabase.instance.client;
    final map = item.toMap();
    map.remove('id');
    var q = client.from(_table).update(map).eq('id', item.id!);
    final uid = client.auth.currentUser?.id;
    if (uid != null) q = q.eq('user_id', uid);
    await q;
  }
}


