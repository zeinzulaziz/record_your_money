class MoneyTransaction {
  final int? id;
  final String jenisTransaksi; // 'pengeluaran' | 'pemasukan'
  final String kategori;
  final DateTime tanggal;
  final String deskripsi;
  final int total; // in smallest unit (IDR integer)

  MoneyTransaction({
    this.id,
    required this.jenisTransaksi,
    required this.kategori,
    required this.tanggal,
    required this.deskripsi,
    required this.total,
  });

  factory MoneyTransaction.fromMap(Map<String, dynamic> map) {
    return MoneyTransaction(
      id: map['id'] as int?,
      jenisTransaksi: map['jenis_transaksi'] as String,
      kategori: map['kategori'] as String,
      tanggal: DateTime.parse(map['tanggal'] as String),
      deskripsi: map['deskripsi'] as String,
      total: (map['total'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'jenis_transaksi': jenisTransaksi,
      'kategori': kategori,
      'tanggal': _isoDate(tanggal),
      'deskripsi': deskripsi,
      'total': total,
    };
  }

  static String _isoDate(DateTime d) {
    return "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }
}


