import 'dart:convert';

class MoneyMindParser {
  static final RegExp _moneyRegex = RegExp(
      r"(Rp\s*)?([0-9\.\,]+)\s*(rb|ribu|k|jt|juta|m)?",
      caseSensitive: false);
  static final RegExp _dateIso = RegExp(r"(\d{4})[-/](\d{1,2})[-/](\d{1,2})");
  static final RegExp _dateId = RegExp(
      r"(\d{1,2})\s*(Jan|Feb|Mar|Apr|Mei|Jun|Jul|Agu|Sep|Okt|Nov|Des)\s*(\d{4})",
      caseSensitive: false);

  static final Map<String, int> _idMonth = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'mei': 5,
    'jun': 6,
    'jul': 7,
    'agu': 8,
    'sep': 9,
    'okt': 10,
    'nov': 11,
    'des': 12,
  };

  static String _todayIso() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  static String _detectDate(String input) {
    final m1 = _dateIso.firstMatch(input);
    if (m1 != null) {
      final y = int.parse(m1.group(1)!);
      final mo = int.parse(m1.group(2)!);
      final d = int.parse(m1.group(3)!);
      return "${y.toString().padLeft(4, '0')}-${mo.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}";
    }
    final m2 = _dateId.firstMatch(input);
    if (m2 != null) {
      final d = int.parse(m2.group(1)!);
      final monStr = m2.group(2)!.toLowerCase();
      final y = int.parse(m2.group(3)!);
      final mon = _idMonth[monStr] ?? DateTime.now().month;
      return "${y.toString().padLeft(4, '0')}-${mon.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}";
    }
    return _todayIso();
  }

  static String _detectJenis(String input) {
    final s = input.toLowerCase();
    if (s.contains('dapat') || s.contains('jual') || s.contains('transfer masuk') || s.contains('pendapatan') || s.contains('gaji')) {
      return 'pemasukan';
    }
    if (s.contains('beli') || s.contains('bayar') || s.contains('makan') || s.contains('biaya') || s.contains('tagihan')) {
      return 'pengeluaran';
    }
    return 'pengeluaran';
  }

  static String _detectKategori(String input, String jenis) {
    final s = input.toLowerCase();
    if (jenis == 'pemasukan') {
      if (s.contains('gaji')) return 'gaji';
      if (s.contains('klien') || s.contains('proyek') || s.contains('invoice')) return 'proyek';
      return 'lainnya';
    }
    // pengeluaran
    if (s.contains('bensin') || s.contains('grab') || s.contains('gojek') || s.contains('transport')) return 'transportasi';
    if (s.contains('makan') || s.contains('kopi') || s.contains('gula') || s.contains('resto') || s.contains('warung')) return 'makanan';
    if (s.contains('listrik') || s.contains('air') || s.contains('pulsa') || s.contains('internet')) return 'utilitas';
    return 'lainnya';
  }

  static int _parseMoneyToInt(String raw, [String? suffix]) {
    String digitsOnly = raw.replaceAll(RegExp(r"[^0-9\,\.]"), '');
    if (digitsOnly.isEmpty) return 0;
    // Normalize decimal comma to dot for parsing fractional multipliers (e.g., 1,2jt)
    digitsOnly = digitsOnly.replaceAll('.', '').replaceAll(',', '.');
    double base = double.tryParse(digitsOnly) ?? 0;
    int multiplier = 1;
    final sfx = (suffix ?? '').toLowerCase();
    if (sfx == 'rb' || sfx == 'ribu' || sfx == 'k') multiplier = 1000;
    if (sfx == 'jt' || sfx == 'juta' || sfx == 'm') multiplier = 1000000;
    final value = (base * multiplier).round();
    return value;
  }

  static List<Map<String, dynamic>> parse(String inputRaw) {
    final input = inputRaw.trim();
    if (input.isEmpty) return [];

    final date = _detectDate(input);
    final jenis = _detectJenis(input);
    final kategori = _detectKategori(input, jenis);

    // Heuristic: split by commas/newlines for potential items
    final parts = input.split(RegExp(r"[\n\r]+|,\s*(?=[A-ZÀ-ÿa-z])"));
    final List<Map<String, dynamic>> items = [];

    for (final part in parts) {
      final match = _moneyRegex.firstMatch(part);
      if (match != null) {
        final amount = _parseMoneyToInt(match.group(2)!, match.group(3));
        final desc = part.replaceFirst(match.group(0)!, '').trim();
        items.add({
          'jenis_transaksi': jenis,
          'kategori': _detectKategori(part, jenis),
          'tanggal': date,
          'deskripsi': desc.isEmpty ? input : desc,
          'total': amount,
        });
      }
    }

    if (items.isNotEmpty) return items;

    // fallback: single-line without explicit amount per item, try any money in input
    final allMoney = _moneyRegex.allMatches(input).toList();
    final total = allMoney.isNotEmpty
        ? _parseMoneyToInt(allMoney.last.group(2)!, allMoney.last.group(3))
        : 0;
    return [
      {
        'jenis_transaksi': jenis,
        'kategori': kategori,
        'tanggal': date,
        'deskripsi': input,
        'total': total,
      }
    ];
  }

  static String toPrettyJson(List<Map<String, dynamic>> data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}


