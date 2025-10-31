import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/storage.dart';
import '../services/supabase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

enum FilterPeriod {
  hari,
  minggu,
  bulan,
  tahun,
  custom,
}

enum FilterMode {
  quick,
  custom,
}

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
  FilterPeriod _selectedFilter = FilterPeriod.hari;
  FilterMode _filterMode = FilterMode.quick;
  DateTime? _startDate;
  DateTime? _endDate;

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

  List<MoneyTransaction> _getFilteredTransactions() {
    final now = DateTime.now();
    final filtered = <MoneyTransaction>[];
    
    for (final t in _items) {
      bool include = false;
      
      // Custom date range filter
      if (_filterMode == FilterMode.custom && _startDate != null && _endDate != null) {
        final txDate = DateTime(t.tanggal.year, t.tanggal.month, t.tanggal.day);
        final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
        include = !txDate.isBefore(start) && !txDate.isAfter(end);
      } else {
        // Quick filter period
        switch (_selectedFilter) {
          case FilterPeriod.hari:
            include = t.tanggal.year == now.year &&
                      t.tanggal.month == now.month &&
                      t.tanggal.day == now.day;
            break;
          case FilterPeriod.minggu:
            // Get Monday of current week (weekday: 1 = Monday, 7 = Sunday)
            final daysFromMonday = (now.weekday - 1) % 7;
            final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysFromMonday));
            final weekEnd = weekStart.add(const Duration(days: 6));
            final txDate = DateTime(t.tanggal.year, t.tanggal.month, t.tanggal.day);
            include = !txDate.isBefore(weekStart) && !txDate.isAfter(weekEnd);
            break;
          case FilterPeriod.bulan:
            include = t.tanggal.year == now.year &&
                      t.tanggal.month == now.month;
            break;
          case FilterPeriod.tahun:
            include = t.tanggal.year == now.year;
            break;
          case FilterPeriod.custom:
            include = false;
            break;
        }
      }
      
      if (include) {
        filtered.add(t);
      }
    }
    
    return filtered;
  }

  String _getFilterLabel() {
    if (_filterMode == FilterMode.custom && _startDate != null && _endDate != null) {
      return '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}';
    }
    switch (_selectedFilter) {
      case FilterPeriod.hari:
        return 'Hari ini';
      case FilterPeriod.minggu:
        return 'Minggu ini';
      case FilterPeriod.bulan:
        return 'Bulan ini';
      case FilterPeriod.tahun:
        return 'Tahun ini';
      case FilterPeriod.custom:
        return 'Custom Range';
    }
  }

  Future<void> _showCustomDateRangePicker() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedStart = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now.subtract(const Duration(days: 7)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Pilih Tanggal Mulai',
    );
    
    if (pickedStart == null) return;
    
    final DateTime? pickedEnd = await showDatePicker(
      context: context,
      initialDate: _endDate ?? pickedStart,
      firstDate: pickedStart,
      lastDate: DateTime(2100),
      helpText: 'Pilih Tanggal Akhir',
    );
    
    if (pickedEnd != null) {
      setState(() {
        _startDate = pickedStart;
        _endDate = pickedEnd;
        _filterMode = FilterMode.custom;
        _selectedFilter = FilterPeriod.custom;
      });
    }
  }

  void _resetToQuickFilter(FilterPeriod period) {
    setState(() {
      _filterMode = FilterMode.quick;
      _selectedFilter = period;
      _startDate = null;
      _endDate = null;
    });
  }

  Widget _buildFilterButton(String label, FilterPeriod period, {bool isFirst = false}) {
    final isSelected = _filterMode == FilterMode.quick && _selectedFilter == period;
    return GestureDetector(
      onTap: () => _resetToQuickFilter(period),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? const Radius.circular(8) : Radius.zero,
            bottomLeft: isFirst ? const Radius.circular(8) : Radius.zero,
            topRight: !isFirst && period == FilterPeriod.tahun ? const Radius.circular(8) : Radius.zero,
            bottomRight: !isFirst && period == FilterPeriod.tahun ? const Radius.circular(8) : Radius.zero,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
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
    final filteredTransactions = _getFilteredTransactions();
    
    int outTotal = 0;
    int inTotal = 0;
    for (final t in filteredTransactions) {
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
      body: Column(
        children: [
          // Fixed Header Section
          Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Periode',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterButton(
                          'Harian',
                          FilterPeriod.hari,
                          isFirst: true,
                        ),
                      ),
                      Expanded(
                        child: _buildFilterButton(
                          'Mingguan',
                          FilterPeriod.minggu,
                        ),
                      ),
                      Expanded(
                        child: _buildFilterButton(
                          'Bulanan',
                          FilterPeriod.bulan,
                        ),
                      ),
                      Expanded(
                        child: _buildFilterButton(
                          'Tahunan',
                          FilterPeriod.tahun,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        height: 36,
                        width: 36,
                        child: IconButton(
                          onPressed: _showCustomDateRangePicker,
                          icon: const Icon(Icons.date_range, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: _filterMode == FilterMode.custom
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            foregroundColor: _filterMode == FilterMode.custom
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: _filterMode == FilterMode.custom
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_filterMode == FilterMode.custom && _startDate != null && _endDate != null)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate!,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  helpText: 'Pilih Tanggal Mulai',
                                );
                                if (picked != null) {
                                  setState(() {
                                    _startDate = picked;
                                    if (_endDate != null && _startDate!.isAfter(_endDate!)) {
                                      _endDate = _startDate;
                                    }
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mulai',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatDate(_startDate!),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate!,
                                  firstDate: _startDate ?? DateTime(2000),
                                  lastDate: DateTime(2100),
                                  helpText: 'Pilih Tanggal Akhir',
                                );
                                if (picked != null) {
                                  setState(() {
                                    _endDate = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selesai',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatDate(_endDate!),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _filterMode = FilterMode.quick;
                                _selectedFilter = FilterPeriod.hari;
                                _startDate = null;
                                _endDate = null;
                              });
                            },
                            tooltip: 'Reset',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Total Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getFilterLabel(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${filteredTransactions.length} transaksi',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Pemasukan',
                    amount: inTotal,
                    color: Colors.green,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Pengeluaran',
                    amount: outTotal,
                    color: Colors.red,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    currency.format(inTotal - outTotal),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: (inTotal - outTotal) >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
          
          // Scrollable Transaction List
            Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada transaksi untuk periode ini',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ringkasan',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
            Expanded(
              child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                            final t = filteredTransactions[index];
                  if (_selecting) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: CheckboxListTile(
                      value: t.id != null && _selectedIds.contains(t.id),
                      onChanged: (v) => _toggleSelected(t, v),
                                  title: Text(
                                    t.deskripsi,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: t.jenisTransaksi == 'pemasukan'
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          t.kategori,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: t.jenisTransaksi == 'pemasukan'
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(t.tanggal),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  secondary: Text(
                                    currency.format(t.total),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: t.jenisTransaksi == 'pemasukan' ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: t.jenisTransaksi == 'pemasukan'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    t.jenisTransaksi == 'pemasukan'
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    color: t.jenisTransaksi == 'pemasukan' ? Colors.green : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  t.deskripsi,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: t.jenisTransaksi == 'pemasukan'
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        t.kategori,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: t.jenisTransaksi == 'pemasukan'
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(t.tanggal),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                                    Text(
                                      currency.format(t.total),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: t.jenisTransaksi == 'pemasukan' ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                        IconButton(
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                          onPressed: () => _editItem(t),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                        ),
                      ],
                                ),
                                isThreeLine: false,
                    ),
                  );
                },
              ),
                      ),
          ],
        ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currency.format(amount),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


