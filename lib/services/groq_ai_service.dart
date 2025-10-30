import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import 'ai_service.dart';
import '../secrets.dart';

class GroqAiService implements AiService {
  final http.Client _client;

  GroqAiService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<MoneyTransaction>> parseToTransactions(String text) async {
    if (kGroqApiKey.isEmpty) {
      return _fallback(text);
    }
    final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final resp = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $kGroqApiKey',
      },
      body: json.encode({
        'model': 'llama-3.1-8b-instant',
        'messages': [
          {
            'role': 'system',
            'content': 'Anda adalah asisten yang mengembalikan JSON valid (tanpa markdown) sesuai instruksi.'
          },
          {
            'role': 'user',
            'content': _buildPrompt(text),
          }
        ],
        'temperature': 0.1,
      }),
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Groq error ${resp.statusCode}: ${resp.body}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final List choices = (data['choices'] as List?) ?? const [];
    final String content = choices.isNotEmpty
        ? ((choices.first as Map)['message'] as Map)['content'] as String? ?? ''
        : '';

    final jsonStr = _extractJson(content);
    final decoded = json.decode(jsonStr);
    final List list = decoded is List ? decoded : [decoded];
    return list
        .map((m) => MoneyTransaction.fromMap(Map<String, dynamic>.from(m as Map)))
        .toList(growable: false);
  }

  List<MoneyTransaction> _fallback(String text) {
    // Minimal fallback: treat as a single expense with zero if no amount.
    final now = DateTime.now();
    final date = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return [
      MoneyTransaction.fromMap({
        'jenis_transaksi': 'pengeluaran',
        'kategori': 'lainnya',
        'tanggal': date,
        'deskripsi': text,
        'total': 0,
      })
    ];
  }

  String _buildPrompt(String text) {
    return '''Konversi teks berikut menjadi array JSON transaksi TANPA pembungkus markdown.
Persyaratan:
- Output HARUS JSON valid (array of objects) saja, tanpa penjelasan.
- Field wajib per item: jenis_transaksi ("pengeluaran"|"pemasukan"), kategori, tanggal (YYYY-MM-DD), deskripsi, total (integer rupiah, tanpa simbol).
- Pahami singkatan Indonesia: "rb"/"ribu"/"k"=×1000; "jt"/"juta"/"m"=×1_000_000. Contoh: 10rb=>10000, 1,2jt=>1200000.
- Jika tanggal tidak ada, gunakan tanggal hari ini.
- Jika ada beberapa item, buat beberapa objek terpisah.

Contoh output yang benar:
[
  {"jenis_transaksi":"pengeluaran","kategori":"makanan","tanggal":"2025-10-30","deskripsi":"bakso","total":10000}
]

Teks:
$text''';
  }

  String _extractJson(String s) {
    final match = RegExp(r'```json\s*([\s\S]*?)```').firstMatch(s);
    if (match != null) return match.group(1)!.trim();
    // If the model returned plain JSON without code fences
    final trimmed = s.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) return trimmed;
    // As last resort, wrap into array
    return '[]';
  }
}


