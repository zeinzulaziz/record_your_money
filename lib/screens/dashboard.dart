import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/storage.dart';
import '../services/supabase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final List<MoneyTransaction> items;
  const DashboardScreen({super.key, required this.items});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StorageService _storage = SupabaseStorage();
  List<MoneyTransaction> _items = [];
  bool _selecting = false;
  final Set<int> _selectedIds = {};
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _storage.init();
    await _refresh();
    _subscribeRealtime();
  }

  Future<void> _refresh() async {
    final list = await _storage.getAll();
    setState(() => _items = list);
  }

  void _subscribeRealtime() {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    // Pastikan Realtime aktif untuk tabel 'transactions' di dashboard Supabase.
    final channel = client.channel('public:transactions');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'transactions',
      // RLS akan membatasi event ke baris yang boleh dilihat user.
      callback: (_) => _refresh(),
    );
    channel.subscribe();
    _channel = channel;
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  void _toggleSelectMode() {
    setState(() {
      _selecting = !_selecting;
      _selectedIds.clear();
    });
  }

  void _toggleSelected(MoneyTransaction t, bool? checked) {
    if (t.id == null) return;
    setState(() {
      if (checked == true) {
        _selectedIds.add(t.id!);
      } else {
        _selectedIds.remove(t.id!);
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus transaksi'),
        content: Text('Hapus ${_selectedIds.length} transaksi terpilih?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;
    await _storage.deleteByIds(_selectedIds.toList());
    await _refresh();
    setState(() {
      _selecting = false;
      _selectedIds.clear();
    });
  }

  Future<void> _editItem(MoneyTransaction t) async {
    final descCtrl = TextEditingController(text: t.deskripsi);
    final totalCtrl = TextEditingController(text: t.total.toString());
    final jenis = ValueNotifier<String>(t.jenisTransaksi);
    final kategoriCtrl = TextEditingController(text: t.kategori);
    DateTime selectedDate = t.tanggal;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit transaksi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: kategoriCtrl,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<String>(
                valueListenable: jenis,
                builder: (_, value, __) => DropdownButtonFormField<String>(
                  value: value,
                  items: const [
                    DropdownMenuItem(value: 'pengeluaran', child: Text('Pengeluaran')),
                    DropdownMenuItem(value: 'pemasukan', child: Text('Pemasukan')),
                  ],
                  onChanged: (v) => jenis.value = v ?? 'pengeluaran',
                  decoration: const InputDecoration(labelText: 'Jenis'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: totalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total (Rp)'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('${selectedDate.toIso8601String().substring(0,10)}')),
                  TextButton(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) {
                        setState(() {});
                        selectedDate = d;
                      }
                    },
                    child: const Text('Pilih Tanggal'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );

    if (saved == true) {
      final edited = MoneyTransaction(
        id: t.id,
        jenisTransaksi: jenis.value,
        kategori: kategoriCtrl.text.trim().isEmpty ? t.kategori : kategoriCtrl.text.trim(),
        tanggal: selectedDate,
        deskripsi: descCtrl.text.trim().isEmpty ? t.deskripsi : descCtrl.text.trim(),
        total: int.tryParse(totalCtrl.text.trim()) ?? t.total,
      );
      await _storage.updateTransaction(edited);
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final today = DateTime.now();
    final isSameDay = (DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    int outTotal = 0;
    int inTotal = 0;
    for (final t in _items) {
      if (!isSameDay(t.tanggal, today)) continue;
      if (t.jenisTransaksi == 'pemasukan') {
        inTotal += t.total;
      } else {
        outTotal += t.total;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_selecting ? 'Pilih (${_selectedIds.length})' : 'Dashboard'),
        actions: [
          if (_selecting)
            IconButton(
              tooltip: 'Hapus terpilih',
              onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
              icon: const Icon(Icons.delete),
            ),
          IconButton(
            tooltip: _selecting ? 'Batal pilih' : 'Pilih banyak',
            onPressed: _toggleSelectMode,
            icon: Icon(_selecting ? Icons.close : Icons.checklist),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hari ini', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatCard(label: 'Pemasukan', amount: inTotal, color: Colors.green),
                const SizedBox(width: 12),
                _StatCard(label: 'Pengeluaran', amount: outTotal, color: Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            Text('Ringkasan', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final t = _items[index];
                  if (_selecting) {
                    return CheckboxListTile(
                      value: t.id != null && _selectedIds.contains(t.id),
                      onChanged: (v) => _toggleSelected(t, v),
                      title: Text('${t.deskripsi} (${t.kategori})'),
                      subtitle: Text('${t.jenisTransaksi} - ${t.tanggal.toIso8601String().substring(0, 10)}'),
                      secondary: Text(currency.format(t.total)),
                    );
                  }
                  return ListTile(
                    title: Text('${t.deskripsi} (${t.kategori})'),
                    subtitle: Text('${t.jenisTransaksi} - ${t.tanggal.toIso8601String().substring(0, 10)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(currency.format(t.total)),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editItem(t),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  const _StatCard({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Rp $amount', style: TextStyle(color: color, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}


