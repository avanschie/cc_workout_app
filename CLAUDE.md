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
  - **Local Development**: Use `supabase start` to run local Supabase, then:
    - `SUPABASE_URL=http://127.0.0.1:54321`
    - `SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0`
- **Data Model**
  - Cloud-first using Supabase Postgres; keep queries simple/typed.
  - SBD only (`squat`, `bench`, `deadlift`); reps 1–10; weight in kg (double).
  - Dates stored as `date` (no time zone confusion).
- **Development Workflow**
  - Start local Supabase: `supabase start`
  - Run app locally: `flutter run --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0`
  - After any code change, run: `flutter analyze` (must pass with no errors/warnings)
  - Format code with: `dart format .`
  - Run tests with: `flutter test` (all tests must pass)
  - ALWAYS update TODO_MVP.md to mark completed features/tasks as [x] done before committing
  - Commit messages should not reference Claude/AI and use regular author attribution
- **Testing Requirements**
  - Write tests for every new feature implementation
  - All tests must pass before considering feature complete
  - Include unit tests for models, services, and business logic
  - Include widget tests for UI components

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
