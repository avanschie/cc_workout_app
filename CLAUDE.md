# Project: Powerlifting Rep Max Tracker (MVP)
**Goal:** Ship a minimal Flutter app to log actual completed S/B/D (squat, bench, deadlift) lifts (no estimates) and display current rep maxes (1–10) per lift.  
**Scope:** Auth, data entry, cloud persistence (Supabase), and a Rep Maxes summary view. No charts yet.

---

## Tech Stack & Conventions

- **Flutter**: stable channel, Dart null-safety.
- **Packages**
  - `flutter_riverpod`
  - `supabase_flutter`
  - `intl` (dates)
  - `freezed`, `json_serializable` (optional for models)
- **Architecture**
  - Feature-first folders, repository pattern, Riverpod providers.
  - Immutable models, DTO mappers for Supabase rows.
- **Env**
  - Configure `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `--dart-define`.
- **Data Model**
  - Cloud-first using Supabase Postgres; keep queries simple/typed.
  - SBD only (`squat`, `bench`, `deadlift`); reps 1–10; weight in kg (double).
  - Dates stored as `date` (no time zone confusion).

---

## Definitions of Done (MVP)

- User can sign in/out (magic link) and stay signed in.
- User can create lift entries with: lift, reps, weight (kg), date.
- Data persists in Supabase with RLS (only owner can read/write).
- Rep Maxes screen shows best weight per rep (1–10) for S/B/D.
- Input validation: reps 1–10, weight > 0, date required.
- Error handling & empty states; loading indicators present.
- Works on iOS and Android devices/emulators.
- App icon & name set; version 0.1.0.
