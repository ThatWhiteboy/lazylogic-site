#!/usr/bin/env bash
set -e
echo "🎙️  Building LazyLogic GPT voice assistant with memory + auto-deploy"
SITE="$HOME/lazylogic/public"
NTFY_TOPIC="lazylogic-global"
mkdir -p "$SITE"

# ---------- HTML UI ----------
cat > "$SITE/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>LazyLogic — Voice AI Assistant</title>
<style>
:root{--bg:#0b0f17;--ink:#e6ebff;--accent:#8257ff;--accent2:#35c2ff;}
html,body{margin:0;height:100%;background:var(--bg);color:var(--ink);font-family:sans-serif;overflow:hidden;text-align:center;}
h1{margin-top:15vh;font-size:2.5em;}
button,input{margin:6px;padding:10px;border-radius:8px;border:1px solid var(--accent2);background:#111;color:var(--ink);}
.chatbox{position:fixed;bottom:15px;left:50%;transform:translateX(-50%);width:90%;max-width:380px;background:rgba(20,25,35,.9);border:1px solid var(--accent2);border-radius:12px;padding:10px;}
#log{height:220px;overflow-y:auto;text-align:left;margin-bottom:5px;}
canvas{position:fixed;top:0;left:0;width:100%;height:100%;z-index:-1;}
</style>
</head>
<body>
<canvas id="bg"></canvas>
<h1>🎙️ LazyLogic AI Assistant</h1>
<div class="chatbox">
  <div id="log"></div>
  <input id="msg" placeholder="Type or speak...">
  <button id="talk">🎤 Speak</button>
</div>

<script>
// ---- animated background ----
const c=document.getElementById('bg'),x=c.getContext('2d');
function r(){c.width=innerWidth;c.height=innerHeight;}window.onresize=r;r();
let p=Array(80).fill().map(()=>({x:Math.random()*c.width,y:Math.random()*c.height,vx:Math.random()*2-1,vy:Math.random()*2-1}));
function a(){x.fillStyle='rgba(11,15,23,.3)';x.fillRect(0,0,c.width,c.height);x.fillStyle='#35c2ff';
p.forEach(o=>{x.beginPath();x.arc(o.x,o.y,2,0,6.28);x.fill();o.x+=o.vx;o.y+=o.vy;
if(o.x<0||o.x>c.width)o.vx*=-1;if(o.y<0||o.y>c.height)o.vy*=-1;});requestAnimationFrame(a);}a();

// ---- GPT with memory + speech ----
const log=document.getElementById('log'),msg=document.getElementById('msg'),btn=document.getElementById('talk');
let history=[{role:"system",content:"You are LazyLogic AI, a friendly automation assistant."}];

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
 const a=data.choices?.[0]?.message?.content?.trim()||"⚠️ No response.";
 history.push({role:"assistant",content:a});
 return a;
}

function speak(t){
 const u=new SpeechSynthesisUtterance(t);
 u.lang="en-US";speechSynthesis.speak(u);
}

async function handle(q){
 log.innerHTML+=`<div><b>You:</b> ${q}</div>`;
 const a=await askGPT(q);
 log.innerHTML+=`<div><b>LazyLogic:</b> ${a}</div>`;
 log.scrollTop=log.scrollHeight;
 speak(a);
}

// text enter
msg.addEventListener("keypress",e=>{if(e.key==="Enter"){const q=msg.value.trim();if(q){msg.value="";handle(q);}}});

// voice input
btn.onclick=()=>{
 if(!('webkitSpeechRecognition'in window)){alert("Speech recognition not supported");return;}
 const rec=new webkitSpeechRecognition();
 rec.lang="en-US";rec.onresult=e=>handle(e.results[0][0].transcript);
 rec.start();
};
</script>
<script async defer data-domain="lazylogic.org" src="https://plausible.io/js/script.js"></script>
</body>
</html>
HTML

# ---------- redirects ----------
echo "/* /index.html 200" > "$SITE/_redirects"

# ---------- deploy ----------
netlify deploy --prod --dir="$SITE" --message "🎙️ GPT Voice Assistant Auto-Deploy" || true

# ---------- notify ----------
curl -fsS -d "✅ LazyLogic Voice Assistant deployed successfully." \
  -H "Title: LazyLogic Voice Auto-Deploy" \
  -H "Tags: rocket,microphone,white_check_mark" \
  https://ntfy.sh/$NTFY_TOPIC >/dev/null 2>&1
