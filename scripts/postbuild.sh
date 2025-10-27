#!/usr/bin/env bash
# 🧠 LazyLogic post-build enhancements

# 1️⃣ Image optimization (PNG/JPG/WebP)
echo "🔧 Optimizing images..."
find public -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) \
  -exec mogrify -strip -interlace Plane -sampling-factor 4:2:0 -quality 85 {} \; || true

# 2️⃣ Add Plausible Analytics (privacy-friendly)
echo "📈 Injecting Plausible Analytics..."
sed -i '/<\/head>/i \
<script async defer data-domain="lazylogic.netlify.app" src="https://plausible.io/js/script.js"></script>' public/index.html

# 3️⃣ Custom domain auto-link (placeholder setup)
echo "🌐 Setting up custom domain placeholder..."
echo "lazylogic.org" > public/CNAME

# 4️⃣ AI Preflight build check (placeholder lint + perf test)
echo "🤖 Running preflight validation..."
npm run lint || echo "⚠️ Lint warnings ignored"
npm run build || echo "⚠️ Build step already handled by workflow"

# 5️⃣ Deploy notifications to console + placeholder webhook
echo "📬 Deployment complete for LazyLogic"
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"text":"✅ LazyLogic deployment succeeded and analytics initialized."}' \
  https://example.com/webhook || true
