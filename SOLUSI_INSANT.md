# 🔥 Solusi Masalah Blank Page di Netlify

Masalah: Halaman blank karena Netlify Drop hanya upload file, tapi tidak build Flutter!

## ✅ Solusi: Connect GitHub ke Netlify (Auto Deploy)

### Cara Setup:

1. **Buka Netlify Dashboard:**
   - Login ke: https://app.netlify.com
   - Klik "Add new site" → "Import an existing project"

2. **Connect ke GitHub:**
   - Pilih "GitHub" sebagai git provider
   - Authorize Netlify (jika perlu)
   - Pilih repository: `zeinzulaziz/record_your_money`

3. **Configure Build Settings:**
   - Base directory: **`/`** (root project)
   - Build command: **`flutter build web --release`**
   - Publish directory: **`build/web`**
   
4. **Environment Variables (Opsional, jika build gagal):**
   - Jika build error karena secrets, tambahkan:
     - `GROQ_API_KEY`: (api key Anda)
     - `SUPABASE_URL`: `https://mfpyhrapkkushlzxdimu.supabase.co`
     - `SUPABASE_ANON_KEY`: (anon key Anda)

5. **Deploy:**
   - Klik "Deploy site"
   - Tunggu build selesai (sekitar 3-5 menit)

**Setelah ini, setiap push ke GitHub akan auto deploy!** 🎉

---

## 🔧 File Konfigurasi

File `netlify.toml` sudah ada di repo, tapi untuk Flutter perlu environment khusus.

### **Option A: Build di GitHub Actions (RECOMMENDED)**

1. **Push ke GitHub** (sudah dilakukan)
2. **Connect GitHub ke Netlify:**
   - Import project dari GitHub
   - Netlify akan auto detect `netlify.toml`
   
3. **Tapi:** Netlify tidak punya Flutter SDK di build environment!
   - Solusi: Gunakan GitHub Actions untuk build, deploy via artifact

### **Option B: Manual Re-deploy dengan Build Command**

1. Di Netlify Dashboard, go to **Site settings**
2. **Build & deploy** → **Build settings**
3. Edit:
   - **Base directory:** `/`
   - **Build command:** `flutter build web --release` (ini akan gagal di Netlify!)
   - **Publish directory:** `build/web`

**Masalah:** Netlify tidak punya Flutter SDK!

### **✅ Option C: Build Lokal + Deploy ke Netlify (TERMUDAH)**

Karena Netlify Drop sudah upload `build/web`, tapi blank karena konfigurasi salah:

1. **Manual deploy ulang dari terminal:**
```bash
cd /Users/fanaloka/record_your_money/build/web
netlify deploy --dir=.
```

2. **Atau:**
   - Buka Netlify dashboard
   - Deploys → Trigger deploy → Deploy site
   - Ini akan re-upload existing files

### **🚀 Option D: GitHub Actions → Netlify (BEST!)**

Build di GitHub Actions, deploy ke Netlify:

1. File workflow sudah ada di `.github/workflows/deploy.yml`
2. Update untuk deploy ke Netlify juga!
3. Atau gunakan template ini:

