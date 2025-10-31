# 🔥 SOLUSI LENGKAP: Deploy Flutter Web ke Netlify

## Masalah Anda:
1. ✅ GitHub repo sudah ada
2. ✅ Netlify site sudah ada: https://recordyourmoney.netlify.app
3. ❌ Halaman masih blank!

## Root Cause:
Netlify tidak bisa build Flutter secara otomatis (tidak ada Flutter SDK di build environment).

---

## 🎯 SOLUSI: 3 Cara (Pilih Salah Satu)

### Cara 1: Deploy Manual via Terminal (TERCEPAT!)

**Build + Upload langsung:**

```bash
# 1. Build Flutter web
cd /Users/fanaloka/record_your_money
flutter build web --release

# 2. Deploy ke Netlify
netlify deploy --prod --dir=build/web --site=recordyourmoney
```

Jika diminta login, ikuti petunjuk di terminal.

**Cocok untuk:** Testing cepat atau one-time deploy.

---

### Cara 2: Auto Deploy via GitHub (RECOMMENDED!)

**Setup sekali, selamanya auto:**

#### Step 1: Get Netlify Token & Site ID

1. **Get Access Token:**
   - Buka: https://app.netlify.com/user/applications
   - "New access token"
   - Copy token

2. **Get Site ID:**
   - Netlify dashboard → Site settings
   - Copy **Site ID** (bukan URL!)

#### Step 2: Add Secrets to GitHub

1. Buka: https://github.com/zeinzulaziz/record_your_money/settings/secrets/actions
2. "New repository secret"
3. Tambahkan:
   - `NETLIFY_AUTH_TOKEN` → Token dari step 1
   - `NETLIFY_SITE_ID` → Site ID dari step 2

#### Step 3: Enable Workflow

File workflow sudah ada! Push ke GitHub:

```bash
git add .github/workflows/deploy_netlify.yml
git commit -m "Enable Netlify auto-deploy"
git push origin main
```

**Setelah ini:** Setiap push ke `main` akan otomatis deploy ke Netlify! 🎉

---

### Cara 3: Connect GitHub di Netlify UI (TAPI TETAP PERLU BUILD MANUAL)

**Masalah:** Netlify tidak punya Flutter SDK.

**Solusi Workaround:**

1. **Connect GitHub:**
   - Netlify → Add site → Import from Git
   - Pilih GitHub → zeinzulaziz/record_your_money

2. **Build Settings:**
   - Build command: **KOSONG** (biar deploy langsung)
   - Publish directory: **KOSONG**
   - Deploy: Akan gagal karena tidak ada file

3. **Manual Deploy:**
   - Deploys → "Trigger deploy" → "Deploy site"
   - Pilih folder `build/web` yang sudah di-build

**Ini bukan auto-deploy beneran, tapi masih manual!**

---

## ✅ REKOMENDASI

**Untuk sekarang (Quick Fix):**
→ **Gunakan Cara 1** (deploy via terminal)

**Untuk production (Long-term):**
→ **Setup Cara 2** (GitHub Actions + Netlify)

---

## 🐛 Troubleshooting

**Q: Deploy gagal dengan error "No files found"?**
A: Pastikan `build/web` sudah di-build dengan `flutter build web --release`

**Q: Aplikasi masih blank?**
A: Cek browser console (F12) untuk error JavaScript. Kemungkinan:
- CORS issue
- API keys tidak di-load
- Dependency missing

**Q: GitHub Actions workflow gagal?**
A: Cek apakah secrets sudah ditambahkan dengan benar

---

## 📝 File Penting

- ✅ `.github/workflows/deploy_netlify.yml` - Workflow untuk auto-deploy
- ✅ `netlify.toml` - Netlify configuration
- ✅ `build/web/` - Folder hasil build yang harus di-deploy

---

**Mulai dengan Cara 1 untuk fix cepat, lalu setup Cara 2 untuk production!** 🚀

