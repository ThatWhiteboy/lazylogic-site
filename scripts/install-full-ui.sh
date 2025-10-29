#!/usr/bin/env bash
set -e
echo "🎨 Building LazyLogic full UI with animated background + chatbot + analytics..."
mkdir -p public/assets
cat > public/index.html <<'HTML'
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
  .chatbot{position:fixed;bottom:20px;right:20px;background:rgba(20,25,35,.9);border:1px solid var(--accent2);border-radius:12px;padding:10px;width:300px;max-height:400px;color:var(--ink);}
  input{width:100%;padding:8px;background:#111;color:#fff;border:1px solid var(--accent2);border-radius:8px;}
</style>
</head>
<body>
<canvas id="bg"></canvas>
<h1>🚀 LazyLogic is Live</h1>
<p>Automation meets design. Let's build something extraordinary.</p>
<div class="chatbot">
  <div id="chatlog" style="overflow-y:auto;height:250px;margin-bottom:5px;"></div>
  <input id="msg" placeholder="Ask me anything...">
</div>
<script>
// ✨ Animated background
const c=document.getElementById('bg'),x=c.getContext('2d');
function r(){c.width=innerWidth;c.height=innerHeight;}
window.onresize=r;r();
let p=Array(100).fill().map(()=>({x:Math.random()*c.width,y:Math.random()*c.height,vx:Math.random()*2-1,vy:Math.random()*2-1}));
function a(){x.fillStyle='rgba(11,15,23,.3)';x.fillRect(0,0,c.width,c.height);x.fillStyle='#35c2ff';
p.forEach(o=>{x.beginPath();x.arc(o.x,o.y,2,0,6.28);x.fill();o.x+=o.vx;o.y+=o.vy;
if(o.x<0||o.x>c.width)o.vx*=-1;if(o.y<0||o.y>c.height)o.vy*=-1;});
requestAnimationFrame(a);}a();
// 🤖 Simple chatbot mock
const chat=document.getElementById('chatlog'),inp=document.getElementById('msg');
inp.addEventListener('keypress',e=>{
 if(e.key==='Enter'){let m=inp.value.trim();if(!m)return;
 chat.innerHTML+=`<div><b>You:</b> ${m}</div>`;
 inp.value='';fetch('https://api.chucknorris.io/jokes/random')
 .then(r=>r.json()).then(j=>{
 chat.innerHTML+=`<div><b>Bot:</b> ${j.value}</div>`;
 chat.scrollTop=chat.scrollHeight;});
 }});
</script>
<script async defer data-domain="lazylogic.org" src="https://plausible.io/js/script.js"></script>
</body>
</html>
HTML
echo "/* /index.html 200" > public/_redirects
netlify deploy --prod --dir=public --message "🚀 Full animated UI + chatbot deploy"
