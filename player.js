const LANGS = ["KR","EN","RU"];

const frames = {
  KR: document.getElementById("krFrame"),
  EN: document.getElementById("enFrame"),
  RU: document.getElementById("ruFrame")
};

const LABELS = {
  KR: {name:"한국어", mode:"Auto Play", key:"k"},
  EN: {name:"English", mode:"Auto Play", key:"e"},
  RU: {name:"Русский", mode:"Auto Play", key:"r"}
};

const state = {
  ready: {KR:false, EN:false, RU:false},
  active: null,
  paused: false,
  volume: 25,
  lastNonZeroVolume: 25,
  controlTimer: null,
  statusTimer: null
};


function ensureIntegratedNavButtons(){
  const bar = document.getElementById("controls");
  if(!bar) return;

  const svgPrev = '<svg class="nav-svg" viewBox="0 0 24 24" aria-hidden="true"><path d="M15.5 4.5 8 12l7.5 7.5"/></svg>';
  const svgNext = '<svg class="nav-svg" viewBox="0 0 24 24" aria-hidden="true"><path d="m8.5 4.5 7.5 7.5-7.5 7.5"/></svg>';

  if(!document.getElementById("prevBtn")){
    const b=document.createElement("button");
    b.id="prevBtn"; b.className="icon-btn nav-screen-btn nav-prev";
    b.title="Previous screen"; b.setAttribute("aria-label","Previous screen");
    b.innerHTML=svgPrev;
    bar.insertBefore(b, bar.firstChild);
  }
  if(!document.getElementById("nextBtn")){
    const b=document.createElement("button");
    b.id="nextBtn"; b.className="icon-btn nav-screen-btn nav-next";
    b.title="Next screen"; b.setAttribute("aria-label","Next screen");
    b.innerHTML=svgNext;
    bar.appendChild(b);
  }
}
ensureIntegratedNavButtons();

const app = document.getElementById("app");
const gate = document.getElementById("gate");
const controls = document.getElementById("controls");
const muteBtn = document.getElementById("muteBtn");
const volDownBtn = document.getElementById("volDownBtn");
const volUpBtn = document.getElementById("volUpBtn");
const volumeLabel = document.getElementById("volumeLabel");
const prevBtn = document.getElementById("prevBtn");
const pauseBtn = document.getElementById("pauseBtn");
const nextBtn = document.getElementById("nextBtn");
const fullBtn = document.getElementById("fullBtn");
const controlToggle = document.getElementById("controlToggle");
const loadingText = document.getElementById("loadingText");
const status = document.getElementById("status");

function doc(lang){
  try { return frames[lang].contentDocument || frames[lang].contentWindow.document; }
  catch(_) { return null; }
}

function normalizeChildIntegratedUI(lang){
  const d = doc(lang);
  if(!d) return false;

  d.documentElement.classList.add("integrated-mode");
  if(d.body) d.body.classList.add("integrated-mode");

  let st = d.getElementById("rooted-integrated-wrapper-style");
  if(!st){
    st = d.createElement("style");
    st.id = "rooted-integrated-wrapper-style";
    st.textContent = `
      html.integrated-mode .top.chrome,
      html.integrated-mode .bottom.chrome,
      html.integrated-mode .drawer,
      html.integrated-mode #buildMark{
        display:none !important;
      }
      html.integrated-mode .progress{
        bottom:0 !important;
      }
      html.integrated-mode .stage{
        inset:0 !important;
      }
    `;
    (d.head || d.documentElement).appendChild(st);
  }
  return true;
}

function click(lang, selector){
  const d = doc(lang);
  const el = d && d.querySelector(selector);
  if(!el) return false;
  el.dispatchEvent(new MouseEvent("click",{bubbles:true,cancelable:true,view:frames[lang].contentWindow}));
  return true;
}

function isStartVisible(lang){
  const d = doc(lang);
  const s = d && d.getElementById("start");
  return !!(s && !s.classList.contains("hide"));
}

function childApi(lang){
  try{
    return frames[lang] && frames[lang].contentWindow && frames[lang].contentWindow.ROOTED_PLAYER_API
      ? frames[lang].contentWindow.ROOTED_PLAYER_API
      : null;
  }catch(_){ return null; }
}

function setChildVolume(lang, value){
  if(!state.ready[lang]) return false;
  const api = childApi(lang);
  if(!api || typeof api.setVolume !== "function") return false;
  api.setVolume(Math.max(0, Math.min(100, Math.round(Number(value)))));
  return true;
}

