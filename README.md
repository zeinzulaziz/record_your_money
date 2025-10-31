# Record Your Money

A Flutter application for recording and managing your financial transactions using voice input, image recognition, and AI-powered text parsing.

## Features

- 💬 **Voice Input**: Record transactions using speech-to-text
- 📷 **Image Recognition**: Extract transaction details from receipts/photos using OCR
- 🤖 **AI-Powered Parsing**: Automatically extract and categorize transaction information using AI
- 💾 **Local Storage**: Store transactions locally using SQLite
- 📊 **Dashboard**: View and manage your transaction history

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/zeinzulaziz/record_your_money.git
cd record_your_money
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure API keys:
   - Create a file `lib/secrets.dart` with your API keys:
   ```dart
   const String kGroqApiKey = 'YOUR_GROQ_API_KEY_HERE';
   ```
   - Get your Groq API key from: https://console.groq.com/

4. Run the app:
```bash
flutter run
```

### Deploy to Web

Aplikasi ini juga mendukung web platform. Untuk deploy ke web:

1. Build aplikasi untuk web:
```bash
flutter build web --release
```

2. Lihat file `DEPLOY_WEB.md` untuk panduan deploy ke berbagai platform:
   - Firebase Hosting
   - Netlify
   - Vercel
   - GitHub Pages

**Catatan:** Beberapa fitur mobile (OCR dan Speech-to-Text) tidak tersedia di web, tapi dashboard dan AI parsing tetap berfungsi.

## Technologies Used

- **Flutter**: Cross-platform mobile development framework
- **SQLite**: Local database for storing transactions
- **Google ML Kit**: Text recognition from images
- **Speech to Text**: Voice input processing
- **Google Generative AI**: AI-powered text parsing
- **Groq AI**: Alternative AI service for text processing

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── homepage.dart            # Main homepage
├── models/                  # Data models
│   └── transaction.dart
├── screens/                 # App screens
│   ├── dashboard.dart
│   └── entry_form.dart
├── services/                # Business logic services
│   ├── ai_parser_service.dart
│   ├── ai_service.dart
│   ├── groq_ai_service.dart
│   ├── ocr_service.dart
│   ├── storage_service.dart
│   ├── stt_service.dart
│   └── zai_ai_service.dart
├── utils/                   # Utility files
│   └── app_theme.dart
└── widgets/                 # Reusable widgets
    ├── loading_overlay.dart
    └── transaction_card.dart
```

## API Keys Setup

This project requires API keys for:
- **Groq AI**: For AI-powered text parsing
- **Google ML Kit**: For OCR capabilities

Make sure to add your keys in `lib/secrets.dart` file before running the app.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.
