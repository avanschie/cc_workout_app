Here's a comprehensive implementation guide for your Flutter + Supabase environment setup:

```markdown
# Flutter + Supabase Environment Setup Implementation Guide

## Overview
Set up a multi-environment Flutter app with Supabase that supports:
- Local development with Supabase CLI
- CI/CD testing with ephemeral Supabase instances
- Staging environment for device testing
- Production environment for end users

## Environment Structure
1. **Local** - Supabase CLI (developer machines)
2. **CI** - Supabase CLI (ephemeral instances in pipeline)
3. **Staging** - Cloud Supabase instance (device testing, UAT)
4. **Production** - Cloud Supabase instance (live users)

## Implementation Tasks

### 1. Create Environment Configuration System

#### Create `lib/config/environment.dart`
- Define Environment enum (local, staging, production)
- Create EnvironmentConfig class with:
  - supabaseUrl
  - supabaseAnonKey
  - appName
  - enableLogging
- Implement AppConfig class with static configuration management
- Handle platform-specific URLs (Android emulator: 10.0.2.2, iOS: localhost)
- Add method to get local Supabase URL for physical devices

### 2. Set Up Multiple Entry Points

#### Create separate main files:
- `lib/main_local.dart` - Initializes Environment.local
- `lib/main_staging.dart` - Initializes Environment.staging
- `lib/main_production.dart` - Initializes Environment.production
- Each file imports config and calls AppConfig.initialize() before runApp()

### 3. Configure VSCode Launch Settings

#### Create `.vscode/launch.json`
- Configuration for "Local (Computer)" → main_local.dart
- Configuration for "Staging (Phone/Cloud)" → main_staging.dart
- Configuration for "Production" → main_production.dart
- Each with appropriate --dart-define ENV parameter

### 4. Create Helper Scripts

#### Shell scripts in project root:
- `run_local.sh` - Runs app with local environment
- `run_staging.sh` - Runs app with staging environment
- `run_production.sh` - Runs app with production environment (careful!)
- Make scripts executable with `chmod +x *.sh`

### 5. Set Up Flutter Flavors

#### Update `android/app/build.gradle`:
```gradle
flavorDimensions "environment"
productFlavors {
    local {
        dimension "environment"
        applicationIdSuffix ".local"
        versionNameSuffix "-LOCAL"
    }
    staging {
        dimension "environment"
        applicationIdSuffix ".staging"
        versionNameSuffix "-STG"
    }
    production {
        dimension "environment"
    }
}
```

#### Update iOS configuration (if needed):
- Set up schemes in Xcode for different environments
- Configure bundle identifiers per environment

### 6. Implement Visual Environment Indicators

#### Create `lib/widgets/environment_banner.dart`:
- Banner widget that shows current environment
- Only visible in non-production environments
- Color coding: Blue for local, Orange for staging
- Position in top-right corner

### 7. Update Main App Widget

#### Modify `lib/app.dart` or create new:
- Initialize Supabase with AppConfig values
- Wrap MaterialApp with EnvironmentBanner
- Set app title from config
- Enable/disable logging based on environment

### 8. Create Makefile for Common Commands

#### `Makefile` in project root:
```makefile
local:
	flutter run -t lib/main_local.dart

staging:
	flutter run -t lib/main_staging.dart

build-staging:
	flutter build apk -t lib/main_staging.dart

install-staging:
	flutter install -t lib/main_staging.dart

build-ios-staging:
	flutter build ipa -t lib/main_staging.dart
```

### 9. Set Up CI/CD Pipeline

#### Create `.github/workflows/test.yml`:
- Install Supabase CLI
- Start local Supabase instance
- Run database migrations
- Seed test data
- Run Flutter tests against local Supabase
- Run integration tests
- Clean up Supabase instance

### 10. Create Database Migration Structure

#### Set up Supabase migrations:
- `supabase/migrations/` - SQL migration files
- `supabase/seed/` - Seed data files:
  - `ci.sql` - Minimal test data
  - `staging.sql` - Rich test data
  - `local.sql` - Development data

### 11. Environment Variable Management

#### Create `.env.example`:
```env
LOCAL_SUPABASE_URL=http://localhost:54321
LOCAL_ANON_KEY=your-local-key
STAGING_SUPABASE_URL=https://xxxxx.supabase.co
STAGING_ANON_KEY=your-staging-key
# Never commit production keys
```

#### Add to `.gitignore`:
```
.env
.env.local
.env.staging
.env.production
```

### 12. Create Debug Menu

#### Add environment info screen/drawer:
- Display current environment
- Show Supabase URL (masked in production)
- Show app version and build number
- Add "Copy Debug Info" button

### 13. Documentation

#### Create `docs/ENVIRONMENT_SETUP.md`:
- How to switch environments
- How to test on physical devices
- How to connect physical device to local Supabase
- Troubleshooting guide

### 14. Physical Device Testing Setup

#### Create helper for physical device connection:
- Script to get computer's IP address
- Instructions for wireless debugging setup
- Helper command for running on physical device with local Supabase

### 15. Secure API Keys

#### Implement secure key storage:
- Use --dart-define for build-time constants
- Never commit production keys
- Consider using secret management service for production
- Document key rotation process

## Testing Checklist

### Local Development
- [ ] Can run app with local Supabase
- [ ] Hot reload works
- [ ] Migrations apply correctly
- [ ] Seed data loads

### Physical Device
- [ ] Can connect to staging environment
- [ ] Can connect to local Supabase (via IP)
- [ ] App displays correct environment banner
- [ ] All features work without USB connection

### CI/CD
- [ ] Tests run with ephemeral Supabase
- [ ] Migrations test passes
- [ ] Integration tests pass
- [ ] Build artifacts generated correctly

### Environment Switching
- [ ] VSCode configurations work
- [ ] Shell scripts execute properly
- [ ] Makefile commands work
- [ ] No accidental production connections

## Success Criteria
- Zero-friction environment switching
- Visual confirmation of current environment
- Impossible to accidentally use production in development
- CI tests run in isolated environments
- Team can onboard easily with clear documentation
```

This guide provides a complete roadmap for implementing the multi-environment setup we discussed. You can work through it systematically with Claude Code to implement each section!