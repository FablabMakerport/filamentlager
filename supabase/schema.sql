-- =====================================================================
-- Filamentlager · Datenbank für Supabase
-- Komplett im SQL Editor einfügen und einmal "Run" klicken.
-- Kann gefahrlos erneut ausgeführt werden.
-- =====================================================================

-- 1) Tabellen ---------------------------------------------------------

create table if not exists public.filamente (
  id            text primary key,
  material      text not null check (material in ('PLA','PETG')),
  farbe         text not null,
  marke         text not null default '',
  hex           text not null default '#8a8f96',
  rollen        integer not null default 0,
  rest          numeric not null default 0,
  angebrochen   integer not null default 0,
  rollengewicht integer not null default 1000,
  preis_rolle   numeric not null default 0,
  zugaenge      jsonb   not null default '[]',
  updated_at    timestamptz not null default now()
);

create table if not exists public.buchungen (
  id           text primary key,
  fid          text references public.filamente(id) on delete set null,
  material     text not null,
  farbe        text not null,
  hex          text,
  gramm        numeric not null,
  abzug        numeric,
  preis        numeric,
  notiz        text not null default '',
  projekt      text not null default '',
  drucker      text not null default '',
  person       text not null default '',
  ts           timestamptz not null default now(),
  erstellt_von uuid default auth.uid() references auth.users(id) on delete set null,
  created_at   timestamptz not null default now()
);

create table if not exists public.projekte (
  id           text primary key,
  name         text not null,
  beschreibung text not null default '',
  status       text not null default 'aktiv' check (status in ('aktiv','fertig')),
  ts           timestamptz not null default now()
);

create table if not exists public.drucke (
  id            text primary key,
  titel         text not null,
  projekt       text not null default '',
  status        text not null default 'fertig' check (status in ('fertig','geplant')),
  ts            timestamptz not null default now(),
  notiz         text not null default '',
  buchung_ids   text[] not null default '{}',
  plan_fid      text,
  plan_g        numeric not null default 0,
  foto_pfad     text,
  datei_pfad    text,
  datei_name    text,
  datei_groesse bigint
);

create table if not exists public.einstellungen (
  schluessel text primary key,
  wert       jsonb not null
);

create index if not exists buchungen_ts_idx  on public.buchungen (ts desc);
create index if not exists buchungen_fid_idx on public.buchungen (fid);
create index if not exists drucke_ts_idx     on public.drucke (ts desc);

-- 2) Freigaben für die Data API -------------------------------------
-- Nötig, weil "Automatically expose new tables" ausgeschaltet ist.
-- Nur angemeldete Nutzer (authenticated) bekommen Zugriff,
-- nicht angemeldete Besucher (anon) gar keinen.

grant usage on schema public to authenticated;

grant select, insert, update, delete on
  public.filamente, public.buchungen, public.projekte, public.drucke, public.einstellungen
  to authenticated;

revoke all on
  public.filamente, public.buchungen, public.projekte, public.drucke, public.einstellungen
  from anon;

-- 3) Zugriffsregeln (Row Level Security) ------------------------------
-- Jedes eingeladene Team-Mitglied darf alles lesen und schreiben.
-- Fremde kommen nicht rein, weil die Registrierung abgeschaltet ist.

alter table public.filamente     enable row level security;
alter table public.buchungen     enable row level security;
alter table public.projekte      enable row level security;
alter table public.drucke        enable row level security;
alter table public.einstellungen enable row level security;

drop policy if exists "Team liest und schreibt" on public.filamente;
drop policy if exists "Team liest und schreibt" on public.buchungen;
drop policy if exists "Team liest und schreibt" on public.projekte;
drop policy if exists "Team liest und schreibt" on public.drucke;
drop policy if exists "Team liest und schreibt" on public.einstellungen;

create policy "Team liest und schreibt" on public.filamente     for all to authenticated using (true) with check (true);
create policy "Team liest und schreibt" on public.buchungen     for all to authenticated using (true) with check (true);
create policy "Team liest und schreibt" on public.projekte      for all to authenticated using (true) with check (true);
create policy "Team liest und schreibt" on public.drucke        for all to authenticated using (true) with check (true);
create policy "Team liest und schreibt" on public.einstellungen for all to authenticated using (true) with check (true);

-- 4) Privater Speicher für Fotos und Druckdateien --------------------
-- Nicht öffentlich, max. 50 MB pro Datei.

insert into storage.buckets (id, name, public, file_size_limit)
values ('dateien', 'dateien', false, 52428800)
on conflict (id) do update set public = false, file_size_limit = excluded.file_size_limit;

drop policy if exists "Team: Dateien lesen"     on storage.objects;
drop policy if exists "Team: Dateien hochladen" on storage.objects;
drop policy if exists "Team: Dateien ändern"    on storage.objects;
drop policy if exists "Team: Dateien löschen"   on storage.objects;

create policy "Team: Dateien lesen"     on storage.objects for select to authenticated using (bucket_id = 'dateien');
create policy "Team: Dateien hochladen" on storage.objects for insert to authenticated with check (bucket_id = 'dateien');
create policy "Team: Dateien ändern"    on storage.objects for update to authenticated using (bucket_id = 'dateien') with check (bucket_id = 'dateien');
create policy "Team: Dateien löschen"   on storage.objects for delete to authenticated using (bucket_id = 'dateien');

-- 5) Live-Abgleich zwischen Geräten ----------------------------------

do $$
declare t text;
begin
  foreach t in array array['filamente','buchungen','projekte','drucke'] loop
    begin
      execute format('alter publication supabase_realtime add table public.%I', t);
    exception when duplicate_object then null;  -- schon eingetragen
    end;
  end loop;
end $$;

-- 6) Kontrolle: sollte 5 Tabellen mit rls = true zeigen --------------

select tablename, rowsecurity as rls
from pg_tables
where schemaname = 'public'
order by tablename;
