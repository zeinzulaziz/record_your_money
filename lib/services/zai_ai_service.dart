import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import 'ai_service.dart';
import 'parser.dart';
import '../secrets.dart';

/// WARNING: Calling provider APIs directly from mobile apps exposes your API key.
/// Proceed only if you accept that risk.
class ZaiAiService implements AiService {
  final http.Client _client;

  ZaiAiService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<MoneyTransaction>> parseToTransactions(String text) async {
    if (kZaiApiKey.isEmpty) {
      // Fall back to local heuristic when no key
      final maps = MoneyMindParser.parse(text);
      return maps.map((m) => MoneyTransaction.fromMap(m)).toList(growable: false);
    }

    final uri = Uri.parse('https://api.z.ai/v1/chat/completions');
    final resp = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $kZaiApiKey',
      },
      body: json.encode({
        'model': 'zai-lite',
        'messages': [
          {
            'role': 'user',
            'content': _buildPrompt(text),
          }
        ],
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('z.ai error ${resp.statusCode}: ${resp.body}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final choices = data['choices'] as List?;
    final content = choices != null && choices.isNotEmpty
        ? (choices.first as Map)['message']['content'] as String
        : '';

    final maps = MoneyMindParser.parse(content.isNotEmpty ? content : text);
    return maps.map((m) => MoneyTransaction.fromMap(m)).toList(growable: false);
  }

  String _buildPrompt(String text) {
    return '''Ubah teks bebas berikut menjadi JSON transaksi.
Format keluaran: array JSON dengan field:
{
  "jenis_transaksi": "pengeluaran" atau "pemasukan",
  "kategori": "kategori kontekstual",
  "tanggal": "YYYY-MM-DD",
  "deskripsi": "ringkas",
  "total": angka tanpa simbol
}
Jika beberapa item, output sebagai array beberapa objek.
Teks: ```\n$text\n```''';
  }
}


