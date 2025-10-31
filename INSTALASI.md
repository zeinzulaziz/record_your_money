# 📝 Cara Setup GitHub Secrets untuk Auto Deploy

Anda sudah punya:
- ✅ **NETLIFY_AUTH_TOKEN:** `nfp_RCvTxZwoGDoUrBVkLK2C7T38rfjoTsri7141`
- ✅ **NETLIFY_SITE_ID:** `1bad40f2-4067-48b9-bb27-11f4ba1c9ce4`

---

## 🎯 Langkah Tambah Secrets ke GitHub

### **Step 1: Login ke GitHub**
1. Buka: https://github.com/login
2. Login dengan akun Anda

### **Step 2: Buka Secrets Page**
1. Buka: https://github.com/zeinzulaziz/record_your_money
2. Klik tab **Settings** (di bagian kanan atas repository)
3. Scroll ke bawah, klik **Secrets and variables** → **Actions**

### **Step 3: Tambahkan Secret 1 - Auth Token**
1. Klik tombol **"New repository secret"** (atau **"Add secret"**)
2. Di field **Name**, ketik: `NETLIFY_AUTH_TOKEN` (exact!)
3. Di field **Secret**, paste: `nfp_RCvTxZwoGDoUrBVkLK2C7T38rfjoTsri7141`
4. Klik **"Add secret"**

### **Step 4: Tambahkan Secret 2 - Site ID**
1. Klik **"New repository secret"** lagi
2. Di field **Name**, ketik: `NETLIFY_SITE_ID` (exact!)
3. Di field **Secret**, paste: `1bad40f2-4067-48b9-bb27-11f4ba1c9ce4`
4. Klik **"Add secret"**

### **Step 5: Verifikasi**
Di halaman Secrets, Anda harus punya 2 secrets:
- ✅ **NETLIFY_AUTH_TOKEN**
- ✅ **NETLIFY_SITE_ID**

---

## 🚀 Test Auto Deploy

Setelah secrets ditambahkan, push ke GitHub untuk trigger workflow:

```bash
cd /Users/fanaloka/record_your_money
git add .github/workflows/deploy_netlify.yml
git commit -m "Add Netlify auto-deploy workflow"
git push origin main
```

**Monitor deployment:**
1. Buka: https://github.com/zeinzulaziz/record_your_money/actions
2. Klik workflow "Build Flutter Web and Deploy to Netlify"
3. Tunggu sampai selesai (sekitar 3-5 menit)
4. ✅ Icon hijau = berhasil!

**Aplikasi akan otomatis update di:**
**https://recordyourmoney.netlify.app/** 🎉

---

## 🐛 Troubleshooting

**Workflow gagal?**
- Cek apakah secrets sudah ditambahkan (Settings → Secrets)
- Pastikan nama secret **exact match**: `NETLIFY_AUTH_TOKEN` dan `NETLIFY_SITE_ID`
- Cek log error di GitHub Actions untuk detail

**Aplikasi masih blank?**
- Tunggu deployment selesai
- Hard refresh browser (Ctrl+F5 atau Cmd+Shift+R)
- Cek browser console (F12) untuk error

**Build gagal dengan Flutter error?**
- Workflow sudah include Flutter setup, tapi kalau error berarti ada dependency issue

---

**Selesai! Setiap push ke `main` akan otomatis deploy!** 🚀

