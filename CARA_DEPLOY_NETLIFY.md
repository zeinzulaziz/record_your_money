# 🚀 Cara Deploy ke Netlify via GitHub (Auto Deploy)

Setup sekali, selamanya auto-deploy dari GitHub! ✨

## Langkah 1: Connect GitHub ke Netlify

1. **Login ke Netlify:**
   - Buka: https://app.netlify.com
   - Login dengan GitHub account Anda

2. **Import Project:**
   - Klik "Add new site" (atau **Add site** → **Import an existing project**)
   - Pilih "GitHub"
   - Authorize Netlify jika diminta
   - Pilih repository: `zeinzulaziz/record_your_money`

3. **Configure Build Settings:**

   Netlify tidak punya Flutter SDK, jadi pakai **build command kosong** dan upload artifact:
   
   - **Base directory:** `/` (kosongkan atau `/`)
   - **Build command:** **(KOSONGKAN - biar gagal dengan cepat)**
   - **Publish directory:** `build/web`
   
   Kenapa kosong? Karena kita akan build via GitHub Actions dan upload file `build/web` langsung!

4. **Deploy:**
   - Klik "Deploy site"
   - Ini akan gagal, tapi tidak masalah (biarkan deployment gagal)

---

## Langkah 2: Setup GitHub Secrets

Untuk auto-deploy ke Netlify via GitHub Actions:

1. **Dapatkan Netlify Token:**
   - Di Netlify: https://app.netlify.com/user/applications
   - Klik "New access token"
   - Name: `GitHub Actions Deploy`
   - Copy token (tampil sekali!)

2. **Dapatkan Site ID:**
   - Di Netlify dashboard → Site settings
   - Copy **Site ID**

3. **Add Secrets ke GitHub:**
   - Buka: https://github.com/zeinzulaziz/record_your_money/settings/secrets/actions
   - Klik "New repository secret"
   - Tambahkan 2 secrets:
     - `NETLIFY_AUTH_TOKEN` → Paste token dari langkah 1
     - `NETLIFY_SITE_ID` → Paste Site ID dari langkah 2

---

## Langkah 3: Setup GitHub Actions

File workflow sudah ada di `.github/workflows/deploy_netlify.yml`!

Push ke GitHub:

```bash
cd /Users/fanaloka/record_your_money
git add .github/workflows/deploy_netlify.yml
git commit -m "Add Netlify auto-deploy"
git push origin main
```

---

## Langkah 4: Aktifkan Workflow

1. Tunggu GitHub Actions selesai (cek di tab "Actions")
2. Deployment akan otomatis ke Netlify
3. URL aplikasi akan tersedia di: `https://recordyourmoney.netlify.app/`

---

## Troubleshooting

**Q: Build gagal di Netlify?**
A: **Normal!** Netlify tidak punya Flutter SDK. GitHub Actions akan handle build.

**Q: GitHub Actions gagal?**
A: Cek apakah secrets sudah ditambahkan dengan benar.

**Q: Aplikasi masih blank?**
A: Cek Netlify dashboard → Deploys → lihat log build apakah file `build/web` ter-upload.

---

## Cara Kerja

1. Push ke GitHub → Trigger GitHub Actions
2. GitHub Actions build Flutter Web di cloud
3. GitHub Actions deploy hasil build ke Netlify
4. Netlify serve aplikasi live!

**Setiap push ke `main` = otomatis update aplikasi!** 🎉

