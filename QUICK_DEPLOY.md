# Quick Deploy - Instant Solution! ⚡

Tanpa perlu setup GitHub Actions yang rumit, deploy Aplikasi Anda dalam **2 menit**:

## 🚀 Deploy ke Netlify Drop (Paling Cepat!)

1. **Build aplikasi:**
```bash
cd /Users/fanaloka/record_your_money
flutter build web --release
```

2. **Buka Netlify Drop:**
   - Buka: https://app.netlify.com/drop

3. **Drag & Drop:**
   - Drag folder `build/web` ke browser
   - Tunggu upload selesai
   
4. **Dapatkan URL:**
   - Langsung dapat URL: `https://random-name.netlify.app`
   - Copy URL tersebut

**Selesai! Aplikasi sudah online!** 🎉

---

## Alternatif: Deploy via GitHub CLI

Jika ingin tetap pakai GitHub Pages tapi lebih mudah:

```bash
# 1. Build web
flutter build web --release --base-href="/record_your_money/"

# 2. Deploy dengan gh-pages CLI
cd build/web
npx gh-pages -d . -r https://github.com/zeinzulaziz/record_your_money.git -b gh-pages
```

Tapi **Netlify Drop jauh lebih mudah!** ✅

---

## Troubleshooting GitHub Actions

Jika ingin fix GitHub Actions:

**Masalah:** GitHub Actions gagal karena `lib/secrets.dart` tidak ada
**Solusi:** File `secrets.dart` di-ignore oleh `.gitignore` (yang benar untuk keamanan!)

**Untuk GitHub Actions perlu:**
1. Buat GitHub Secrets di Settings → Secrets → Actions
2. Tambahkan:
   - `GROQ_API_KEY`
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
3. Update workflow untuk gunakan secrets dari environment variables

**Tapi untuk sekarang:** Netlify Drop adalah solusi paling cepat!

