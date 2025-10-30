import 'dart:convert';
import '../models/transaction.dart';
import 'parser.dart';

abstract class AiService {
  Future<List<MoneyTransaction>> parseToTransactions(String text);
}

class LocalHeuristicAiService implements AiService {
  @override
  Future<List<MoneyTransaction>> parseToTransactions(String text) async {
    final maps = MoneyMindParser.parse(text);
    return maps
        .map((m) => MoneyTransaction.fromMap(m))
        .toList(growable: false);
  }
}

// Gemini implementation removed (we no longer use Gemini here).


