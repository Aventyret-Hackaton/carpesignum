/* Carpe Signum – webbversion.
 * Samma flöde, texter och "astrologi" som iPhone-appen.
 * Webbläsare i telefoner kan inte skanna Bluetooth, så signalerna här är simulerade
 * (samma som appens demoläge). Gyro, stjärnstoft och väder fungerar som i appen. */
"use strict";

// ───────────── Biblioteket (samma texter som CarpeSignum/Library.swift) ─────────────
const Library = {
  headlines: [
    "{planet} står i ditt {planetord} rum",
    "{planet} har gått in i ditt {planetord} rum",
    "{planet} vandrar genom ditt {planetord} rum",
    "{planet} har tagit plats i {planetrum}",
    "{planet} har vänt sig mot dig",
  ],
  openings: [
    "Med en signalstyrka på {dbm} i {teckenrum} bör du undvika viktiga beslut före lunch.",
    "Signalen står i {dbm} i {teckenrum}. Det är ett gynnsamt läge för att säga nej till saker du redan sagt ja till.",
    "{teckenrum} lyser idag med {dbm}. Det har inte hänt sedan i tisdags, och då gick det som det gick.",
    "När {tecken} mäter {dbm} på morgonen bör man inte lita på sitt eget omdöme förrän efter klockan tre.",
    "En signalstyrka på {dbm} i {teckenrum} talar för förändring. Förändringen är liten och gäller troligen din lunch.",
    "{tecken} står i {dbm} idag. Det är starkare än vad som är lämpligt för en onsdag, oavsett vilken dag det är.",
    "Dagens starkaste signal, {dbm}, faller i {teckenrum}. Gör inga större inköp, särskilt inte av sladdar.",
    "Med {dbm} i {teckenrum} är du ovanligt mottaglig. Undvik möten där någon säger ”snabb fråga”.",
    "Signalerna i {teckenrum} ligger på {dbm}. Det är ett tecken på att du har rätt, men inte idag.",
    "{dbm} i {teckenrum} innebär att dina relationer stärks, framför allt den till din laddare.",
    "När signalen når {dbm} i {teckenrum} bör man vara försiktig med att svara ”alla” på e-post.",
    "{teckenrum} mäts idag till {dbm}. Den som föds under denna signal blir sällan tekniskt ansvarig, men ofta tillfrågad.",
  ],
  planets: [
    "{planet} har dragit sig tillbaka till det {planetord} rummet. Det talar för tålamod, men emot mjölkskum.",
    "{planet} står i ditt {planetord} rum. Det talar för tålamod, men emot mjölkskum.",
    "{planet} har gått in i {planetrum}. Det är ett gott tecken för den som väntar, och ett dåligt för den som har bråttom.",
    "{planet} befinner sig i ditt {planetord} rum. Lyssna på den, även om den bara säger ett enda ljud.",
    "Med {planet} i {planetrum} bör du hålla dina åsikter om kontorsmöbler för dig själv.",
    "{planet} står i {planetnr}. Det är en konstellation som brukar föregå missförstånd i kalendern.",
    "När {planet} vandrar in i ditt {planetord} rum blir det svårare att hitta rätt mötesrum.",
    "{planet} står stilla i {planetrum}. Gör du detsamma kommer dagen att gå bra.",
    "{planet} i {planetnr} talar för samarbete. Samarbetet kommer inte att fungera, men det talar för det.",
    "{planet} har tagit plats i ditt {planetord} rum och kommer att stanna där tills någon flyttar den.",
    "Det är ovanligt att {planet} står i {planetrum} så här tidigt i veckan. Ta det som en varning eller ett erbjudande.",
    "{planet} i ditt {planetord} rum innebär att någon nära dig har en åsikt om din kaffe.",
    "{planet} står i opposition till din telefon. Låt dem lösa det själva.",
  ],
  followers: [
    "{foljare} har följt dig i {tid}. Det är ingen slump.",
    "{foljare} har varit nära dig i {tid}. Den vet mer än den säger.",
    "Under {tid} har {foljare} hållit sig inom två meter. Fråga dig varför.",
    "{foljare} har inte lämnat din sida på {tid}. Det är antingen lojalitet eller en kabel.",
    "I {tid} har {foljare} lyssnat. Den har inte sagt något, och det är det mest oroande.",
    "{foljare} har funnits i din närhet i {tid}. Det binder er samman, men inte juridiskt.",
    "{foljare} har sänt mot dig i {tid}. Du behöver inte svara, men du bör veta om det.",
    "Bland {antal} enheter har {foljare} valt dig. Den har gjort det i {tid}.",
    "{foljare} har varit med dig i {tid}. Ni är nu kompatibla, även om det inte gäller er.",
    "Svagast idag är {svagast}. Den signalen är någon annans problem. {foljare} däremot har följt dig i {tid}.",
  ],
  todos: [
    ["Håll dig borta från brunnar.", "Drick ditt vatten från vänster sida av glaset.", "Ladda inte telefonen före lunch.", "Säg ”tack” till hissen.", "Ta trapporna, men bara nedåt.", "Ställ inte koppen på skrivbordets högra halva.", "Byt sida på sängen ikväll.", "Öppna inga flikar som du inte tänker stänga.", "Lägg telefonen med skärmen uppåt. Den vill se.", "Undvik ord som börjar på B."],
    ["Hälsa på {planet} innan du hälsar på en människa.", "Undvik skrivaren efter klockan två.", "Sitt inte närmare än två meter från {planet}.", "Byt plats i mötesrummet varje gång någon säger ”synergi”.", "Sätt på dig skorna i omvänd ordning.", "Ät lunch i {planetrum}, oavsett var den serveras.", "Stäng av Bluetooth i elva minuter. Säg inget till någon.", "Fråga {planet} om lov innan du tar en kopp.", "Gå ett varv runt bordet innan du sätter dig.", "Byt namn på din telefon till något mer ödmjukt."],
    ["Gå baklänges till ditt nästa möte.", "Svara bara på mejl som innehåller ett udda antal ord.", "Ta inga beslut i rum med fler än tre uttag.", "Viska ditt namn till {planet} tre gånger.", "Bär dina hörlurar på fel öron hela eftermiddagen.", "Presentera dig med ditt tecken istället för ditt namn.", "Låt {planet} bestämma vad du äter till middag.", "Ställ alla stolar i {planetrum} så att de pekar mot routern.", "Tacka nej till allt som erbjuds i fyrkantiga förpackningar.", "Gå bara på varannan platta i korridoren."],
    ["Säg upp din prenumeration på något du tycker om.", "Flytta in i {planetrum} tills signalen stabiliseras.", "Avboka alla möten där {planet} inte är inbjuden.", "Ge din telefon till den person du litar minst på, i en timme.", "Ändra din adress till {planetrum}.", "Ring din mamma och säg att {planet} hälsar.", "Sälj soffan. Den står i fel rum.", "Byt tandkräm till ett märke du aldrig har hört talas om.", "Tatuera in {dbm} någonstans där ingen ser det.", "Lämna jobbet tidigt och kom tillbaka sent, samma dag."],
    ["Gör slut med din partner och lämna landet.", "Sälj din bostad och flytta närmare {planet}.", "Byt namn till {tecken} och flytta till en annan tidszon.", "Säg upp dig och starta ett företag tillsammans med {planet}.", "Lämna allt du äger i {planetrum} och börja om på nytt i hallen.", "Gifta dig med den första enhet som går under {dbm}.", "Flytta till en ö där det saknas Bluetooth. Ta inte med telefonen.", "Testamentera allt du äger till {planet}.", "Byt kontinent före klockan fem.", "Gå i exil i {planetrum} tills Merkurius har bestämt sig."],
  ],
};

