# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is an iOS app built with The Composable Architecture (TCA), featuring a modular Swift Package structure. The app tracks activities, goals, and streaks.

### Key Architecture Patterns
- **TCA (The Composable Architecture)**: Unidirectional data flow architecture by Point-Free
- **Modular Package Structure**: All business logic in `/Packages/ActivitiesApp`
- **Dependency Injection**: Client protocols with test implementations
- **Feature-Based Organization**: Each feature is a separate module

### Module Structure
- **Feature Modules**: `ACT.ActivitiesListFeature` (TCA logic), `ACT.ActivitiesListFeatureiOS` (UI)
- **Client Modules**: `DatabaseClient`, `GoalEvaluationClient`, `GoalCreationClient`, `ActivitiesStreakEvaluationClient`
- **Shared Modules**: `ACT.SharedModels` (domain models), `ACT.SharedUI` (styleguide)
- **Database**: GRDB SQLite implementation in `ACT.DatabaseClientGRDB`

### Key Domain Concepts
- **Activities**: Track various activities with different session units (integer, floating, time-based)
- **Goals**: Three types - EveryXDays, DaysOfWeek, WeeksPeriod
- **Streaks**: Automatic calculation based on goal completion
- **Success Criteria**: "at least", "exactly", "less than" goals

## Common Development Commands

### Build Commands
```bash
# Build main app
xcodebuild -scheme Activities -configuration Debug

# Build for release
xcodebuild -scheme Activities -configuration Release
```

### Test Commands
```bash
# Run ALL unit tests (reads from Package.swift testCases automatically)
./run_tests_fast.sh

# Run ALL tests individually (slower but more detailed)
./run_all_tests.sh

# Manual commands
xcodebuild test -scheme Activities -destination 'platform=macOS'
xcodebuild test -scheme ACT.GoalEvaluationClient -destination 'platform=macOS'
```

### Working with Swift Package
```bash
# Resolve package dependencies
xcodebuild -resolvePackageDependencies -scheme Activities

# Build specific package target
swift build --package-path Packages/ActivitiesApp --target ACT.SharedModels
```

## Testing Strategy

- **XCTest Framework**: Apple's standard testing framework
- **CustomDump**: Enhanced test assertions (from Point-Free)
- **Test Doubles**: Each client has `.testValue` implementations
- **Test Organization**: Unit tests per module, edge case tests, integration tests
- **Automated Testing**: `./run_tests_fast.sh` auto-discovers tests from Package.swift testCases array

## Development Workflow - CRITICAL

**ALWAYS run tests before git operations:**

```bash
# 1. BEFORE every git commit - run all tests
./run_tests_fast.sh

# 2. Only commit if tests pass
git add .
git commit -m "Your commit message"

# 3. BEFORE every git push - run tests again  
./run_tests_fast.sh
git push
```

**Test Discovery**: Adding new tests is automatic - just add the test target to the `testCases` array in `/Packages/ActivitiesApp/Package.swift` and the script will discover and run it.

## Important Technical Details

- **iOS 18+ Deployment Target**: Very modern, uses latest iOS features
- **Swift 6.1**: Latest Swift version with strict concurrency
- **Database**: GRDB 7.5.0 for SQLite persistence
- **Dependencies**: TCA 1.20.2, swift-tagged, ElixirShared (local package)