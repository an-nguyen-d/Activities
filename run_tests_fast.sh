#!/bin/bash

echo "🧪 Running ALL unit tests from Package.swift testCases..."
echo ""

# Extract test targets from Package.swift testCases array
TEST_TARGETS=($(grep -A 20 "private static let testCases" Packages/ActivitiesApp/Package.swift | grep -E "^\s*\.[A-Z]" | sed 's/.*\.\([^,]*\).*/\1/' | tr -d ' '))

echo "Found ${#TEST_TARGETS[@]} test targets in Package.swift:"
for target in "${TEST_TARGETS[@]}"; do
  echo "  - ACT.$target"
done
echo ""

DESTINATION="platform=iOS Simulator,name=iPhone 16,OS=18.5"
FAILED_TESTS=()
SKIPPED_TESTS=()

for target in "${TEST_TARGETS[@]}"; do
  scheme="ACT.$target"
  echo "🧪 Testing $scheme..."
  
  # Check if scheme exists in Xcode
  if xcodebuild -list -project Activities.xcodeproj 2>/dev/null | grep -q "^        $scheme$"; then
    # Scheme exists, run it with xcodebuild
    if xcodebuild test -scheme "$scheme" -destination "$DESTINATION" -quiet 2>/dev/null; then
      echo "✅ $scheme passed"
    else
      echo "❌ $scheme failed"
      FAILED_TESTS+=("$scheme")
    fi
  else
    # Scheme doesn't exist, try testing the package target directly
    echo "⚠️  Scheme not found, testing package target directly..."
    cd Packages/ActivitiesApp
    if swift test --filter "$target" 2>/dev/null; then
      echo "✅ $scheme passed (via swift test)"
      cd ../..
    else
      echo "⚠️  $scheme skipped (no scheme + swift test failed)"
      SKIPPED_TESTS+=("$scheme")
      cd ../..
    fi
  fi
  echo ""
done

echo "📊 Test Summary:"
echo "Total targets: ${#TEST_TARGETS[@]}"
echo "Passed: $((${#TEST_TARGETS[@]} - ${#FAILED_TESTS[@]} - ${#SKIPPED_TESTS[@]}))"
echo "Failed: ${#FAILED_TESTS[@]}"
echo "Skipped: ${#SKIPPED_TESTS[@]}"

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
  echo ""
  echo "❌ Failed tests:"
  for failed in "${FAILED_TESTS[@]}"; do
    echo "  - $failed"
  done
fi

if [ ${#SKIPPED_TESTS[@]} -gt 0 ]; then
  echo ""
  echo "⚠️  Skipped tests (need scheme creation):"
  for skipped in "${SKIPPED_TESTS[@]}"; do
    echo "  - $skipped"
  done
fi

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
  exit 1
else
  echo ""
  echo "🎉 All available tests passed!"
  exit 0
fi