// ───────────── Astrologin (samma som CarpeSignum/Astrology.swift) ─────────────
const ROMANS = ["I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII"];
const ORDINALS = ["första","andra","tredje","fjärde","femte","sjätte","sjunde","åttonde","nionde","tionde","elfte","tolfte"];
const OFFICE_PLANETS = ["Kaffemaskinen","Skrivaren","Mikron","Diskmaskinen","Kylskåpet"];
const MAKERS = { 0x004C:"Apple", 0x0006:"Microsoft", 0x0075:"Samsung", 0x00C4:"LG", 0x0065:"HP", 0x00E0:"Google", 0x0087:"Garmin", 0x012D:"Sony", 0x009E:"Bose" };

function house(rssi) {
  const number = Math.max(1, Math.min(12, Math.trunc((rssi + 100) / 4)));
  let room;
  if (rssi >= -50) room = ["badrummet","badrum"];
  else if (rssi >= -60) room = ["sovrummet","sovrum"];
  else if (rssi >= -75) room = ["köket","kök"];
  else if (rssi >= -85) room = ["vardagsrummet","vardagsrum"];
  else room = ["hallen","hall"];
  return { number, roman: ROMANS[number-1], ordinal: ORDINALS[number-1], room: room[0], roomPlain: room[1] };
}

