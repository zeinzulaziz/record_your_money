class Transaction {
  final String jenisTransaksi;
  final String kategori;
  final DateTime tanggal;
  final String deskripsi;
  final double total;

  Transaction({
    required this.jenisTransaksi,
    required this.kategori,
    required this.tanggal,
    required this.deskripsi,
    required this.total,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      jenisTransaksi: json['jenis_transaksi'] ?? '',
      kategori: json['kategori'] ?? '',
      tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
      deskripsi: json['deskripsi'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jenis_transaksi': jenisTransaksi,
      'kategori': kategori,
      'tanggal': tanggal.toIso8601String(),
      'deskripsi': deskripsi,
      'total': total,
    };
  }

  Transaction copyWith({
    String? jenisTransaksi,
    String? kategori,
    DateTime? tanggal,
    String? deskripsi,
    double? total,
  }) {
    return Transaction(
      jenisTransaksi: jenisTransaksi ?? this.jenisTransaksi,
      kategori: kategori ?? this.kategori,
      tanggal: tanggal ?? this.tanggal,
      deskripsi: deskripsi ?? this.deskripsi,
      total: total ?? this.total,
    );
  }
}
