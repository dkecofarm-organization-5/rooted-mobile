(()=>{
  const DESIGN_W=1600;
  const MIN_DESIGN_H=720;
  const MAX_DESIGN_H=1000;
  const app=document.getElementById('app');
  function fitDesktopStage(){
    if(!app) return;
    const vw=Math.max(1,window.innerWidth);
    const vh=Math.max(1,window.innerHeight);
    // Preserve desktop width so iframe media queries stay in desktop mode.
    // Match device aspect ratio by changing only the virtual desktop height.
    const designH=Math.max(MIN_DESIGN_H,Math.min(MAX_DESIGN_H,Math.round(DESIGN_W*vh/vw)));
    const scale=Math.min(vw/DESIGN_W,vh/designH);
    const shownW=DESIGN_W*scale, shownH=designH*scale;
    const x=Math.round((vw-shownW)/2), y=Math.round((vh-shownH)/2);
    app.style.width=DESIGN_W+'px';
    app.style.height=designH+'px';
    app.style.transform=`translate(${x}px,${y}px) scale(${scale})`;
    document.documentElement.style.setProperty('--rooted-mobile-scale',String(scale));
    document.documentElement.dataset.parity=`${DESIGN_W}x${designH}`;
  }
  addEventListener('resize',fitDesktopStage,{passive:true});
  addEventListener('orientationchange',()=>setTimeout(fitDesktopStage,80),{passive:true});
  addEventListener('load',fitDesktopStage,{once:true});
  fitDesktopStage();

  // On mobile, first user interaction may enter fullscreen / lock landscape when allowed.
  async function assist(){
    try{ if(document.documentElement.requestFullscreen && !document.fullscreenElement) await document.documentElement.requestFullscreen(); }catch(_){ }
    try{ if(screen.orientation?.lock) await screen.orientation.lock('landscape'); }catch(_){ }
  }
  ['startKR','startEN','startRU'].forEach(id=>document.getElementById(id)?.addEventListener('click',assist,{passive:true}));
})();