function sign(signal) {
  const m = signal ? MAKERS[signal.maker] : undefined;
  switch (m) {
    case "Apple": return ["Oxen","Oxens"];
    case "Samsung": return ["Skorpionen","Skorpionens"];
    case "Microsoft": return ["Vattumannen","Vattumannens"];
    case "LG": return ["Kräftan","Kräftans"];
    case "HP": return ["Stenbocken","Stenbockens"];
    case "Google": return ["Tvillingarna","Tvillingarnas"];
    case "Garmin": return ["Skytten","Skyttens"];
    case "Sony": case "Bose": return ["Vågen","Vågens"];
    case undefined: return ["Fiskarna","Fiskarnas"];
    default: return ["Lejonet","Lejonets"];
  }
}

const planetCache = {};
function displayNames(signals) {
  const names = {};
  const present = new Set(signals.map(s => s.id));
  const free = OFFICE_PLANETS.filter(n => !Object.entries(planetCache).some(([id, v]) => present.has(id) && v === n));
  signals.filter(s => !s.name).sort((a,b) => a.id.localeCompare(b.id)).forEach(s => {
    if (!planetCache[s.id] && free.length && s.rssi > -85 && s.rssi < -55) planetCache[s.id] = free.shift();
  });
  for (const s of signals) {
    if (s.name) names[s.id] = s.name;
    else if (planetCache[s.id]) names[s.id] = planetCache[s.id];
    else if (MAKERS[s.maker]) names[s.id] = `Okänd ${MAKERS[s.maker]}-enhet`;
    else names[s.id] = "Okänd enhet";
  }
  return names;
}
const isPlanet = n => OFFICE_PLANETS.includes(n);
const dbmShort = r => r < 0 ? `−${Math.abs(r)}` : `${r}`;
const dbm = r => `${dbmShort(r)} dBm`;
function duration(sec) {
  const m = Math.max(1, Math.floor(sec / 60));
  return m < 60 ? `${m} min` : `${Math.floor(m/60)} h ${String(m%60).padStart(2,"0")} min`;
}
function durationWords(sec) {
  const w = ["noll","en","två","tre","fyra","fem","sex","sju","åtta","nio","tio","elva","tolv","tretton","fjorton","femton","sexton","sjutton","arton","nitton","tjugo"];
  const m = Math.max(1, Math.floor(sec / 60));
  if (m >= 60) { const h = Math.floor(m/60); return h === 1 ? "en timme" : (h <= 20 ? `${w[h]} timmar` : `${h} timmar`); }
  return m === 1 ? "en minut" : (m <= 20 ? `${w[m]} minuter` : `${m} minuter`);
}

// ───────────── Simulerade signaler (samma som appens demoläge) ─────────────
const Scanner = {
  signals: [],
  start() {
    if (this.signals.length) return;
    const now = Date.now();
    const samples = [
      ["Fridas iPhone",0x004C,-41,3*3600+300], ["Apple Watch",0x004C,-45,7200], [null,0x004C,-52,3*3600+300],
      ["AirPods",0x004C,-64,1800], [null,0x0075,-71,900], [null,0x0006,-76,600], [null,0x00C4,-68,2400],
      [null,0x0065,-83,300], [null,0x004C,-88,120], [null,null,-92,60], [null,0x004C,-95,60], [null,0x0075,-81,400],
    ];
    this.signals = samples.map((s,i) => ({ id: `a${String(i+1).padStart(3,"0")}`, name: s[0], maker: s[1], rssi: s[2], firstSeen: now - s[3]*1000 }));
    for (let i = 0; i < 29; i++) this.signals.push({ id: `b${String(i).padStart(3,"0")}`, name: null, maker: i % 4 === 0 ? 0x0006 : 0x004C, rssi: -84 - (i % 14), firstSeen: now - 60000 });
    setInterval(() => { for (const s of this.signals) s.rssi = Math.max(-100, Math.min(-35, s.rssi + Math.round(Math.random()*4 - 2))); }, 1000);
  },
  current() { return [...this.signals].sort((a,b) => b.rssi - a.rssi); },
};

