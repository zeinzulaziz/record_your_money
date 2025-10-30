import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/transaction_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String _selectedFilter = 'semua';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Transaction> transactions = await StorageService.getTransactions();
      transactions.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error loading transactions: $e');
    }
  }

  List<Transaction> _getFilteredTransactions() {
    if (_selectedFilter == 'semua') {
      return _transactions;
    }
    return _transactions.where((t) => t.jenisTransaksi == _selectedFilter).toList();
  }

  Future<void> _deleteTransaction(int index) async {
    List<Transaction> filteredTransactions = _getFilteredTransactions();
    Transaction transactionToDelete = filteredTransactions[index];
    int actualIndex = _transactions.indexOf(transactionToDelete);
    
    if (actualIndex != -1) {
      await StorageService.deleteTransaction(actualIndex);
      await _loadTransactions();
      _showSnackBar('Transaksi berhasil dihapus');
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

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Transaksi'),
        content: Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTransaction(index);
            },
            child: Text('Hapus', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Riwayat Transaksi'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'semua',
                child: Text('Semua'),
              ),
              PopupMenuItem(
                value: 'pemasukan',
                child: Text('Pemasukan'),
              ),
              PopupMenuItem(
                value: 'pengeluaran',
                child: Text('Pengeluaran'),
              ),
            ],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada transaksi',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Mulai catat transaksi Anda',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Filter Info
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Icon(Icons.filter_list, size: 20, color: AppTheme.primaryColor),
                          SizedBox(width: 8),
                          Text(
                            'Filter: ${_selectedFilter == 'semua' ? 'Semua' : _selectedFilter == 'pemasukan' ? 'Pemasukan' : 'Pengeluaran'}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '${_getFilteredTransactions().length} transaksi',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Transactions List
                    Expanded(
                      child: ListView.builder(
                        itemCount: _getFilteredTransactions().length,
                        itemBuilder: (context, index) {
                          Transaction transaction = _getFilteredTransactions()[index];
                          return TransactionCard(
                            transaction: transaction,
                            onDelete: () => _showDeleteConfirmation(index),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
