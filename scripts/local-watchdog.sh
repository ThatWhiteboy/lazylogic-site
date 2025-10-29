#!/usr/bin/env bash
# 🧠 LazyLogic Local Linux Self-Healing Watchdog with DNS Fallback

NTFY_TOPIC="lazylogic-global"
SITES=("https://lazylogic.netlify.app" "https://lazylogic.org")
LOGFILE="$HOME/lazylogic/scripts/watchdog.log"
TIMESTAMP="$(date '+%F %T')"

log() { echo "[$TIMESTAMP] $1" | tee -a "$LOGFILE"; }

notify() {
  local msg="$1"; local title="$2"; local tags="$3"
  curl -fsS -d "$msg" -H "Title: $title" -H "Tags: $tags" \
    https://ntfy.sh/$NTFY_TOPIC >/dev/null 2>&1
}

for site in "${SITES[@]}"; do
  host="$(echo "$site" | sed 's~https://~~;s~/~~')"
  log "🔎 Checking $site ..."
  resp="$(curl -fsSL --max-time 20 "$site" || true)"
  if [ -z "$resp" ]; then
    log "❌ Empty response for $site. Flushing DNS and retrying..."
    sudo systemd-resolve --flush-caches || true
    dig +short "$host" || true
    sleep 5
    resp="$(curl -fsSL --max-time 20 "$site" || true)"
  fi
  if [ -z "$resp" ]; then
    log "🚨 $site still unreachable after DNS retry."
    notify "❌ $site unreachable even after DNS retry." "LazyLogic Watchdog" "warning,skull"
    continue
  fi
  if echo "$resp" | grep -q "index.html 200"; then
    log "⚠️ Found stray 'index.html 200' text at $site."
    notify "⚠️ $site shows stray 'index.html 200' text — possible misrender." \
      "LazyLogic Watchdog" "alert,code"
    continue
  fi
  if ! ping -c1 -W3 "$host" >/dev/null 2>&1; then
    log "⚠️ Ping failed for $host — possible network issue."
    notify "⚠️ Ping to $host failed after DNS check." "LazyLogic Network Check" "wifi,warning"
    continue
  fi
  log "✅ $site verified clean and reachable."
  notify "✅ $site verified clean and reachable (Linux local check)." \
    "LazyLogic Watchdog" "rocket,white_check_mark"
done