// ───────────── Slumptal som blir desamma samma dag ─────────────
function hash(text) { let h = 0x811c9dc5; for (const c of new TextEncoder().encode(text)) { h ^= c; h = Math.imul(h, 0x01000193) >>> 0; } return h >>> 0; }
function seeded(seed) { let s = seed >>> 0; return () => { s = (s + 0x6D2B79F5) >>> 0; let t = s; t = Math.imul(t ^ (t >>> 15), t | 1); t ^= t + Math.imul(t ^ (t >>> 7), t | 61); return ((t ^ (t >>> 14)) >>> 0) / 4294967296; }; }
const pick = (arr, rnd) => arr[Math.floor(rnd() * arr.length)];
const dayKey = d => `${d.getFullYear()}-${d.getMonth()+1}-${d.getDate()}`;

function fill(template, values) {
  let text = template;
  for (const [k, v] of Object.entries(values)) text = text.split(`{${k}}`).join(v);
  // Stor bokstav i början av varje mening.
  let out = "", cap = true;
  for (const ch of text) {
    if (cap && /\p{L}/u.test(ch)) { out += ch.toUpperCase(); cap = false; }
    else { out += ch; if (".!?".includes(ch)) cap = true; else if (!/\s/.test(ch) && ch !== "”") cap = false; }
  }
  return out;
}
const lowerFirst = t => (isPlanet(t) || t.startsWith("Okänd ")) ? t[0].toLowerCase() + t.slice(1) : t;

// ───────────── AI-astrologen (samma som CarpeSignum/Reading.swift) ─────────────
function read(input, now = new Date()) {
  const signals = input.length ? input : [{ id: "x", name: null, maker: null, rssi: -90, firstSeen: now - 600000 }];
  const names = displayNames(signals);
  const name = s => names[s.id] || "Okänd enhet";
  const sorted = [...signals].sort((a,b) => b.rssi - a.rssi);
  const strongest = sorted[0], weakest = sorted[sorted.length-1];
  const [signName, signGen] = sign(strongest);

  const planetSignals = sorted.filter(s => isPlanet(name(s)));
  const fallback = sorted.slice(1);
  const first = planetSignals[0] || fallback[0] || strongest;
  const second = planetSignals[1] || fallback.find(s => s.id !== first.id) || first;

  const follower = signals.reduce((a,b) => a.firstSeen <= b.firstSeen ? a : b);
  const followerName = name(follower);
  const followerSec = (now - follower.firstSeen) / 1000;
  const followerPhrase = followerName.startsWith("Okänd ") ? "en o" + followerName.slice(1) : followerName;

  const values = planet => { const h = house(planet.rssi); return {
    dbm: dbm(strongest.rssi), svagast: dbm(weakest.rssi), tecken: signName, teckenrum: `${signGen} rum`,
    rum: house(strongest.rssi).room, planet: lowerFirst(name(planet)), planetnr: h.roman, planetrum: h.room,
    planetord: h.ordinal, foljare: followerPhrase, tid: durationWords(followerSec), antal: `${signals.length}` }; };
  const main = values(first), other = values(second);
  const rnd = seeded(hash(`${dayKey(now)}|${signName}|${name(first)}`));

  const headline = fill(pick(Library.headlines, rnd), main);
  const paragraphs = [fill(pick(Library.openings, rnd), main), fill(pick(Library.planets, rnd), other)];
  const quote = fill(pick(Library.followers, rnd), main);
  const fh = house(first.rssi);
  const chips = [dbm(strongest.rssi), `${name(first)} i ${fh.roman}`, `${followerName.replace("Okänd ","")} · ${duration(followerSec)}`];

  const basisSignals = [];
  for (const s of [follower, first, second, strongest, ...sorted]) { if (!basisSignals.some(b => b.id === s.id)) basisSignals.push(s); if (basisSignals.length === 4) break; }
  const basis = basisSignals.map(s => { const h = house(s.rssi);
    return isPlanet(name(s)) ? { name: name(s), detail: `${h.roman} · ${h.roomPlain} · ${dbmShort(s.rssi)}` }
                             : { name: name(s), detail: `${duration((now - s.firstSeen)/1000)} · ${dbmShort(s.rssi)}` }; });

  const todos = [];
  for (let level = 1; level <= 5; level++) {
    const t = pick(Library.todos[level-1], rnd);
    let source;
    if (t.includes("{planet}") || t.includes("{planetrum}")) source = `${name(first)} i ${fh.roman}`;
    else if (level === 4) source = "Merkurius i retrograd";
    else { const p = level === 5 ? strongest : sorted[Math.floor(rnd() * Math.min(sorted.length, 8))]; source = `${name(p)} · ${dbm(p.rssi)}`; }
    todos.push({ id: level, level, text: fill(t, main), source, done: false });
  }
  return { date: now.getTime(), day: dayKey(now), headline, paragraphs, quote, chips, basis,
           weighing: `Väger ${lowerFirst(name(first))} mot ${lowerFirst(name(second))}`, todos, count: signals.length };
}

