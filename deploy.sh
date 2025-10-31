#!/bin/bash
# Script untuk deploy Flutter Web ke Netlify via CLI

echo "🚀 Deploy Flutter Web ke Netlify..."
echo ""

# 1. Build web
echo "📦 Building web application..."
cd /Users/fanaloka/record_your_money
flutter build web --release

# 2. Check jika netlify CLI sudah installed
if ! command -v netlify &> /dev/null; then
    echo "⚠️  Netlify CLI belum terinstall"
    echo "Installing Netlify CLI..."
    npm install -g netlify-cli
fi

# 3. Deploy
echo "🚀 Deploying to Netlify..."
netlify deploy --prod --dir=build/web --json

echo ""
echo "✅ Deployment selesai!"
echo "Buka https://app.netlify.com untuk melihat URL aplikasi Anda"

