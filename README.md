# Powerlifting Rep Max Tracker (MVP)

A Flutter app to log actual completed S/B/D (squat, bench, deadlift) lifts and display current rep maxes (1–10) per lift.

## Prerequisites

- Flutter (stable channel)
- Docker Desktop
- Supabase CLI
- PostgreSQL client tools (psql)

## Local Development Setup

### 1. Install Dependencies

```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Install PostgreSQL client (for psql)
brew install postgresql@14

# Add psql to PATH permanently
echo 'export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Install Flutter dependencies
flutter pub get
```

### 2. Start Local Supabase

```bash
# Start Docker Desktop first, then:
supabase start
```

This will:
- Download and start all Supabase services (PostgreSQL, Auth, API, etc.)
- Apply database migrations from `supabase/migrations/`
- Seed the database with test data from `supabase/seed.sql`
- Display local URLs and keys

### 3. Verify Database Setup

```bash
# Check that data was loaded (should show 31 entries)
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -c "SELECT COUNT(*) FROM lift_entries;"

# View sample rep maxes
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -c "SELECT lift, reps, weight_kg FROM rep_maxes LIMIT 10;"
```

### 4. Run Flutter App

```bash
flutter run --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
```

## Database Schema

The app uses these main tables:

- **`lift_entries`**: Individual lift records (id, user_id, lift, reps, weight_kg, performed_at, created_at)
- **`rep_maxes`**: View showing best weight per (user, lift, reps) combination

## Test Users

The seed data includes two test users:
- **john@example.com** (password: password123) - Strong lifter
- **jane@example.com** (password: password123) - Moderate lifter

## Supabase Services

When running locally, access these services at:
- **Database**: `postgresql://postgres:postgres@127.0.0.1:54322/postgres`
- **API**: `http://127.0.0.1:54321`
- **Studio (UI)**: `http://127.0.0.1:54323`
- **Inbucket (Email)**: `http://127.0.0.1:54324`

## Stop Local Services

```bash
supabase stop
```

## Reset Database

To reset the database and reapply migrations/seed data:

```bash
supabase db reset
```