// ───────────── Sparat för dagen (fungerar även om lagring är blockerad) ─────────────
const store = {
  get(k) { try { return JSON.parse(localStorage.getItem(k)); } catch { return null; } },
  set(k, v) { try { localStorage.setItem(k, JSON.stringify(v)); } catch {} },
  del(k) { try { localStorage.removeItem(k); } catch {} },
};
let reading = store.get("cs.reading");
if (!reading || reading.day !== dayKey(new Date())) reading = null;

// ───────────── Väder från Open-Meteo (öppet API, ingen nyckel) ─────────────
const CITIES = [["Brasília",-15.79,-47.88],["Ulaanbaatar",47.92,106.92],["Reykjavik",64.15,-21.94],["Nairobi",-1.29,36.82],["Lima",-12.05,-77.04],["Wellington",-41.29,174.78],["Tasjkent",41.3,69.24],["Anchorage",61.22,-149.9],["Hobart",-42.88,147.33],["Timbuktu",16.77,-3.01],["Longyearbyen",78.22,15.65],["Kiruna",67.86,20.23]];
let weather = null;
async function fetchWeather() {
  if (weather) return;
  const rnd = seeded(hash(dayKey(new Date())));
  const [city, lat, lon] = pick(CITIES, rnd);
  const ord = pick(ORDINALS, rnd);
  try {
    const r = await fetch(`https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,weather_code`);
    const d = (await r.json()).current;
    const c = d.weather_code, t = Math.round(d.temperature_2m);
    const phrase = c === 0 ? "Det är klart" : c <= 2 ? "Det är halvklart" : c === 3 ? "Det är mulet" : (c === 45 || c === 48) ? "Det är dimmigt"
      : (c >= 51 && c <= 57) ? "Det duggar" : ((c >= 61 && c <= 67) || (c >= 80 && c <= 82)) ? "Det regnar"
      : ((c >= 71 && c <= 77) || c === 85 || c === 86) ? "Det snöar" : c >= 95 ? "Det åskar" : "Vädret är obestämbart";
    weather = { label: `Fjärrsignal · ${city}`, line: `${phrase}, ${t < 0 ? "−" + Math.abs(t) : t} °C. Det påverkar ditt ${ord} rum.` };
    if (state.phase === "main" && state.tab === "horoscope") render();
  } catch { /* utan internet visas ingen väderrad */ }
}

// ───────────── Gyro: skärmen nedåt konsulterar signalerna ─────────────
let faceDown = false;
function onOrientation(e) {
  if (e.beta == null) return;
  const b = Math.abs(e.beta);
  if (!faceDown && b > 150) { faceDown = true; onFaceDown(); }
  else if (faceDown && b < 120) { faceDown = false; onFaceUp(); }
}
async function enableMotion() {
  try {
    if (typeof DeviceOrientationEvent !== "undefined" && typeof DeviceOrientationEvent.requestPermission === "function") {
      if (await DeviceOrientationEvent.requestPermission() !== "granted") return;
    }
    window.addEventListener("deviceorientation", onOrientation);
  } catch { /* inget gyro, inget problem */ }
}
if (typeof DeviceOrientationEvent !== "undefined" && typeof DeviceOrientationEvent.requestPermission !== "function") enableMotion();

