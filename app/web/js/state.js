export const state={scene:"desk",money:620,income:0,expenses:0,minutes:19*60+30,energy:63,focus:52,health:86};
export function clamp(value,min=0,max=100){return Math.max(min,Math.min(max,value));}
export function passTime(minutes){state.minutes=(state.minutes+minutes)%(24*60);}
export function timeString(){const h=Math.floor(state.minutes/60);const m=state.minutes%60;return `${String(h).padStart(2,"0")}:${String(m).padStart(2,"0")}`;}
