import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<String> recordAndTranscribe() async {
    try {
      // Ensure any previous session is stopped/cancelled
      try {
        await _speech.stop();
      } catch (_) {}
      try {
        await _speech.cancel();
      } catch (_) {}

      final available = await _speech.initialize();
      if (!available) return '';
      final buffer = StringBuffer();
      await _speech.listen(
        onResult: (res) {
          if (res.recognizedWords.isNotEmpty) {
            buffer
              ..clear()
              ..write(res.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 1),
        partialResults: false,
        localeId: 'id_ID',
      );
      await Future.delayed(const Duration(seconds: 6));
      await _speech.stop();
      return buffer.toString();
    } catch (e) {
      return '';
    }
  }
}


