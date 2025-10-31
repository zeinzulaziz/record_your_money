# 🚨 Penting: GitHub Secrets Harus Ditambahkan!

## Status Saat Ini

Workflow saat ini akan **GAGAL** karena GitHub Secrets belum ditambahkan ke repository.

---

## ✅ LANGKAH LENGKAP UNTUK SETUP SECRETS:

### 1. Buka Halaman GitHub Secrets
**Link:** https://github.com/zeinzulaziz/record_your_money/settings/secrets/actions

### 2. Tambahkan 5 Secrets Berikut (Klik "New repository secret" untuk setiap secret)

#### Secret 1: NETLIFY_AUTH_TOKEN
- **Name:** `NETLIFY_AUTH_TOKEN`
- **Value:** *(dapatkan dari Netlify dashboard → Site settings → General → Site details)*

#### Secret 2: NETLIFY_SITE_ID
- **Name:** `NETLIFY_SITE_ID`
- **Value:** *(dapatkan dari Netlify dashboard → Site settings → General → Site details)*

#### Secret 3: KGROQ_API_KEY
- **Name:** `KGROQ_API_KEY`
- **Value:** *(dapatkan dari https://console.groq.com/ → API Keys)*

#### Secret 4: KSUPABASE_URL
- **Name:** `KSUPABASE_URL`
- **Value:** *(dapatkan dari Supabase project → Settings → API → Project URL)*

#### Secret 5: KSUPABASE_ANON_KEY
- **Name:** `KSUPABASE_ANON_KEY`
- **Value:** *(dapatkan dari Supabase project → Settings → API → anon public key)*

### 3. Setelah Semua Secrets Ditambahkan

Setelah semua 5 secrets ditambahkan, lakukan salah satu berikut:

#### Opsi A: Manual Trigger (Paling Cepat)
1. Buka: https://github.com/zeinzulaziz/record_your_money/actions
2. Klik workflow: "Build Flutter Web and Deploy to Netlify"
3. Klik "Run workflow" → Pilih branch "main" → Klik hijau "Run workflow"

#### Opsi B: Push Kode Baru
```bash
git add .
git commit -m "Trigger deploy after adding secrets"
git push origin main
```

### 4. Pantau Proses Deploy

1. Buka: https://github.com/zeinzulaziz/record_your_money/actions
2. Klik workflow run yang baru
3. Tunggu sampai selesai (sekitar 2-3 menit)
4. Icon hijau ✅ = **SUKSES!**
5. Icon merah ❌ = **GAGAL** (cek log untuk error)

### 5. Setelah Sukses

Aplikasi akan tersedia di:
**https://recordyourmoney.netlify.app/**

---

## ⚠️ Catatan Penting

- **JANGAN** share secrets ini ke public
- Secrets ini sudah di-hardcode di lokal untuk develop, tapi untuk CI/CD harus melalui GitHub Secrets
- Setelah ditambahkan, workflow akan auto-run setiap push ke main branch

---

## ✅ Checklist

- [ ] Secret NETLIFY_AUTH_TOKEN ditambahkan
- [ ] Secret NETLIFY_SITE_ID ditambahkan  
- [ ] Secret KGROQ_API_KEY ditambahkan
- [ ] Secret KSUPABASE_URL ditambahkan
- [ ] Secret KSUPABASE_ANON_KEY ditambahkan
- [ ] Workflow di-trigger (manual atau push)
- [ ] Workflow selesai dengan ✅
- [ ] Aplikasi live di Netlify

---

## 🆘 Troubleshooting

### Workflow gagal dengan error "secret not found"
- Pastikan semua 5 secrets sudah ditambahkan
- Pastikan nama secrets EXACT match (case sensitive)

### Workflow gagal saat build
- Cek log untuk detail error
- Pastikan Flutter version di workflow sesuai dengan yang di local

### Workflow sukses tapi aplikasi blank di Netlify
- Cek Netlify dashboard untuk error log
- Pastikan base-href sudah benar di web/index.html
