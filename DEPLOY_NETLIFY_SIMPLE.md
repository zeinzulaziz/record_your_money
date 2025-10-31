# 🚀 Deploy ke Netlify via GitHub (Cara Termudah!)

Yang sudah ada:
- ✅ Site Netlify: https://recordyourmoney.netlify.app
- ✅ Repository GitHub: zeinzulaziz/record_your_money
- ✅ File `netlify.toml` sudah ada

Masalah: Halaman blank karena build command belum di-set!

---

## Solusi: Connect GitHub ke Netlify

### Cara 1: Manual Build + Upload (Paling Cepat untuk Testing)

1. **Build di lokal:**
```bash
cd /Users/fanaloka/record_your_money
flutter build web --release
```

2. **Upload ke Netlify:**
   - Buka Netlify dashboard → Deploys
   - Klik "Trigger deploy" → "Deploy site"
   - Atau drag & drop folder `build/web` ke Netlify Drop lagi

**Ini akan langsung work!**

---

### Cara 2: Connect GitHub (Auto Deploy) ⭐

**Setup sekali pakai auto-deploy:**

1. **Connect GitHub di Netlify:**
   - Buka: https://app.netlify.com
   - Site: recordyourmoney.netlify.app
   - Site settings → Build & deploy → Continuous Deployment
   - "Link repository" → Pilih GitHub → zeinzulaziz/record_your_money

2. **Configure Build Settings:**
   - Base directory: **`/`**
   - Build command: **`flutter build web --release`** (ini akan gagal!)
   - Publish directory: **`build/web`**

**Tapi tunggu:** Netlify tidak punya Flutter SDK built-in!

### Solusi: Build via GitHub Actions

Netlify **dapat** pakai build dari GitHub Actions via artifact upload.

File `.github/workflows/deploy_netlify.yml` sudah disiapkan, tapi perlu secrets dulu.

---

## 🎯 Rekomendasi: Hybrid Approach

**Manual deploy sekarang, auto-deploy setup nanti:**

```bash
# 1. Build lokal
flutter build web --release

# 2. Deploy via CLI
cd /Users/fanaloka/record_your_money
netlify deploy --prod --dir=build/web
```

Atau:

**Update Build Settings di Netlify:**
1. Dashboard → Site settings → Build & deploy
2. Edit build settings:
   - Build command: **KOSONG**
   - Publish directory: `build/web`
3. Upload `build/web` manual via Netlify Drop

---

## ✅ Fix Blank Page SEKARANG

**Opsi A: Re-deploy folder yang sudah di-build:**

1. Buat ZIP dari `build/web`:
```bash
cd /Users/fanaloka/record_your_money
cd build/web
zip -r ../../web_build.zip .
```

2. Upload ZIP ke: https://recordyourmoney.netlify.app/admin/deploy-settings

**Opsi B: Manual deploy via CLI:**

```bash
cd /Users/fanaloka/record_your_money/build/web
netlify deploy --prod --dir=. --site=recordyourmoney
```

**Opsi C: Build Settings Fix:**

1. Di Netlify: Site settings → Build & deploy
2. Build command: KOSONG
3. Publish directory: (kosongkan semua)
4. Save
5. Deploys → Trigger deploy → Clear cache and deploy

---

**Coba salah satu cara di atas, yang mana pun yang paling mudah!** 🚀