function updateVolumeUI(){
  volumeLabel.textContent = `${state.volume}%`;
  muteBtn.textContent = state.volume === 0 ? "🔇" : (state.volume < 50 ? "🔉" : "🔊");
  muteBtn.title = state.volume === 0 ? "Unmute" : "Mute";
  muteBtn.setAttribute("aria-label", muteBtn.title);
}

function applyVolume(value){
  value = Math.max(0, Math.min(100, Math.round(Number(value) / 5) * 5));
  if(value > 0) state.lastNonZeroVolume = value;
  state.volume = value;
  if(state.active) setChildVolume(state.active, value);
  updateVolumeUI();
  showStatus(`Volume ${value}%`);
  showControls();
}

function volumeDown(){ applyVolume(state.volume - 5); }
function volumeUp(){ applyVolume(state.volume + 5); }

function toggleMute(){
  if(state.volume === 0){
    applyVolume(state.lastNonZeroVolume || 25);
  }else{
    state.lastNonZeroVolume = state.volume;
    applyVolume(0);
  }
}

function startOrRestart(lang){
  if(!state.ready[lang]) return false;
  const api = childApi(lang);
  if(!api || typeof api.resetAndPlay !== "function") return false;
  api.resetAndPlay();
  api.setVolume(state.volume);
  return true;
}

function fullyStop(lang){
  if(!state.ready[lang]) return false;
  const api = childApi(lang);
  if(!api || typeof api.stopAndReset !== "function") return false;
  api.stopAndReset();
  return true;
}

function showStatus(text){
  status.textContent = text;
  status.classList.remove("hidden");
  clearTimeout(state.statusTimer);
  state.statusTimer = setTimeout(()=>status.classList.add("hidden"),1800);
}

function showControls(pinned=false){
  if(!state.active) return;
  controls.classList.remove("hidden");
  controlToggle.classList.remove("hidden");
  clearTimeout(state.controlTimer);
  state.controlTimer = null;
  if(!pinned){
    state.controlTimer = setTimeout(()=>{
      if(state.active) controls.classList.add("hidden");
    },3000);
  }
}

function hideControls(){
  if(!state.active) return;
  controls.classList.add("hidden");
  clearTimeout(state.controlTimer);
  state.controlTimer = null;
}

function setActiveButtonState(lang){
  LANGS.forEach(code=>{
    frames[code].classList.toggle("active", code===lang);
    document.getElementById("header"+code).classList.toggle("active", code===lang);
  });
}

function activate(lang){
  if(!state.ready[lang]) return;
  normalizeChildIntegratedUI(lang);

  if(state.active && state.active !== lang){
    fullyStop(state.active);
  }

  setActiveButtonState(lang);
  state.active = lang;
  state.paused = false;
  pauseBtn.textContent = "⏸";
  pauseBtn.title = "Pause";
  pauseBtn.setAttribute("aria-label","Pause");

  if(!startOrRestart(lang)){
    showStatus("Edition playback API unavailable");
    return;
  }

  gate.classList.add("hidden");
  controlToggle.classList.remove("hidden");
  showControls();
  showStatus(`${LABELS[lang].name} · ${LABELS[lang].mode} · score reset`);
}

function previousScene(){
  const lang = state.active;
  if(!lang) return;
  const api = childApi(lang);
  if(!api || typeof api.prev !== "function"){ showStatus("Previous scene unavailable"); return; }
  api.prev();
  showStatus("Previous");
  showControls();
}

function nextScene(){
  const lang = state.active;
  if(!lang) return;
  const api = childApi(lang);
  if(!api || typeof api.next !== "function"){ showStatus("Next scene unavailable"); return; }
  api.next();
  showStatus("Next");
  showControls();
}

function pauseResume(){
  const lang = state.active;
  if(!lang) return;
  const api = childApi(lang);
  if(!api){ showStatus("Playback control unavailable"); return; }

  if(state.paused){
    api.resume();
    state.paused = false;
  }else{
    api.pause();
    state.paused = true;
  }

  pauseBtn.textContent = state.paused ? "▶" : "⏸";
  pauseBtn.title = state.paused ? "Resume" : "Pause";
  pauseBtn.setAttribute("aria-label", pauseBtn.title);
  showStatus(state.paused ? "Paused · page + score" : "Resumed · page + score");
  showControls();
}

