#!/usr/bin/env bash
set -e
echo "⚙️  Running LazyLogic Universal Auto-Deploy..."

# 1️⃣ Prep
mkdir -p public/{assets,about,contact,services,ai-tools,pricing} netlify/functions
echo "🌐 Preparing public structure..."

# 2️⃣ Generate neon multi-page UI with chat widget
cat > public/index.html <<'HTML'
<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>LazyLogic — Automate Everything</title>
<style>
:root{--bg:#0b0f17;--ink:#e6ebff;--accent:#8257ff;--accent2:#35c2ff;}
body{margin:0;font-family:sans-serif;background:var(--bg);color:var(--ink);overflow-x:hidden;text-align:center}
h1{margin-top:20vh;font-size:3em;color:var(--accent2)}
nav a{color:var(--accent2);margin:0 10px;text-decoration:none;}
.chat-btn{position:fixed;bottom:20px;right:20px;width:70px;height:70px;border-radius:50%;border:2px solid var(--accent2);
background:rgba(20,25,35,.8);box-shadow:0 0 15px var(--accent2);cursor:pointer;}
.chat-btn img{width:100%;height:100%;border-radius:50%;}
.chatbox{display:none;position:fixed;bottom:100px;right:20px;width:320px;height:420px;background:rgba(10,15,25,.95);
border:1px solid var(--accent2);border-radius:15px;padding:10px;overflow:hidden;color:var(--ink);}
.chatbox.active{display:block;animation:fadeIn .3s;}
#chatlog{height:320px;overflow-y:auto;text-align:left;}
input{width:100%;padding:8px;background:#111;color:#fff;border:1px solid var(--accent2);border-radius:8px;}
@keyframes fadeIn{from{opacity:0;transform:translateY(20px);}to{opacity:1;transform:translateY(0);}}
</style></head><body>
<nav><a href="#about">About</a><a href="#services">Services</a><a href="#pricing">Pricing</a><a href="#contact">Contact</a></nav>
<h1>AI That Works<br><span style="color:var(--accent)">While You Relax</span></h1>
<p>Experience the future of automation with LazyLogic.ai</p>
<div class="chat-btn" id="chatBtn"><img src="assets/robo.png" alt="Chat"></div>
<div class="chatbox" id="chatBox"><div id="chatlog"></div><input id="msg" placeholder="Ask me anything..."></div>
<script>
const btn=document.getElementById('chatBtn'),box=document.getElementById('chatBox'),log=document.getElementById('chatlog');
btn.onclick=()=>box.classList.toggle('active');
document.getElementById('msg').addEventListener('keypress',async e=>{
 if(e.key==='Enter'){let m=e.target.value.trim();if(!m)return;
 log.innerHTML+=`<div><b>You:</b> ${m}</div>`;e.target.value='';
 const r=await fetch('/.netlify/functions/chat',{method:'POST',body:JSON.stringify({q:m})});
 const j=await r.json();log.innerHTML+=`<div><b>Bot:</b> ${j.reply}</div>`;log.scrollTop=log.scrollHeight;}
});
</script></body></html>
HTML
echo "/* /index.html 200" > public/_redirects

# 3️⃣ Chat Function
cat > netlify/functions/chat.js <<'JS'
export async function handler(event){
  const {q=''}=JSON.parse(event.body||'{}');
  return new Response(JSON.stringify({reply:`Got it: ${q||'Say something to start.'}`}),{
    headers:{'content-type':'application/json','access-control-allow-origin':'*'}
  });
}
JS

# 4️⃣ Commit + deploy
git add . && git commit -m "🚀 Automated LazyLogic Deploy" || true
git pull --rebase origin master || true
git push origin master || true

# 5️⃣ Deploy
echo "🚀 Deploying to Netlify..."
netlify link --id 7a76027f-4466-40a2-9b72-6eb427b7eb31 || true
netlify deploy --prod --dir=public --message "🤖 Auto full deploy (LazyLogic Universal)"
echo "✅ Deployment complete!"
