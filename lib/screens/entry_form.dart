import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/storage.dart';

class EntryFormScreen extends StatefulWidget {
  final StorageService storage;
  const EntryFormScreen({super.key, required this.storage});

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _jenis = 'pengeluaran';
  final TextEditingController _kategori = TextEditingController();
  final TextEditingController _deskripsi = TextEditingController();
  final TextEditingController _total = TextEditingController();
  DateTime _tanggal = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tanggal = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final int amount = int.tryParse(_total.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final item = MoneyTransaction(
      jenisTransaksi: _jenis,
      kategori: _kategori.text.trim().isEmpty ? 'lainnya' : _kategori.text.trim(),
      tanggal: _tanggal,
      deskripsi: _deskripsi.text.trim(),
      total: amount,
    );
    await widget.storage.upsertTransactions([item]);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi disimpan')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'pengeluaran', label: Text('Pengeluaran')),
                    ButtonSegment(value: 'pemasukan', label: Text('Pemasukan')),
                  ],
                  selected: {_jenis},
                  onSelectionChanged: (s) => setState(() => _jenis = s.first),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _kategori,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Isi kategori' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _deskripsi,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _total,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah (Rp)',
                    hintText: 'cth: 50000',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) {
                    final num = int.tryParse((v ?? '').replaceAll(RegExp(r'[^0-9]'), ''));
                    if (num == null || num <= 0) return 'Masukkan jumlah yang valid';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.date_range),
                        label: Text('${_tanggal.year}-${_tanggal.month.toString().padLeft(2, '0')}-${_tanggal.day.toString().padLeft(2, '0')}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