function restart(){
  if(!state.active) return;
  const api = childApi(state.active);
  if(!api || typeof api.resetAndPlay !== "function"){ showStatus("Restart unavailable"); return; }
  api.resetAndPlay();
  api.setVolume(state.volume);
  state.paused = false;
  pauseBtn.textContent = "⏸";
  pauseBtn.title = "Pause";
  pauseBtn.setAttribute("aria-label","Pause");
  showStatus("Restarted · scene 1 + score 0:00");
}

function stop(){
  if(state.active) fullyStop(state.active);
  LANGS.forEach(code=>{
    frames[code].classList.remove("active");
    document.getElementById("header"+code).classList.remove("active");
  });
  state.active = null;
  state.paused = false;
  pauseBtn.textContent = "⏸";
  pauseBtn.title = "Pause";
  pauseBtn.setAttribute("aria-label","Pause");
  controls.classList.add("hidden");
  controlToggle.classList.add("hidden");
  gate.classList.remove("hidden");
}

function isFullscreen(){
  return document.fullscreenElement === app || document.webkitFullscreenElement === app;
}

function updateFullscreenButton(){
  if(!fullBtn) return;
  fullBtn.textContent = isFullscreen() ? "⤢" : "⛶";
  fullBtn.title = isFullscreen() ? "Exit Fullscreen" : "Fullscreen";
  fullBtn.setAttribute("aria-label", fullBtn.title);
}

function fullscreen(){
  try{
    if(isFullscreen()){
      if(document.exitFullscreen){
        const p = document.exitFullscreen();
        if(p && p.catch) p.catch(()=>{});
      }else if(document.webkitExitFullscreen){
        document.webkitExitFullscreen();
      }
      return;
    }
    if(app.requestFullscreen){
      const p = app.requestFullscreen();
      if(p && p.catch) p.catch(()=>{});
    }else if(app.webkitRequestFullscreen){
      app.webkitRequestFullscreen();
    }
  }catch(_){}
}

function updateLoadingText(){
  const readyCount = LANGS.filter(code=>state.ready[code]).length;
  if(readyCount === LANGS.length){
    loadingText.textContent = "Select KR, EN, or RU to begin continuous playback.";
  } else if(readyCount >= 1){
    loadingText.textContent = `${readyCount} edition(s) ready. Remaining editions are still loading…`;
  } else {
    loadingText.textContent = "Loading digital editions…";
  }
}

function markReady(lang){
  normalizeChildIntegratedUI(lang);
  state.ready[lang] = true;
  const startBtn = document.getElementById("start"+lang);
  if(startBtn) startBtn.disabled = false;
  updateLoadingText();
}

LANGS.forEach(code=>{
  frames[code].addEventListener("load",()=>markReady(code));
  document.getElementById("start"+code).addEventListener("click",()=>activate(code));
  document.getElementById("header"+code).addEventListener("click",()=>activate(code));
});

muteBtn.addEventListener("click",toggleMute);
volDownBtn.addEventListener("click",volumeDown);
volUpBtn.addEventListener("click",volumeUp);
updateVolumeUI();

if(prevBtn) prevBtn.addEventListener("click",previousScene);
pauseBtn.addEventListener("click",pauseResume);
if(nextBtn) nextBtn.addEventListener("click",nextScene);
document.getElementById("restartBtn").addEventListener("click",restart);
document.getElementById("stopBtn").addEventListener("click",stop);
fullBtn.addEventListener("click",fullscreen);

controlToggle.addEventListener("click",()=>{
  if(controls.classList.contains("hidden")){
    showControls(true);
  }else{
    hideControls();
  }
});

document.addEventListener("mousemove",e=>{
  if(!state.active) return;
  const revealZone = Math.max(100, window.innerHeight * 0.14);
  if(e.clientY >= window.innerHeight - revealZone){
    showControls();
  }
});

document.addEventListener("touchstart",()=>{
  if(state.active) showControls();
},{passive:true});

document.addEventListener("keydown",e=>{
  if(e.key===" " && state.active){e.preventDefault();pauseResume();}
  const lower = e.key.toLowerCase();
  LANGS.forEach(code=>{
    if(lower === LABELS[code].key) activate(code);
  });
});

document.addEventListener("fullscreenchange", updateFullscreenButton);
document.addEventListener("webkitfullscreenchange", updateFullscreenButton);
updateFullscreenButton();

window.ROOTED_INTEGRATED_PLAYER = {
  activate,previousScene,nextScene,pauseResume,restart,stop,
  getState:()=>JSON.parse(JSON.stringify(state))
};
