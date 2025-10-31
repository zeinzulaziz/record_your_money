# 🔑 Setup GitHub Secrets untuk Auto Deploy

## Token & Site ID yang Sudah Ada:

✅ **NETLIFY_AUTH_TOKEN:** `nfp_RCvTxZwoGDoUrBVkLK2C7T38rfjoTsri7141`
✅ **NETLIFY_SITE_ID:** `1bad40f2-4067-48b9-bb27-11f4ba1c9ce4`

---

## Cara Menambahkan ke GitHub Secrets:

### Step 1: Buka GitHub Secrets Page

1. Buka: **https://github.com/zeinzulaziz/record_your_money/settings/secrets/actions**

### Step 2: Add Secret 1 (Auth Token)

1. Klik **"New repository secret"**
2. Name: `NETLIFY_AUTH_TOKEN`
3. Secret: `nfp_RCvTxZwoGDoUrBVkLK2C7T38rfjoTsri7141`
4. Klik **"Add secret"**

### Step 3: Add Secret 2 (Site ID)

1. Klik **"New repository secret"** lagi
2. Name: `NETLIFY_SITE_ID`
3. Secret: `1bad40f2-4067-48b9-bb27-11f4ba1c9ce4`
4. Klik **"Add secret"**

### Step 4: Verifikasi

Anda harus punya 2 secrets:
- ✅ NETLIFY_AUTH_TOKEN
- ✅ NETLIFY_SITE_ID

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

