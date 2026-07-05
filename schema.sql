-- ============================================================
-- Gym Quest · Esquema de base de datos (Supabase / Postgres)
-- Pega este archivo completo en: Supabase -> SQL Editor -> Run
-- ============================================================

-- Cada entrenamiento iniciado (uno por "Iniciar entrenamiento")
create table if not exists sessions (
  id            uuid primary key,
  profile_id    text not null,
  day_id        int,
  day_title     text,
  day_type      text,            -- 'gym' | 'rest'
  week_number   int,
  started_at    timestamptz,
  finished_at   timestamptz,
  duration_min  numeric,
  completed     boolean default false,
  sets_planned  int,
  sets_done     int,
  postpones     int default 0
);

-- Cada serie completada (el corazón del análisis)
create table if not exists sets (
  id              uuid primary key,
  session_id      uuid,
  profile_id      text not null,
  logged_at       timestamptz,
  week_number     int,
  day_id          int,
  day_title       text,
  block           text,          -- bloque/circuito al que pertenece
  kind            text,          -- 'circuit' | 'straight'
  exercise        text,
  set_number      int,           -- 1..n dentro del ejercicio
  sets_total      int,
  target          text,          -- reps objetivo ("8-10", "30-45s / lado"...)
  weight          numeric,       -- peso tal como se ingresó
  unit            text,          -- 'kg' | 'lb'
  weight_kg       numeric,       -- normalizado a kg para comparar
  times_postponed int default 0, -- veces que se pospuso antes de hacerla (máquina ocupada)
  is_pr           boolean default false
);

-- Eventos: omisiones, swaps de descanso, récords, niveles, días/semanas completados
create table if not exists events (
  id           uuid primary key,
  profile_id   text,
  ts           timestamptz,
  type         text,             -- 'postpone'|'swap_rest'|'pr'|'level_up'|'day_complete'|'week_complete'
  detail       jsonb,
  week_number  int,
  day_id       int
);

-- Estado de la app para sincronizar progreso entre dispositivos
create table if not exists app_state (
  profile_id  text primary key,
  state       jsonb,
  updated_at  timestamptz
);

-- Índices útiles para análisis
create index if not exists idx_sets_exercise  on sets (profile_id, exercise, logged_at);
create index if not exists idx_sets_week      on sets (profile_id, week_number);
create index if not exists idx_sessions_week  on sessions (profile_id, week_number);
create index if not exists idx_events_type    on events (profile_id, type);

-- ------------------------------------------------------------
-- Acceso con la anon key (app personal, sin login).
-- NOTA: cualquiera con tu anon key puede leer/escribir estas
-- tablas. Para un proyecto personal es aceptable; no publiques
-- la key en un repo público (o usa repo privado).
-- ------------------------------------------------------------
alter table sessions  enable row level security;
alter table sets      enable row level security;
alter table events    enable row level security;
alter table app_state enable row level security;

create policy "anon all sessions"  on sessions  for all using (true) with check (true);
create policy "anon all sets"      on sets      for all using (true) with check (true);
create policy "anon all events"    on events    for all using (true) with check (true);
create policy "anon all app_state" on app_state for all using (true) with check (true);
