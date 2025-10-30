import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final ImagePicker _picker = ImagePicker();

  Future<String> scanFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.camera);
      if (file == null) return '';
      final inputImage = InputImage.fromFilePath(file.path);
      final textRecognizer = TextRecognizer();
      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        return recognizedText.text;
      } finally {
        textRecognizer.close();
      }
    } catch (e) {
      return '';
    }
  }

  Future<String> pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return '';
      final inputImage = InputImage.fromFilePath(file.path);
      final textRecognizer = TextRecognizer();
      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        return recognizedText.text;
      } finally {
        textRecognizer.close();
      }
    } catch (e) {
      return '';
    }
  }
}


