import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/ai_parser_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/loading_overlay.dart';
import 'history_screen.dart';
import '../widgets/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  List<Transaction> _recentTransactions = [];
  double _totalBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Transaction> transactions = await StorageService.getTransactions();
    setState(() {
      _recentTransactions = transactions.take(3).toList();
      _totalBalance = _calculateBalance(transactions);
    });
  }

  double _calculateBalance(List<Transaction> transactions) {
    double balance = 0;
    for (Transaction transaction in transactions) {
      if (transaction.jenisTransaksi == 'pemasukan') {
        balance += transaction.total;
      } else {
        balance -= transaction.total;
      }
    }
    return balance;
  }

  Future<void> _parseAndSaveTransaction() async {
    if (_textController.text.trim().isEmpty) {
      _showSnackBar('Masukkan teks transaksi terlebih dahulu');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<Transaction> transactions = await AIParserService.parseTextToTransactions(_textController.text);
      
      if (transactions.isNotEmpty) {
        await StorageService.saveTransactions(transactions);
        _textController.clear();
        await _loadData();
        _showSnackBar('Transaksi berhasil disimpan!');
      } else {
        _showSnackBar('Tidak dapat mendeteksi transaksi dari teks tersebut');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red, // Warna merah untuk debugging
      appBar: AppBar(
        title: Text('Record Your Money'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Home Screen Berjalan!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Saldo: Rp ${NumberFormat('#,###').format(_totalBalance)}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _parseAndSaveTransaction,
              child: Text('Test Button'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
