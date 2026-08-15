PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS game (
  id TEXT PRIMARY KEY,
  game_version TEXT NOT NULL,
  schema_version INTEGER NOT NULL,
  rule_pack_version TEXT NOT NULL,
  scenario_id TEXT NOT NULL,
  rng_seed INTEGER NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS event_log (
  seq INTEGER PRIMARY KEY AUTOINCREMENT,
  game_id TEXT NOT NULL,
  sim_time TEXT NOT NULL,
  event_type TEXT NOT NULL,
  aggregate_type TEXT,
  aggregate_id TEXT,
  payload_json TEXT NOT NULL,
  FOREIGN KEY(game_id) REFERENCES game(id)
);
