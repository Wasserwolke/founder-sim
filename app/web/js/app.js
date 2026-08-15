import {state,clamp,passTime,timeString} from "./state.js";
import {scenes} from "./scenes.js";
const env=document.querySelector("#environment");
const rain=document.querySelector("#rain");
const darkness=document.querySelector("#darkness");
const deskHotspots=document.querySelector("#deskHotspots");
const mapHotspots=document.querySelector("#mapHotspots");
const back=document.querySelector("#backButton");
const toast=document.querySelector("#toast");
function setImageWithFallback(path,placeholder){const img=new Image();img.onload=()=>{env.classList.remove("missing");env.style.backgroundImage=`url("${path}")`;};img.onerror=()=>{env.style.backgroundImage="none";env.classList.add("missing");env.dataset.placeholder=placeholder;};img.src=path;}
function renderHUD(){document.querySelector("#money").textContent=`${state.money} EUR`;document.querySelector("#income").textContent=`${state.income} EUR`;document.querySelector("#expenses").textContent=`${state.expenses} EUR`;document.querySelector("#clock").textContent=timeString();for(const key of ["energy","focus","health"]){document.querySelector(`#${key}`).textContent=state[key];document.querySelector(`#${key}Bar`).style.width=`${clamp(state[key])}%`;}const late=Math.max(0,(state.minutes-21*60)/240);const tired=(100-state.energy)/100;darkness.style.opacity=String(Math.min(.55,late*.22+tired*.18));}
function showToast(text){toast.textContent=text;toast.classList.remove("hidden");clearTimeout(showToast.timer);showToast.timer=setTimeout(()=>toast.classList.add("hidden"),2200);}
function renderScene(){const scene=scenes[state.scene];setImageWithFallback(scene.asset,scene.placeholder);deskHotspots.classList.toggle("hidden",state.scene!=="desk");mapHotspots.classList.toggle("hidden",state.scene!=="map");back.classList.toggle("hidden",state.scene==="desk");rain.classList.toggle("hidden",state.scene!=="desk");renderHUD();}
function action(name){switch(name){case"coffee":passTime(12);state.energy=clamp(state.energy+5);state.focus=clamp(state.focus+7);state.health=clamp(state.health-1);showToast("Kaffee: +Fokus, etwas Zeit vergeht.");break;case"phone":showToast("Telefon-Modul folgt spaeter.");break;case"notebook":showToast("Notizbuch / Ziele folgen spaeter.");break;case"map":state.scene="map";break;case"storage":state.scene="storage";break;case"desk":state.scene="desk";break;case"client":showToast("Kundenfahrt folgt spaeter.");break;case"hardware":showToast("Baumarkt folgt spaeter.");break;}renderScene();}
document.addEventListener("click",e=>{const target=e.target.closest("[data-action]");if(target)action(target.dataset.action);});
renderScene();
