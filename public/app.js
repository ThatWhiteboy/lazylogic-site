(() => {
  // year
  document.getElementById('y').textContent = new Date().getFullYear();

  // animated background particles + parallax beams
  const c = document.getElementById('bg');
  const x = c.getContext('2d');
  let w,h,px,particles=[];

  function resize(){
    w = c.width = window.innerWidth;
    h = c.height = window.innerHeight;
    px = Math.round((w*h)/22000); // particle density
    particles = Array.from({length: px}, () => ({
      x: Math.random()*w,
      y: Math.random()*h,
      r: Math.random()*1.8+0.4,
      vx: (Math.random()-0.5)*0.35,
      vy: (Math.random()-0.5)*0.35,
      a: Math.random()*Math.PI*2
    }));
  }
  function step(){
    x.clearRect(0,0,w,h);
    // gradient beams
    const g1 = x.createLinearGradient(0,0,w,0);
    g1.addColorStop(0,"rgba(130,87,255,0.13)");
    g1.addColorStop(1,"rgba(53,194,255,0.10)");
    x.fillStyle = g1;
    x.fillRect(0,0,w,h);

    // particles
    particles.forEach(p=>{
      p.x+=p.vx; p.y+=p.vy; p.a+=0.01;
      if(p.x<0||p.x>w) p.vx*=-1;
      if(p.y<0||p.y>h) p.vy*=-1;
      x.beginPath();
      x.arc(p.x,p.y,p.r,0,Math.PI*2);
      x.fillStyle = `rgba(159,179,255,${0.15+0.15*Math.sin(p.a)})`;
      x.fill();
    });
    requestAnimationFrame(step);
  }
  window.addEventListener('resize', resize);
  resize(); step();
})();
