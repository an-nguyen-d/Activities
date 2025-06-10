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

## UI Architecture & Styling Principles

### View Construction Pattern
All iOS feature views should follow the pattern established in `ActivityCreationView`:

1. **Inherit from BaseView** (from ElixirShared):
   ```swift
   final class MyFeatureView: BaseView { ... }
   ```

2. **Use updateObject for inline configuration**:
   ```swift
   private let myLabel = updateObject(UILabel()) {
       $0.text = "SECTION TITLE"
       $0.font = .systemFont(ofSize: 12, weight: .regular)
       $0.textColor = .secondaryLabel
   }
   ```

3. **Override setupView() and setupSubviews()**:
   - `setupView()`: Configure view properties
   - `setupSubviews()`: Add subviews and constraints using ElixirShared utilities

4. **Use ElixirShared Layout Utilities**:
   - `addSubviews()`: Add multiple subviews at once
   - `fillView()`: Constraint view to fill superview
   - `anchor()`: Convenient Auto Layout API

### Consistent Styling
- **Section Headers**: All caps, 12pt regular font, `.secondaryLabel` color
- **Body Text**: `.preferredFont(forTextStyle: .body)`, `.View.Text.primary` color
- **Interactive Elements**: `.peterRiver` color for buttons and links
- **Spacing**: 24pt between sections, 20pt padding from edges
- **Background**: `.View.Background.primary` (black)

### UI Component Patterns
- **Scroll Views**: Use for all content that might overflow
- **Stack Views**: Vertical stacks with 24pt spacing for main content layout
- **Buttons**: 
  - **ALWAYS use BaseButton** instead of UIButton
  - Set tap handlers using `button.onTapHandler = { }` instead of `addTarget`
  - For text buttons: Set `.peterRiver` tint color
  - For primary action buttons: Set `.peterRiver` background with white text
- **Collection Views**: For dynamic content like tags with flow layout

## Common Development Commands

### Build Commands
```bash
# Build main app
xcodebuild -scheme Activities -configuration Debug

# Build for release
xcodebuild -scheme Activities -configuration Release

# Build specific package target (for checking compile errors/warnings)
./build_target.sh ACT.DatabaseClientGRDB
./build_target.sh ACT.SharedModels

# Manual target build
xcodebuild build -scheme "ACT.DatabaseClientGRDB" -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5"
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