// ───────────── Stjärnstoft (konfetti) ─────────────
const canvas = document.getElementById("stardust");
const ctx = canvas.getContext("2d");
let bursts = [], animating = false;
function stardust() {
  const colors = ["#BCA7FF","#BCA7FF","rgba(188,167,255,.6)","rgba(236,232,223,.7)","#DBD8DE"];
  bursts.push({ start: performance.now(), p: Array.from({length: 70}, () => ({
    x: Math.random(), vx: Math.random()*80-40, vy: 30+Math.random()*150, size: 2+Math.random()*3,
    spin: Math.random()*8-4, star: Math.random() < .3, color: colors[Math.floor(Math.random()*colors.length)] })) });
  if (!animating) { animating = true; requestAnimationFrame(drawDust); }
}
function drawDust(now) {
  const dpr = window.devicePixelRatio || 1, W = innerWidth, H = innerHeight;
  if (canvas.width !== W*dpr) { canvas.width = W*dpr; canvas.height = H*dpr; }
  ctx.setTransform(dpr,0,0,dpr,0,0); ctx.clearRect(0,0,W,H);
  const life = 3.5;
  bursts = bursts.filter(b => (now - b.start)/1000 < life);
  for (const b of bursts) {
    const t = (now - b.start)/1000, fade = 1 - Math.max(0, (t - life*.6)/(life*.4));
    for (const p of b.p) {
      const x = p.x*W + p.vx*t, y = -20 + p.vy*t + 80*t*t;
      ctx.save(); ctx.globalAlpha = fade; ctx.translate(x,y); ctx.rotate(p.spin*t); ctx.fillStyle = p.color;
      if (p.star) { ctx.font = `${p.size*2.2}px sans-serif`; ctx.textAlign = "center"; ctx.textBaseline = "middle"; ctx.fillText("✶",0,0); }
      else { ctx.beginPath(); ctx.arc(0,0,p.size/2,0,Math.PI*2); ctx.fill(); }
      ctx.restore();
    }
  }
  if (bursts.length) requestAnimationFrame(drawDust); else { animating = false; ctx.clearRect(0,0,W,H); }
}

