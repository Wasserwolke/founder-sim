export const state = {
  scene: "desk",
  minutes: 19 * 60 + 30
};

export function passTime(minutes) {
  state.minutes = (state.minutes + Number(minutes)) % (24 * 60);
}

export function timeString() {
  const h = Math.floor(state.minutes / 60);
  const m = state.minutes % 60;
  return `${String(h).padStart(2, "0")}:${String(m).padStart(2, "0")}`;
}
