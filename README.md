# Record Your Money

Aplikasi pencatatan keuangan yang menggunakan AI untuk mengubah teks bebas menjadi data transaksi terstruktur.

## Fitur

- **AI Text Parser**: Mengubah teks bebas (hasil scan nota atau ucapan) menjadi data transaksi terstruktur
- **Kategori Otomatis**: Mendeteksi kategori transaksi berdasarkan konteks
- **Riwayat Transaksi**: Melihat semua transaksi dengan filter
- **Saldo Real-time**: Menampilkan saldo berdasarkan pemasukan dan pengeluaran
- **UI/UX Elegan**: Desain yang simpel dan mudah digunakan

## Cara Penggunaan

1. **Input Teks Transaksi**: Masukkan teks transaksi di halaman utama
   - Contoh: "Beli bensin 50 ribu"
   - Contoh: "Dapat gaji 5 juta dari kantor"
   - Contoh: "Toko Sinar, 24 Okt 2025, Gula Rp20.000, Kopi Rp30.000, Total Rp50.000"

2. **Proses Otomatis**: Aplikasi akan mendeteksi:
   - Jenis transaksi (pemasukan/pengeluaran)
   - Kategori (makanan, transportasi, dll)
   - Tanggal
   - Jumlah uang

3. **Simpan**: Transaksi akan disimpan dan saldo akan terupdate

## Instalasi

1. Pastikan Flutter sudah terinstall
2. Clone repository ini
3. Jalankan `flutter pub get`
4. Jalankan `flutter run`

## Dependencies

- `http`: Untuk komunikasi dengan API
- `shared_preferences`: Untuk penyimpanan lokal
- `intl`: Untuk format tanggal dan angka
- `google_fonts`: Untuk font Poppins
- `flutter_svg`: Untuk ikon SVG

## Struktur Project

```
lib/
├── models/
│   └── transaction.dart
├── services/
│   ├── ai_parser_service.dart
│   └── storage_service.dart
├── screens/
│   ├── home_screen.dart
│   └── history_screen.dart
├── widgets/
│   ├── transaction_card.dart
│   └── loading_overlay.dart
├── utils/
│   └── app_theme.dart
└── main.dart
```

## AI Parser Logic

Aplikasi menggunakan logika parsing sederhana berdasarkan kata kunci:

- **Jenis Transaksi**:
  - Pengeluaran: "beli", "bayar", "makan", "bensin", dll
  - Pemasukan: "dapat", "jual", "transfer masuk", "gaji", dll

- **Kategori**:
  - Makanan: "makan", "minum", "restoran", "kopi", dll
  - Transportasi: "bensin", "parkir", "tol", "grab", dll
  - Belanja: "belanja", "toko", "supermarket", dll

- **Jumlah**: Mendeteksi angka dengan format "Rp", "ribu", "juta"

## Kontribusi

Silakan buat issue atau pull request untuk perbaikan dan fitur baru.

## Lisensi

MIT License
