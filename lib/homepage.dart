import 'package:flutter/material.dart';
import 'services/ai_service.dart';
import 'services/groq_ai_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/storage.dart';
import 'services/supabase_storage.dart';
import 'services/ocr_service.dart';
import 'services/stt_service.dart';
import 'screens/dashboard.dart';
class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _controller = TextEditingController();
  final AiService _ai = GroqAiService();
  final StorageService _storage = SupabaseStorage();
  final OcrService _ocr = OcrService();
  final SpeechToTextService _stt = SpeechToTextService();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _storage.init();
  }

  

  Future<void> _parseWithAiAndSave() async {
    setState(() => _busy = true);
    try {
      final items = await _ai.parseToTransactions(_controller.text);
      if (items.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada transaksi terdeteksi')),
          );
        }
        return;
      }
      await _storage.upsertTransactions(items);
      debugPrint('Saved transactions: ${items.map((e) => e.toMap()).toList()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tersimpan: ${items.length} transaksi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _scanOcr() async {
    setState(() => _busy = true);
    try {
      final text = await _ocr.scanFromCamera();
      if (text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada teks terdeteksi dari kamera')),
          );
        }
        return;
      }
      setState(() {
        _controller.text = text;
      });
      await _parseWithAiAndSave();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickOcrFromGallery() async {
    setState(() => _busy = true);
    try {
      final text = await _ocr.pickFromGallery();
      if (text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada teks terdeteksi dari galeri')),
          );
        }
        return;
      }
      setState(() {
        _controller.text = text;
      });
      await _parseWithAiAndSave();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recordStt() async {
    setState(() => _busy = true);
    try {
      final text = await _stt.recordAndTranscribe();
      if (text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada ucapan terdeteksi / izin diblokir')),
          );
        }
        return;
      }
      setState(() {
        _controller.text = text;
      });
      await _parseWithAiAndSave();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _testGemini() async {
    setState(() => _busy = true);
    try {
      const sample = 'Toko Sinar, 24 Okt 2025, Gula Rp20.000, Kopi Rp30.000, Total Rp50.000';
      final items = await _ai.parseToTransactions(sample);
      debugPrint('Gemini test -> ${items.map((e) => e.toMap()).toList()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gemini OK: ${items.length} transaksi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gemini error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyMind'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
          IconButton(
            tooltip: 'Test AI',
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: _busy ? null : _testGemini,
          ),
          IconButton(
            tooltip: 'Rekap',
            icon: const Icon(Icons.bar_chart),
            onPressed: () async {
              final list = await _storage.getAll();
              if (!mounted) return;
              // Buka layar rekap
              // ignore: use_build_context_synchronously
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DashboardScreen(items: list),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_busy) const LinearProgressIndicator(),
            if (_busy) const SizedBox(height: 12),
            Text(
              'Catat keuangan tanpa input manual',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Tempel hasil OCR atau ucapan di sini...\nContoh: Toko Sinar, 24 Okt 2025, Gula Rp20.000, Kopi Rp30.000, Total Rp50.000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : _scanOcr,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scan Nota (OCR)'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _pickOcrFromGallery,
                  icon: const Icon(Icons.photo),
                  label: const Text('Pilih Gambar (OCR)'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _recordStt,
                  icon: const Icon(Icons.mic),
                  label: const Text('Rekam Ucapan (STT)'),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _busy ? null : _parseWithAiAndSave,
                child: const Text('Proses dengan AI'),
              ),
            ),
          ],
        ),
      ),
      // Tidak ada input manual; semua dari OCR/STT
    );
  }
}
