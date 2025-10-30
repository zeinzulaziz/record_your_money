import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import 'ai_service.dart';
import 'parser.dart';

class ProxyAiService implements AiService {
  final String baseUrl;
  final http.Client _client;

  ProxyAiService({required this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<MoneyTransaction>> parseToTransactions(String text) async {
    final uri = Uri.parse('$baseUrl/api/generate');
    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: json.encode({'prompt': text}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Proxy error ${response.statusCode}: ${response.body}');
    }

    final decoded = json.decode(response.body);
    // Backend may return either { result: string } or a structured list
    if (decoded is Map && decoded['result'] is String) {
      final resultText = decoded['result'] as String;
      final maps = MoneyMindParser.parse(resultText);
      return maps.map((m) => MoneyTransaction.fromMap(m)).toList(growable: false);
    }
    if (decoded is List) {
      return decoded
          .map((m) => MoneyTransaction.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList(growable: false);
    }
    if (decoded is Map && decoded['items'] is List) {
      final List items = decoded['items'] as List;
      return items
          .map((m) => MoneyTransaction.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList(growable: false);
    }
    throw Exception('Unexpected proxy response: ${response.body}');
  }
}


