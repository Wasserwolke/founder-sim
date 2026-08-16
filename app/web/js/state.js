export const state = {
  scene: "desk",
  minutes: 19 * 60 + 30
};

/** Advance simulated time while keeping it inside one 24-hour day. */
export function passTime(minutes) {
  state.minutes = (state.minutes + Number(minutes)) % (24 * 60);
}

/** Format the current simulation time as HH:MM. */
export function timeString() {
  const hours = Math.floor(state.minutes / 60) % 24;
  const minutes = state.minutes % 60;
  return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}`;
}
