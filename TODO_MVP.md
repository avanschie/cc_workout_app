# TODO: Powerlifting Rep Max Tracker MVP

## Phase 0: CI/CD & Quality Assurance

### 0.1 Continuous Integration Setup
- [x] Configure GitHub Actions CI pipeline
- [x] Enforce code formatting with `dart format --set-exit-if-changed`
- [x] Enforce static analysis with `flutter analyze --fatal-warnings` (zero warnings policy)
- [x] Automate test execution on all commits
- [x] Set up automated dependency updates via Renovate bot
- [x] Configure proper concurrency management for CI jobs

## Phase 1: Project Setup & Dependencies

### 1.1 Flutter Project Structure
- [x] Verify Flutter stable channel installation
- [x] Set up feature-first folder structure:
  ```
  lib/
  ├── core/
  │   ├── config/
  │   ├── constants/
  │   └── utils/
  ├── features/
  │   ├── auth/
  │   ├── lifts/
  │   └── rep_maxes/
  ├── shared/
  │   ├── models/
  │   ├── providers/
  │   └── widgets/
  └── main.dart
  ```

### 1.2 Dependencies
- [x] Add `flutter_riverpod` to pubspec.yaml
- [x] Add `supabase_flutter` to pubspec.yaml
- [x] Add `intl` package for date handling
- [x] Add `freezed` and `json_serializable` (optional for models)
- [x] Add dev dependencies: `build_runner`, `freezed_annotation`, `json_annotation`
- [x] Run `flutter pub get`

### 1.3 Environment Configuration
- [x] Set up environment variables for Supabase:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
- [x] Configure `--dart-define` usage
- [x] Create environment configuration helper
- [x] Implement multi-environment setup:
  - [x] Create Environment enum and EnvironmentConfig class
  - [x] Add local environment (hardcoded for Android emulator)
  - [x] Add staging environment (uses --dart-define)
  - [x] Create lib/main_local.dart entry point
  - [x] Create lib/main_staging.dart entry point
  - [x] Set up VSCode launch configurations (.vscode/launch.json)
  - [x] Add visual environment banner for debug builds

### 1.4 Platform-Specific Development Configuration
- [x] Configure Android emulator network settings (use 10.0.2.2:54321 for local Supabase)
- [x] Document production email requirements (no example.com domains in staging/production)
- [x] Set up environment-specific auth behavior (local auto-login, staging optional verification)

## Phase 2: Supabase Backend Setup

### 2.1 Database Schema
- [x] Create `lift_entries` table with columns:
  - `id` (UUID, primary key)
  - `user_id` (UUID, foreign key to auth.users)
  - `lift` (lift_type enum: 'squat', 'bench', 'deadlift')
  - `reps` (int2: 1-10)
  - `weight_kg` (numeric(6,2))
  - `performed_at` (date)
  - `created_at` (timestamptz)
- [x] Create `lift_type` enum for type safety
- [x] Create `rep_maxes` view for best weight per (user, lift, reps)

### 2.2 Row Level Security (RLS)
- [x] Enable RLS on `lift_entries` table
- [x] Create policies: users can only read/write their own lifts (SELECT, INSERT, UPDATE, DELETE)
- [x] Test RLS policies with actual users

### 2.3 Seed Data
- [x] Create seed.sql with sample lift entries for testing
- [x] Apply seed data to local database

### 2.4 Authentication Setup
- [x] Configure Supabase Auth with email/password
- [x] Set up email templates (optional)
- [x] Test authentication flow
- [x] Implement environment-specific auth behavior (auto-login for local dev)

## Phase 3: Core Models & Services

### 3.1 Data Models
- [x] Create `LiftEntry` model with:
  - id, userId, lift, reps, weightKg, performedAt, createdAt
  - Validation methods
  - JSON serialization (if using freezed)
- [x] Create `RepMax` model for rep_maxes view data

