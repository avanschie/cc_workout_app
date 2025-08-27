# Claude Development Guide

This file contains commands and practices for maintaining this Flutter project locally to avoid CI failures.

## General
When creating commits, don't mention Claude (i.e., list claude as co-author, etc.)

## Pre-commit Checks

Run these commands locally before committing changes:

### 1. Code Formatting
```bash
dart format .
```
- Automatically formats all Dart code according to Flutter standards
- Must be run to pass CI formatting checks
- Alternative: `flutter format .`

### 2. Static Analysis
```bash
flutter analyze
```
- Runs Dart analyzer to catch potential issues, unused imports, etc.
- Should have zero issues for CI to pass
- Fix warnings and errors before committing

### 3. Dependency Management
```bash
flutter pub get
```
- Ensures all dependencies are properly resolved
- Run after modifying pubspec.yaml
- Generates/updates pubspec.lock

### 4. Testing
```bash
flutter test
```
- Runs all unit and widget tests
- All tests must pass for CI to succeed
- Add tests for new functionality

## Recommended Workflow

Before each commit (essential - run in this exact order):
1. `flutter pub get` - Ensure dependencies are current
2. `dart format .` - Format code
3. `flutter analyze` - Check for issues (must have zero warnings/errors)
4. `flutter test` - Run tests (all tests must pass)

**IMPORTANT**: Each step must complete successfully before proceeding to the next. The CI will fail if any of these steps produce errors or warnings.

### Optional Build Verification
```bash
flutter build apk --debug    # Android debug build (primary target)
```
- Verifies the app builds successfully
- Can be slow, not required for every commit
- Run when making significant changes or before releases

## Project Configuration

- **Flutter Version**: 3.35.x (includes Dart 3.9.0)
- **Dart SDK**: ^3.9.0
- **Linting**: flutter_lints ^6.0.0

## IDE Integration

Consider setting up your IDE to:
- Format on save
- Show analysis results inline
- Run tests automatically

## CI Pipeline

The GitHub Actions workflow runs:
- Dependency resolution (`flutter pub get`)
- Code formatting check (`dart format --set-exit-if-changed`)
- Static analysis (`flutter analyze`)
- Tests (`flutter test`)
- Build verification (APK and web)

All steps must pass for successful CI.