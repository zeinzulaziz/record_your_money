import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class AIParserService {
  // Simulasi AI parsing - dalam implementasi nyata bisa menggunakan OpenAI API atau service AI lainnya
  static Future<List<Transaction>> parseTextToTransactions(String inputText) async {
    try {
      // Simulasi delay untuk menunjukkan proses AI
      await Future.delayed(Duration(seconds: 1));
      
      // Logika parsing sederhana berdasarkan kata kunci
      List<Transaction> transactions = [];
      
      // Deteksi jenis transaksi
      String jenisTransaksi = _detectTransactionType(inputText);
      
      // Deteksi kategori
      String kategori = _detectCategory(inputText);
      
      // Deteksi tanggal
      DateTime tanggal = _detectDate(inputText);
      
      // Deteksi jumlah
      double total = _detectAmount(inputText);
      
      // Buat transaksi
      if (total > 0) {
        transactions.add(Transaction(
          jenisTransaksi: jenisTransaksi,
          kategori: kategori,
          tanggal: tanggal,
          deskripsi: _generateDescription(inputText),
          total: total,
        ));
      }
      
      return transactions;
    } catch (e) {
      throw Exception('Error parsing text: $e');
    }
  }
  
  static String _detectTransactionType(String text) {
    String lowerText = text.toLowerCase();
    
    // Kata kunci untuk pengeluaran
    List<String> pengeluaranKeywords = [
      'beli', 'bayar', 'makan', 'minum', 'bensin', 'parkir', 
      'tol', 'ongkos', 'harga', 'total', 'bayar', 'pembelian',
      'makanan', 'minuman', 'transport', 'belanja'
    ];
    
    // Kata kunci untuk pemasukan
    List<String> pemasukanKeywords = [
      'dapat', 'jual', 'transfer masuk', 'gaji', 'bonus', 
      'penjualan', 'pendapatan', 'masuk', 'terima'
    ];
    
    for (String keyword in pengeluaranKeywords) {
      if (lowerText.contains(keyword)) {
        return 'pengeluaran';
      }
    }
    
    for (String keyword in pemasukanKeywords) {
      if (lowerText.contains(keyword)) {
        return 'pemasukan';
      }
    }
    
    // Default ke pengeluaran jika tidak jelas
    return 'pengeluaran';
  }
  
  static String _detectCategory(String text) {
    String lowerText = text.toLowerCase();
    
    // Mapping kategori berdasarkan kata kunci
    Map<String, List<String>> categoryMap = {
      'makanan': ['makan', 'minum', 'restoran', 'warung', 'kafe', 'kopi', 'gula'],
      'transportasi': ['bensin', 'parkir', 'tol', 'ongkos', 'transport', 'grab', 'gojek'],
      'belanja': ['belanja', 'toko', 'supermarket', 'mall', 'shopping'],
      'kesehatan': ['obat', 'dokter', 'rumah sakit', 'apotek', 'kesehatan'],
      'hiburan': ['film', 'game', 'hiburan', 'entertainment'],
      'pendidikan': ['sekolah', 'kursus', 'buku', 'pendidikan'],
      'gaji': ['gaji', 'salary', 'pendapatan'],
      'proyek': ['proyek', 'klien', 'freelance', 'kerja'],
    };
    
    for (String category in categoryMap.keys) {
      for (String keyword in categoryMap[category]!) {
        if (lowerText.contains(keyword)) {
          return category;
        }
      }
    }
    
    return 'lainnya';
  }
  
  static DateTime _detectDate(String text) {
    // Deteksi tanggal dari teks (implementasi sederhana)
    RegExp datePattern = RegExp(r'(\d{1,2})\s*(jan|feb|mar|apr|mei|jun|jul|agu|sep|okt|nov|des)\s*(\d{4})', caseSensitive: false);
    Match? match = datePattern.firstMatch(text);
    
    if (match != null) {
      int day = int.parse(match.group(1)!);
      String monthStr = match.group(2)!.toLowerCase();
      int year = int.parse(match.group(3)!);
      
      Map<String, int> months = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'mei': 5, 'jun': 6,
        'jul': 7, 'agu': 8, 'sep': 9, 'okt': 10, 'nov': 11, 'des': 12
      };
      
      int month = months[monthStr] ?? DateTime.now().month;
      return DateTime(year, month, day);
    }
    
    // Jika tidak ada tanggal yang terdeteksi, gunakan tanggal hari ini
    return DateTime.now();
  }
  
  static double _detectAmount(String text) {
    // Deteksi jumlah uang dari teks
    RegExp amountPattern = RegExp(r'rp\s*([0-9.,]+)|([0-9.,]+)\s*rp|([0-9.,]+)\s*ribu|([0-9.,]+)\s*juta', caseSensitive: false);
    Match? match = amountPattern.firstMatch(text);
    
    if (match != null) {
      String amountStr = '';
      
      // Ambil group yang tidak null
      for (int i = 1; i <= match.groupCount; i++) {
        if (match.group(i) != null) {
          amountStr = match.group(i)!;
          break;
        }
      }
      
      // Bersihkan string dan konversi ke double
      amountStr = amountStr.replaceAll(',', '').replaceAll('.', '');
      double amount = double.tryParse(amountStr) ?? 0;
      
      // Jika ada kata "ribu", kalikan dengan 1000
      if (text.toLowerCase().contains('ribu')) {
        amount *= 1000;
      }
      
      // Jika ada kata "juta", kalikan dengan 1000000
      if (text.toLowerCase().contains('juta')) {
        amount *= 1000000;
      }
      
      return amount;
    }
    
    return 0;
  }
  
  static String _generateDescription(String text) {
    // Buat deskripsi singkat dari teks input
    if (text.length > 50) {
      return text.substring(0, 47) + '...';
    }
    return text;
  }
}
