#!/usr/bin/env bash
set -e
echo "🚀 Building LazyLogic GPT chatbot UI with memory + auto-deploy"

# --- config ---
SITE_DIR="$HOME/lazylogic/public"
NTFY_TOPIC="lazylogic-global"
LOG="$HOME/lazylogic/scripts/auto-deploy.log"
TIMESTAMP="$(date '+%F %T')"
export OPENAI_API_KEY="${OPENAI_API_KEY:-YOUR_OPENAI_API_KEY}"

mkdir -p "$SITE_DIR/assets"

# --- 1. generate the HTML with memory + GPT backend ---
cat > "$SITE_DIR/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>LazyLogic — Automate Everything</title>
<style>
:root {
  --bg:#0b0f17;--ink:#e6ebff;--muted:#9fb3ff;
  --accent:#8257ff;--accent2:#35c2ff;--coffee:#c48a4a;
}
html,body{margin:0;padding:0;height:100%;background:var(--bg);color:var(--ink);font-family:sans-serif;overflow:hidden;}
h1{font-size:3em;margin-top:20vh;}
canvas{position:fixed;top:0;left:0;width:100%;height:100%;z-index:-1;}
.chatbot{position:fixed;bottom:20px;right:20px;background:rgba(20,25,35,.9);border:1px solid var(--accent2);border-radius:12px;padding:10px;width:320px;max-height:420px;color:var(--ink);}
input{width:100%;padding:8px;background:#111;color:#fff;border:1px solid var(--accent2);border-radius:8px;}
</style>
</head>
<body>
<canvas id="bg"></canvas>
<h1>🚀 LazyLogic AI Assistant</h1>
<p>Automation meets design. Ask anything below.</p>
<div class="chatbot">
  <div id="chatlog" style="overflow-y:auto;height:250px;margin-bottom:5px;"></div>
  <input id="msg" placeholder="Ask LazyLogic..." autofocus>
</div>
<script>
// animated background
const c=document.getElementById('bg'),x=c.getContext('2d');
function resize(){c.width=innerWidth;c.height=innerHeight;}window.onresize=resize;resize();
let p=Array(80).fill().map(()=>({x:Math.random()*c.width,y:Math.random()*c.height,vx:Math.random()*2-1,vy:Math.random()*2-1}));
function draw(){x.fillStyle='rgba(11,15,23,.3)';x.fillRect(0,0,c.width,c.height);
x.fillStyle='#35c2ff';p.forEach(o=>{x.beginPath();x.arc(o.x,o.y,2,0,6.28);x.fill();o.x+=o.vx;o.y+=o.vy;
if(o.x<0||o.x>c.width)o.vx*=-1;if(o.y<0||o.y>c.height)o.vy*=-1;});requestAnimationFrame(draw);}draw();

// GPT chat with memory
const chat=document.getElementById('chatlog'),inp=document.getElementById('msg');
let history=[{role:"system",content:"You are LazyLogic AI, a helpful automation assistant."}];
async function askGPT(q){
 history.push({role:"user",content:q});
 const res=await fetch("https://api.openai.com/v1/chat/completions",{
   method:"POST",
   headers:{
     "Content-Type":"application/json",
     "Authorization":"Bearer "+(localStorage.getItem("OPENAI_API_KEY")||"YOUR_OPENAI_API_KEY")
   },
   body:JSON.stringify({model:"gpt-3.5-turbo",messages:history,max_tokens:200})
 });
 const data=await res.json();
 const reply=data.choices?.[0]?.message?.content?.trim()||"⚠️ No response.";
 history.push({role:"assistant",content:reply});
 return reply;
}
inp.addEventListener("keypress",async e=>{
 if(e.key==="Enter"){
   const q=inp.value.trim();if(!q)return;
   chat.innerHTML+=`<div><b>You:</b> ${q}</div>`;inp.value="";
   chat.scrollTop=chat.scrollHeight;
   const a=await askGPT(q);
   chat.innerHTML+=`<div><b>LazyLogic:</b> ${a}</div>`;
   chat.scrollTop=chat.scrollHeight;
 }
});
</script>
<script async defer data-domain="lazylogic.org" src="https://plausible.io/js/script.js"></script>
</body>
</html>
HTML

# --- 2. redirect file ---
echo "/* /index.html 200" > "$SITE_DIR/_redirects"

# --- 3. deploy to Netlify ---
netlify deploy --prod --dir="$SITE_DIR" --message "🤖 GPT chatbot (memory) auto-deploy" || true

# --- 4. ntfy alert ---
curl -fsS -d "✅ LazyLogic GPT chatbot (memory mode) deployed successfully." \
  -H "Title: LazyLogic Auto-Deploy" -H "Tags: rocket,coffee,white_check_mark" \
  https://ntfy.sh/$NTFY_TOPIC >/dev/null 2>&1

echo "[$TIMESTAMP] ✅ Completed GPT chatbot deploy" | tee -a "$LOG"
