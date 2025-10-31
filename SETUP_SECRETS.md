# 🔑 Setup GitHub Secrets untuk Auto Deploy

## Secrets yang Diperlukan:

### Netlify Secrets:
- **NETLIFY_AUTH_TOKEN:** `your_netlify_token_here`
- **NETLIFY_SITE_ID:** `your_netlify_site_id_here`

### App Secrets:
- **KGROQ_API_KEY:** `your_groq_api_key_here`
- **KSUPABASE_URL:** `https://your-supabase-url.supabase.co`
- **KSUPABASE_ANON_KEY:** `your_supabase_anon_key_here`

---

## Cara Menambahkan ke GitHub Secrets:

### Step 1: Buka GitHub Secrets Page

1. Buka: **https://github.com/zeinzulaziz/record_your_money/settings/secrets/actions**

### Step 2: Tambahkan 5 Secrets

Tambahkan satu per satu, klik **"New repository secret"** untuk setiap secret:

#### Secret 1: Netlify Auth Token
- Name: `NETLIFY_AUTH_TOKEN`
- Secret: (dapatkan dari Netlify dashboard → Site settings → General → Site details → Site ID & Netlify CLI token)

#### Secret 2: Netlify Site ID
- Name: `NETLIFY_SITE_ID`
- Secret: (dapatkan dari Netlify dashboard → Site settings → General → Site details → Site ID & Netlify CLI token)

#### Secret 3: Groq API Key
- Name: `KGROQ_API_KEY`
- Secret: (dapatkan dari https://console.groq.com/ → API Keys)

#### Secret 4: Supabase URL
- Name: `KSUPABASE_URL`
- Secret: (dapatkan dari Supabase project → Settings → API → Project URL)

#### Secret 5: Supabase Anon Key
- Name: `KSUPABASE_ANON_KEY`
- Secret: (dapatkan dari Supabase project → Settings → API → anon public key)

### Step 3: Verifikasi

Anda harus punya 5 secrets:
- ✅ NETLIFY_AUTH_TOKEN
- ✅ NETLIFY_SITE_ID
- ✅ KGROQ_API_KEY
- ✅ KSUPABASE_URL
- ✅ KSUPABASE_ANON_KEY

---

## Test Auto Deploy:

Setelah secrets ditambahkan, push code untuk trigger workflow:

```bash
git add .
git commit -m "Test auto deploy"
git push origin main
```

Cek GitHub Actions:
- Buka: https://github.com/zeinzulaziz/record_your_money/actions
- Tunggu workflow "Build Flutter Web and Deploy to Netlify" selesai
- Icon hijau ✅ = berhasil!

Setelah sukses, aplikasi akan auto-update di:
**https://recordyourmoney.netlify.app/** 🎉
