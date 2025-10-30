import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class StorageService {
  static const String _transactionsKey = 'transactions';
  
  static Future<List<Transaction>> getTransactions() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? transactionsJson = prefs.getString(_transactionsKey);
      
      if (transactionsJson == null) {
        return [];
      }
      
      List<dynamic> transactionsList = json.decode(transactionsJson);
      return transactionsList.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  static Future<void> saveTransaction(Transaction transaction) async {
    try {
      List<Transaction> transactions = await getTransactions();
      transactions.add(transaction);
      await _saveTransactions(transactions);
    } catch (e) {
      throw Exception('Error saving transaction: $e');
    }
  }
  
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    try {
      List<Transaction> existingTransactions = await getTransactions();
      existingTransactions.addAll(transactions);
      await _saveTransactions(existingTransactions);
    } catch (e) {
      throw Exception('Error saving transactions: $e');
    }
  }
  
  static Future<void> deleteTransaction(int index) async {
    try {
      List<Transaction> transactions = await getTransactions();
      if (index >= 0 && index < transactions.length) {
        transactions.removeAt(index);
        await _saveTransactions(transactions);
      }
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }
  
  static Future<void> _saveTransactions(List<Transaction> transactions) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> transactionsJson = 
        transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_transactionsKey, json.encode(transactionsJson));
  }
  
  static Future<void> clearAllTransactions() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_transactionsKey);
    } catch (e) {
      throw Exception('Error clearing transactions: $e');
    }
  }
}