### 3.2 Enums & Constants
- [x] Create `LiftType` enum (squat, bench, deadlift) matching database enum
- [x] Define validation constants (min/max reps, weight limits)

### 3.3 Repository Pattern
- [x] Create `AuthRepository` interface and implementation
- [x] Create `LiftEntriesRepository` interface and implementation
- [x] Create `RepMaxesRepository` interface and implementation
- [x] Implement CRUD operations for lift entries
- [x] Add error handling for network/database operations

## Phase 4: Authentication Feature

### 4.1 Auth State Management
- [x] Create Riverpod providers for auth state (AsyncNotifier pattern with AuthController)
- [x] Implement sign in with email/password
- [x] Implement sign up with email/password/display name
- [x] Implement password reset functionality
- [x] Implement sign out functionality
- [x] Handle persistent sessions with environment-specific behavior
- [x] Add auto-login for local development environment

### 4.2 Auth UI
- [x] Create sign-in screen with email/password input and validation
- [x] Create sign-up screen with form validation and password strength indicator
- [x] Create forgot password screen with step-by-step instructions
- [x] Create auth loading screen with environment indicators
- [x] Add comprehensive loading states and error handling with specific error messages
- [x] Create AuthGate for routing between auth/main app based on auth state
- [x] Implement navigation flow for authenticated/unauthenticated states
- [x] Add reusable form components with real-time validation
- [x] Integrate with MainNavigationShell (user menu, sign out, profile display)

## Phase 5: Lifts Feature (Data Entry)

### 5.1 Lift Entry State Management
- [x] Create Riverpod providers for lift operations
- [x] Implement lift creation/editing logic
- [x] Add form validation providers

### 5.2 Lift Entry UI
- [x] Create "Add Lift" screen with:
  - Lift type selector (squat/bench/deadlift)
  - Reps input (1-10)
  - Weight input (kg)
  - Date picker
  - Save/Cancel buttons
- [x] Implement input validation:
  - Reps: 1-10 range
  - Weight: > 0
  - Date: required
- [x] Add loading indicators during save
- [x] Handle save errors with user feedback

### 5.3 Lifts History Feature
- [x] Create lifts history screen showing chronological list of all lifts (newest first)
- [x] Display lift information: lift type (squat/bench/deadlift), reps, weight (kg), date
- [x] Implement edit functionality for existing lift entries
- [x] Implement delete functionality with confirmation dialog
- [x] Add empty state when no lifts exist
- [ ] Add search/filter capabilities (optional)
- [x] Implement pagination or lazy loading for large datasets

## Phase 6: Rep Maxes Feature

### 6.1 Rep Max Calculations
- [x] Create service to calculate best weight per rep (1-10) for each lift type
- [x] Implement efficient queries to get max weights
- [x] Handle edge cases (no data for certain rep ranges)

### 6.2 Rep Maxes State Management
- [x] Create Riverpod providers for rep max data
- [x] Implement data refresh/reload functionality

### 6.3 Rep Maxes UI
- [x] Create Rep Maxes screen showing:
  - Grid/table layout for S/B/D
  - Best weight for reps 1-10
  - Clear labels and units (kg)
- [x] Add loading states
- [x] Handle empty states (no lifts recorded)
- [x] Add pull-to-refresh functionality

## Phase 7: Navigation & App Structure

### 7.1 Main App Structure
- [x] Set up main.dart with Riverpod integration
- [x] Configure Supabase initialization
- [x] Implement theme and material design

### 7.2 Navigation & Bottom Tabs
- [x] Implement bottom navigation bar with 2 main tabs:
  - **Rep Maxes Tab**: Shows the current rep maxes table (main view)
  - **History Tab**: Shows chronological lift history
- [x] Set up tab-based navigation structure
- [x] Define routes for:
  - Auth screens (sign in/out)
  - Bottom nav container (main app shell)
  - Add Lift screen (accessible from both tabs via FAB or button)
  - Individual lift edit screens
