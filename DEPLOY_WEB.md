# Panduan Deploy Aplikasi ke Web

Project ini sudah berhasil di-build untuk web. File build sudah ada di `build/web`.

## Quick Start - Deploy dengan Netlify Drop (Paling Mudah!)

Jika Anda ingin deploy **cepat tanpa setup apapun**:

1. Kunjungi: https://app.netlify.com/drop
2. Drag & drop folder `build/web` ke halaman tersebut
3. Dapatkan URL langsung: `https://random-name.netlify.app`

**Selesai!** Aplikasi Anda sudah online dan bisa diakses lewat URL tersebut.

---

## Perbandingan Platform

| Platform | Auto-Deploy | Kesulitan | Bandwidth | Fitur |
|----------|-------------|-----------|-----------|-------|
| **Netlify** | ✅ Built-in | ⭐ Mudah | Unlimited | CDN, Forms, Functions |
| **Firebase** | ✅ + CI/CD | ⭐⭐ Medium | Pay-as-go | Database, Auth, Functions |
| **Vercel** | ✅ Built-in | ⭐ Mudah | Unlimited | Edge Functions, Analytics |
| **GitHub Pages** | ⚠️ via Actions | ⭐⭐⭐ Sulit | 100 GB/bulan | Custom domain |

**Rekomendasi:** 
- 🥇 **Netlify** - Untuk kemudahan & fitur lengkap (bisa auto-deploy)
- 🥈 **GitHub Pages** - Jika sudah pakai GitHub & ingin gratis (perlu setup Actions dulu)
- 🥉 **Firebase** - Jika perlu fitur backend database & auth

**Untuk GitHub Pages khususnya:**
- ✅ Sudah punya GitHub repo: Sangat cocok!
- ✅ File `.github/workflows/deploy.yml` sudah disiapkan
- ⚠️ Perlu setup GitHub Actions di Settings → Pages
- ⚠️ Bandwidth limited 100GB/bulan (cukup untuk traffic normal)
- ✅ URL: `https://zeinzulaziz.github.io/record_your_money/`

---

## Cara Deploy Permanen

Jika Anda ingin deploy dengan URL custom dan domain sendiri:

### Opsi 1: Netlify (Mudah & Gratis)

**Via Web (Drag & Drop):**
1. Kunjungi: https://app.netlify.com/drop
2. Drag folder `build/web` ke halaman
3. Dapatkan URL langsung!

**Via Netlify CLI:**
1. Install: `npm install -g netlify-cli`
2. Login: `netlify login`
3. Deploy: 
```bash
flutter build web --release
netlify deploy --prod --dir=build/web
```

**Via Git (Auto Deploy):**
1. Push code ke GitHub
2. Login ke Netlify dan pilih "New site from Git"
3. Pilih repo dan deploy
4. Setiap push ke main akan auto deploy!

### Opsi 2: Firebase Hosting (Baik untuk Production)

1. **Install Firebase CLI:**
```bash
npm install -g firebase-tools
```

2. **Login ke Firebase:**
```bash
firebase login
```

3. **Inisialisasi Firebase di project:**
```bash
firebase init
```
Pilih:
- Hosting
- Use an existing project (atau create new project)
- Public directory: `build/web`
- Single-page app: **Yes**
- Overwrite index.html: **No**

4. **Deploy:**
```bash
flutter build web --release
firebase deploy --only hosting
```

5. **Akses aplikasi:**
URL akan tersedia di: `https://YOUR-PROJECT-ID.web.app`

### Opsi 3: Vercel

1. **Install Vercel CLI:**
```bash
npm install -g vercel
```

2. **Deploy:**
```bash
flutter build web --release
vercel --prod build/web
```

Atau gunakan web UI: https://vercel.com/new

### Opsi 4: GitHub Pages

**Kelebihan:**
✅ Gratis
✅ Terintegrasi dengan GitHub
✅ URL custom domain supported

**Kekurangan:**
⚠️ Perlu manual push `build/web` tiap update
⚠️ Bandwidth terbatas (100 GB/bulan)
⚠️ Build limit 10x/jam (bisa diatasi dengan GitHub Actions)
⚠️ Tidak ada auto-deploy langsung dari main branch

1. **Build aplikasi:**
```bash
flutter build web --release --base-href="/record_your_money/"
```

2. **Push ke GitHub:**
```bash
cd build/web
git init
git add .
git commit -m "Deploy web"
git remote add origin https://github.com/zeinzulaziz/record_your_money.git
git branch -M gh-pages
git push -u origin gh-pages
```

3. **Aktifkan GitHub Pages:**
- Buka Settings di GitHub repo
- Pilih Pages
- Source: `gh-pages` branch
- Folder: `/ (root)`

4. **URL akan tersedia di:**
`https://zeinzulaziz.github.io/record_your_money/`

**Tips:** Untuk auto-deploy dari main branch, buat file `.github/workflows/deploy.yml`:

```yaml
name: Deploy Flutter Web
on:
  push:
    branches: [ main ]
permissions:
  contents: write
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.7'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter build web --release --base-href="/record_your_money/"
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: './build/web'
```

Dengan ini, setiap push ke `main` akan otomatis deploy ke GitHub Pages!

---

## Catatan Penting

⚠️ **Limitations untuk Web:**
- OCR (Camera & Gallery): Tidak berfungsi di web
- Speech-to-Text: Tidak berfungsi di web
- Fitur dashboard dan AI parsing tetap berfungsi normal

✅ **Yang Berfungsi di Web:**
- Input manual teks di text field
- Proses dengan AI untuk parsing transaksi
- Dashboard dengan filter lengkap (Harian, Mingguan, Bulanan, Tahunan, Custom)
- Lihat dan edit transaksi
- Delete multiple transaksi
- Supabase authentication dan storage

## Testing Lokal

Untuk test lokal sebelum deploy:
```bash
flutter run -d chrome --web-renderer html
```

Atau gunakan local server:
```bash
cd build/web
python3 -m http.server 8000
# Akses di http://localhost:8000
```

## Build Command

Untuk rebuild aplikasi:
```bash
flutter build web --release
```

File hasil build ada di `build/web` dan siap untuk di-deploy ke platform manapun.

## URL Production

Setelah deploy selesai, share URL production Anda agar bisa diakses di device manapun!

Contoh:
- Netlify: `https://your-app.netlify.app`
- Firebase: `https://your-project.web.app`
- Vercel: `https://your-app.vercel.app`
- GitHub Pages: `https://username.github.io/record_your_money/`
