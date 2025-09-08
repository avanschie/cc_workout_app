# Staging Environment Setup Guide

This guide explains how to set up and use the staging environment for testing the app on real devices with a cloud Supabase database.

## Overview

The app supports multiple environments:
- **Local**: Uses local Supabase CLI (Android emulator at 10.0.2.2:54321)
- **Staging**: Uses cloud Supabase database (for physical device testing)

## Prerequisites

1. Physical Android/iOS device
2. USB cable for device connection
3. Access to staging Supabase credentials

## Quick Start

### 1. Connect Your Device

**Android:**
```bash
# Enable Developer Options and USB Debugging on your device
# Connect via USB cable
adb devices  # Should show your device
```

**iOS:**
```bash
# Connect via USB cable
# Trust the computer when prompted on device
```

### 2. Run Staging Environment

**Using VSCode:**
- Select "Staging" configuration from Run and Debug panel
- Press F5 or click Run

**Using Command Line:**
```bash
flutter run -t lib/main_staging.dart \
  --dart-define=SUPABASE_URL=https://rpntfvfemtsfolxweufs.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_LjCvkObpXcY_kG-aefy80w_uYUTp93q
```

## Environment Indicators

When running in staging mode, you'll see:
- App title: "Powerlifting Rep Max Tracker (Staging)"
- Orange environment banner in top-right corner (debug builds only)
- Console output showing staging environment

## Troubleshooting

### Device Not Detected

**Android:**
1. Enable Developer Options: Settings > About Phone > Tap Build Number 7 times
2. Enable USB Debugging: Settings > Developer Options > USB Debugging
3. Change USB mode to "File Transfer" if needed
4. Run `flutter devices` to verify detection

**iOS:**
1. Trust the computer when prompted
2. Run `flutter devices` to verify detection

### Connection Issues

1. **Check network**: Device needs internet access for cloud Supabase
2. **Verify credentials**: Ensure staging Supabase URL and key are correct
3. **Check logs**: Look for Supabase connection errors in console

### Authentication Problems

1. **Email/Password**: Standard authentication flow requires valid credentials
2. **RLS Policies**: Ensure Row Level Security is properly configured
3. **User Creation**: New users are created through Supabase Auth

## Security Notes

- Staging credentials are in `.env.staging` (not committed to git)
- Never commit actual credentials to version control
- Use different credentials for staging vs production
- Rotate keys periodically

## Team Setup

For team members to set up staging:

1. **Get Credentials**: Ask admin for staging Supabase URL and anon key
2. **Create .env.staging**:
   ```
   EXPO_PUBLIC_SUPABASE_URL=https://your-staging-url.supabase.co
   EXPO_PUBLIC_SUPABASE_KEY=your-staging-anon-key
   ```
3. **Update VSCode Config**: Modify `.vscode/launch.json` with your credentials
4. **Test Connection**: Run staging environment and verify database connectivity

## Database Schema

The staging database has the same schema as local development:
- `lift_entries` table with RLS policies
- `rep_maxes` view for best lifts
- Authentication through Supabase Auth

Migrations are applied manually through Supabase dashboard SQL editor.