- [ ] Handle deep linking and navigation state
- [x] Ensure proper tab state persistence during app lifecycle

## Phase 8: Error Handling & Polish

### 8.1 Error Handling
- [x] Implement global error handling
- [x] Add user-friendly error messages
- [x] Handle network connectivity issues
- [x] Add retry mechanisms where appropriate

### 8.2 Loading States
- [x] Add loading indicators for all async operations
- [x] Implement skeleton screens where appropriate
- [x] Add pull-to-refresh on data screens

### 8.3 Validation & User Feedback
- [x] Implement client-side validation
- [x] Add form field validation messages
- [x] Show success messages after operations
- [x] Add confirmation dialogs for destructive actions

## Phase 9: Testing & Quality Assurance

### 9.1 Testing
- [x] Write unit tests for models and services
- [x] Write widget tests for key UI components
- [x] Write integration tests for critical flows
- [ ] Test on both iOS and Android

### 9.2 Performance & Optimization
- [x] Optimize database queries
- [x] Implement proper state management patterns
- [ ] Test app performance and memory usage

## Phase 10: App Release Preparation

### 10.1 App Configuration
- [x] Set app name in pubspec.yaml and native configs
- [ ] Design and set app icon
- [x] Set version to 0.1.0
- [ ] Configure app permissions

### 10.2 Platform-Specific Setup
- [ ] Configure iOS bundle identifier and settings
- [ ] Configure Android package name and settings
- [ ] Test on physical devices
- [ ] Prepare app store assets (if releasing)
- [ ] Verify iOS/Android release builds compile successfully
- [ ] Test production Supabase configuration with real email domains

### 10.3 Production Environment Setup
- [ ] Set up production Supabase project
- [ ] Configure production database schema and RLS policies
- [ ] Set up production authentication with email verification
- [ ] Verify production environment variables configuration

## Phase 11: Final Testing & Deployment

### 11.1 End-to-End Testing
- [ ] Test complete user journey: sign up → add lifts → view rep maxes
- [ ] Test offline behavior and error recovery
- [ ] Verify data persistence and RLS
- [ ] Verify all code passes `flutter analyze` with zero warnings (enforced by CI)
- [ ] Test app performance and memory usage under load

### 11.2 Documentation
- [x] Update README with setup instructions
- [x] Document environment variable setup
- [ ] Add troubleshooting guide

## Definition of Done Checklist

- [x] User can sign in/out (email/password) and stay signed in
- [x] User can create lift entries with: lift, reps, weight (kg), date  
- [x] Data persists in Supabase with RLS (only owner can read/write)
- [x] Rep Maxes screen shows best weight per rep (1–10) for S/B/D
- [x] Input validation: reps 1–10, weight > 0, date required
- [x] Error handling & empty states; loading indicators present
- [ ] Works on iOS and Android devices/emulators
- [x] App icon & name set; version 0.1.0

---

**Estimated Timeline:** 2-3 weeks for a solo developer working part-time
**Priority Order:** Follow phases 0-6 for core MVP, then 7-11 for polish and release

## Notes for Production Deployment

### Email Domain Requirements
- **Local Development**: Uses `@example.com` emails (john@example.com, jane@example.com) with hardcoded passwords
- **Staging/Production**: Must use realistic email domains (gmail.com, test.com, etc.) as Supabase blocks example.com domains
- **Email Verification**: Disabled for local, optional for staging, mandatory for production

### Android Emulator Configuration
- **Network Access**: Use `10.0.2.2:54321` instead of `127.0.0.1:54321` when running on Android emulator
- **Local Supabase**: The emulator cannot access localhost directly, requires the Android emulator's special IP

### Code Quality Standards
- **Zero Warnings Policy**: CI enforces `flutter analyze --fatal-warnings` - any warning fails the build
- **Formatting**: All code must pass `dart format --set-exit-if-changed`
- **Testing**: All tests must pass before code can be merged