// ───────────── Gränssnittet ─────────────
const app = document.getElementById("app");
const esc = s => String(s).replace(/[&<>"]/g, c => ({ "&":"&amp;", "<":"&lt;", ">":"&gt;", '"':"&quot;" })[c]);
const DAYS = ["SÖN","MÅN","TIS","ONS","TORS","FRE","LÖR"], MONTHS = ["JAN","FEB","MARS","APR","MAJ","JUNI","JULI","AUG","SEP","OKT","NOV","DEC"];
const shortDay = ms => { const d = new Date(ms); return `${DAYS[d.getDay()]} ${d.getDate()} ${MONTHS[d.getMonth()]}`; };
const ICON_HOROSKOP = `<svg viewBox="0 0 18 18" fill="none"><path d="M9 1.5V9M9 9V16.5M9 9H1.5M9 9H16.5M9 9L4 4M9 9L14 14M9 9L14 4M9 9L4 14" stroke="currentColor"/></svg>`;
const ICON_GUIDE = `<svg viewBox="0 0 18 18" fill="none"><path d="M1.5 2.5H5.5V6.5H1.5V2.5Z" stroke="currentColor"/><path d="M1.5 11.5H5.5V15.5H1.5V11.5Z" stroke="currentColor"/><path d="M8.5 4.5H16.5M8.5 13.5H16.5" stroke="currentColor"/></svg>`;

const state = { phase: reading ? "main" : (store.get("cs.seenIntro") ? "scanning" : "start"), tab: "horoscope" };
let timers = [];
function go(phase, tab) { timers.forEach(clearTimeout); timers = []; state.phase = phase; if (tab) state.tab = tab; render(); }

function render() {
  closeOverlay();
  if (state.phase === "start") return renderStart();
  if (state.phase === "scanning") return renderScanning();
  if (state.phase === "consulting") return renderConsulting();
  if (!reading) return go("scanning");
  app.innerHTML = (state.tab === "horoscope" ? horoscopeHTML() : guideHTML()) + flikradHTML();
  bindMain();
}

function renderStart() {
  app.innerHTML = `
  <section class="screen">
    <img src="assets/Logotype.svg" alt="Carpe Signum" width="102" height="72">
    <p class="small" style="padding:20px 0 4px">Stjärnorna var aldrig nära nog</p>
    <div style="height:75px"></div>
    <div class="karta"><img src="assets/Signalkarta.svg" alt=""></div>
    <div class="flex" style="min-height:24px"></div>
    <button class="knapp" id="koppla">Koppla till Bluetooth</button>
    <p class="small center" style="margin-top:16px">(Bara astrologen får se din data)</p>
    <p class="label center c-faint" style="margin-top:10px;font-size:9px">Webbversion · signalerna är simulerade</p>
  </section>`;
  document.getElementById("koppla").onclick = () => { store.set("cs.seenIntro", true); enableMotion(); go("scanning"); };
}

function renderScanning() {
  Scanner.start();
  const started = performance.now(), DURATION = 7000;
  app.innerHTML = `
  <section class="screen">
    <p class="label c-faint" id="klocka">Skannar · 00:00</p>
    <div style="height:40px"></div>
    <h1 class="title">Hämtar signaler…</h1>
    <p class="small" id="antal" style="margin-top:8px">&nbsp;</p>
    <div class="flex" style="min-height:16px;max-height:64px"></div>
    <div class="karta snurrar"><img src="assets/Signalkarta.svg" alt=""></div>
    <div class="flex" style="min-height:16px"></div>
    <div class="rader" id="rader" style="min-height:185px"></div>
  </section>`;
  const tick = () => {
    if (state.phase !== "scanning") return;
    const el = Math.min(DURATION, performance.now() - started) / 1000;
    const sigs = Scanner.current(), names = displayNames(sigs);
    const rooms = new Set(sigs.map(s => house(s.rssi).room)).size;
    document.getElementById("klocka").textContent = `Skannar · 00:${String(Math.floor(el)).padStart(2,"0")}`;
    document.getElementById("antal").textContent = `${sigs.length} enheter · ${rooms} rum hittills`;
    document.getElementById("rader").innerHTML = sigs.slice(0,4).map(s => radHTML(names[s.id], dbm(s.rssi))).join("");
    timers.push(setTimeout(tick, 500));
  };
  tick();
  timers.push(setTimeout(() => { reading = read(Scanner.current()); store.set("cs.reading", reading); go("main", "horoscope"); }, DURATION));
}

function renderConsulting() {
  app.innerHTML = `
  <section class="screen">
    <p class="label c-faint">Konsulterar signalerna</p>
    <div style="height:40px"></div>
    <h1 class="title">Tar fram din guide…</h1>
    <p class="small" style="margin-top:8px">${esc(reading.weighing)}</p>
    <div class="flex" style="min-height:16px;max-height:64px"></div>
    <div class="karta snurrar"><img src="assets/Signalkarta.svg" alt=""></div>
    <div class="flex" style="min-height:16px"></div>
    <div class="forlopp"><div id="fyllt"></div></div>
  </section>`;
  requestAnimationFrame(() => requestAnimationFrame(() => { const f = document.getElementById("fyllt"); if (f) f.style.width = "100%"; }));
  state.timeIsUp = false;
  timers.push(setTimeout(() => { state.timeIsUp = true; finishConsulting(); }, 3000));
}
function finishConsulting() { if (state.phase === "consulting" && state.timeIsUp && !faceDown) go("main", "guide"); }
function onFaceDown() { if (state.phase === "main" && state.tab === "horoscope" && reading) go("consulting"); }
function onFaceUp() { finishConsulting(); }

const radHTML = (namn, varde) => `<div class="rad"><img src="assets/IkonPunkt.svg" alt=""><span class="namn">${esc(namn)}</span><span class="label">${esc(varde)}</span></div>`;

function horoscopeHTML() {
  return `
  <section class="screen scroll">
    <div class="topprad">
      <p class="label c-accent" id="datum">Dagens horoskop: ${shortDay(reading.date)}</p>
      <button id="forklaring" aria-label="Så räknade vi"><img src="assets/IkonForklaring.svg" alt=""></button>
    </div>
    <div style="height:50px;flex-shrink:0"></div>
    <h1 class="title">${esc(reading.headline)}</h1>
    <p class="reading" style="margin-top:24px">${esc(reading.paragraphs[0])}</p>
    <p class="reading" style="margin-top:12px">${esc(reading.paragraphs[1])}</p>
    <p class="accentText citat" style="margin-top:32px">${esc(reading.quote)}</p>
    ${weather ? `<p class="label c-faint" style="margin-top:24px">${esc(weather.label)}</p><p class="small" style="margin-top:6px">${esc(weather.line)}</p>` : ""}
    <div class="chips" style="margin-top:48px">${reading.chips.map(c => `<span class="chip label c-faint">${esc(c)}</span>`).join("")}</div>
    <div class="flex" style="min-height:32px"></div>
    <button class="knapp" id="guida">Guida mig rätt</button>
    <p class="label c-faint center" style="margin-top:12px">Eller lägg telefonen med skärmen nedåt</p>
  </section>`;
}

function guideHTML() {
  return `
  <section class="screen scroll">
    <p class="label c-accent">Guide: ${shortDay(reading.date)}</p>
    <div style="height:40px;flex-shrink:0"></div>
    <h1 class="title">Att göra</h1>
    <p class="small" style="margin-top:6px">för att rädda din själ</p>
    <div style="height:20px;flex-shrink:0"></div>
    ${reading.todos.map(t => `
      <button class="todo ${t.done ? "klar" : ""}" data-id="${t.id}">
        <span class="ruta">${t.done ? `<img src="assets/IkonBock.svg" alt="">` : ""}</span>
        <span class="text"><span class="body">${esc(t.text)}</span><span class="label c-faint">${esc(t.source)}</span></span>
        <span class="label ${t.done ? "c-faint" : "c-accent"}">${t.level}/5</span>
      </button>`).join("")}
    <div class="flex" style="min-height:52px"></div>
    <p class="label c-faint center">Ny guide i morgon kl. 07:00</p>
  </section>`;
}

const flikradHTML = () => `
  <nav class="flikrad">
    <button class="flik ${state.tab === "horoscope" ? "aktiv" : ""}" data-tab="horoscope">${ICON_HOROSKOP}<span class="label" style="color:inherit">Horoskop</span></button>
    <button class="flik ${state.tab === "guide" ? "aktiv" : ""}" data-tab="guide">${ICON_GUIDE}<span class="label" style="color:inherit">Guide</span></button>
  </nav>`;

function bindMain() {
  app.querySelectorAll(".flik").forEach(b => b.onclick = () => go("main", b.dataset.tab));
  if (state.tab === "horoscope") {
    fetchWeather();
    document.getElementById("guida").onclick = () => go("consulting");
    document.getElementById("forklaring").onclick = showBasis;
    // Dolt reglage för demon: håll inne på datumet.
    const d = document.getElementById("datum"); let lp;
    d.addEventListener("pointerdown", () => { lp = setTimeout(showMenu, 1200); });
    ["pointerup","pointerleave","pointercancel"].forEach(ev => d.addEventListener(ev, () => clearTimeout(lp)));
  } else {
    app.querySelectorAll(".todo").forEach(b => b.onclick = () => {
      const t = reading.todos.find(x => x.id === Number(b.dataset.id));
      if (!t.done) stardust();
      t.done = !t.done; store.set("cs.reading", reading); render();
    });
  }
}

function overlay(html) {
  closeOverlay();
  const o = document.createElement("div"); o.className = "dimma"; o.id = "dimma"; o.innerHTML = html;
  o.addEventListener("click", e => { if (e.target === o) closeOverlay(); });
  document.body.appendChild(o); return o;
}
function closeOverlay() { document.getElementById("dimma")?.remove(); }

function showBasis() {
  const o = overlay(`
  <div class="ark">
    <div class="handtag"></div>
    <p class="label c-accent" style="margin-top:28px">Så räknade vi</p>
    <h2 class="title" style="margin-top:10px">Underlaget för dagens horoskop</h2>
    <p class="reading" style="margin-top:12px">Varje enhet du varit nära har vägts efter signalstyrka och tid. Ditt rum är där signalen var starkast.</p>
    <div class="rader" style="margin-top:24px">${reading.basis.map(b => radHTML(b.name, b.detail)).join("")}</div>
    <button class="knapp kontur" id="stang" style="margin-top:28px">Stäng</button>
  </div>`);
  o.querySelector("#stang").onclick = closeOverlay;
}

function showMenu() {
  const o = overlay(`
  <div class="ark">
    <div class="handtag"></div>
    <p class="label c-accent" style="margin-top:28px">Kosmos</p>
    <button class="knapp" id="igen" style="margin-top:20px">Läs signalerna igen</button>
    <button class="knapp kontur" id="avbryt" style="margin-top:12px">Avbryt</button>
  </div>`);
  o.querySelector("#igen").onclick = () => { reading = null; store.del("cs.reading"); go("scanning"); };
  o.querySelector("#avbryt").onclick = closeOverlay;
}

render();
