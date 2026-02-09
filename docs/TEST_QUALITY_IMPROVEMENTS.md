# Test Quality Improvements

## Critical Issues Identified

### 1. Tests Assert UI Strings Instead of Behavior ⚠️ HIGH PRIORITY

**Problem:**
Tests are asserting on UI labels rather than actual behavior or state.

**Examples of Fragile Tests:**
```dart
expect(find.textContaining('₹6'), findsAtLeastNWidgets(1));
expect(find.text('TREND'), findsOneWidget);
expect(find.text('INSIGHT'), findsOneWidget);
```

**Why This is Wrong:**
- Copy changes break tests without logic regression
- Localization will break all tests
- Low signal - doesn't protect calculations or state transitions
- Testing presentation, not business logic

**Fix Strategy:**
1. Add semantic keys to widgets
2. Assert on derived values, not labels
3. Test widget types + keys
4. Verify provider state when accessible

**Example Fix:**
```dart
// Before
expect(find.text('TREND'), findsOneWidget);

// After
expect(find.byKey(const Key('trend_section')), findsOneWidget);
expect(find.text('₹6,50,000'), findsOneWidget); // Exact formatted amount
```

**Action Items:**
- [ ] Add keys to all major UI components
- [ ] Replace text-based assertions with key-based assertions
- [ ] Create widget key constants file
- [ ] Update all widget tests to use keys

---

### 2. Currency Assertions Are Inconsistent and Unsafe ⚠️ MEDIUM PRIORITY

**Problem:**
Mixed currency assertion patterns that can hide bugs.

**Examples:**
```dart
₹-
₹6
₹1,00,000
₹0
```

**Why This is Wrong:**
- Formatting rules differ for negatives, commas, locales
- Partial matches can pass for incorrect values
- No centralized formatting validation

**Fix Strategy:**
Create a test helper for currency assertions:

```dart
// test/helpers/currency_test_helpers.dart
Finder findAmount(String value) => find.text('₹$value');

Finder findFormattedAmount(double amount) {
  final formatted = CurrencyFormatter.format(amount);
  return find.text(formatted);
}
```

**Example Fix:**
```dart
// Before
expect(find.textContaining('₹6'), findsAtLeastNWidgets(1));

// After
expect(findAmount('-1,60,000'), findsOneWidget);
expect(findFormattedAmount(650000), findsOneWidget);
```

**Action Items:**
- [ ] Create `test/helpers/currency_test_helpers.dart`
- [ ] Replace all currency text assertions with helper
- [ ] Ensure exact value matching
- [ ] Add tests for currency formatter itself

---

### 3. Navigation Tests Rely on Visible Text Instead of Routes ⚠️ MEDIUM PRIORITY

**Problem:**
Navigation tests verify text appearance, not actual navigation.

**Example:**
```dart
await tester.tap(find.text('ASSETS'));
expect(find.text('ASSETS BREAKUP'), findsOneWidget);
```

**Why This is Weak:**
- Text-based navigation tests are brittle
- Not verifying route push, only text appearance
- Doesn't catch navigation bugs

**Fix Strategy:**
Assert on route push or screen type:

```dart
// Before
await tester.tap(find.text('ASSETS'));
expect(find.text('ASSETS BREAKUP'), findsOneWidget);

// After
await tester.tap(find.byKey(const Key('assets_button')));
await tester.pumpAndSettle();
expect(find.byType(NetWorthDetailsScreen), findsOneWidget);
```

**Action Items:**
- [ ] Add keys to all navigation buttons
- [ ] Assert on screen types, not text
- [ ] Consider using `go_router` test helpers if applicable
- [ ] Update all navigation tests

---

### 4. RecurringTransactions Delete Test Misses Confirmation Flows ⚠️ LOW PRIORITY

**Problem:**
Delete tests don't account for confirmation dialogs.

**Example:**
```dart
await tester.tap(find.byIcon(Icons.delete_outline_rounded));
verify(() => mockRepo.deleteItem(...)).called(1);
```

**Why This is Wrong:**
- If confirmation dialog exists/added, test will fail silently
- Doesn't verify user experience
- Missing pump after tap

**Fix Strategy:**
```dart
await tester.tap(find.byIcon(Icons.delete_outline_rounded));
await tester.pump(); // Process the tap
// If confirmation dialog exists:
// await tester.tap(find.text('DELETE'));
// await tester.pumpAndSettle();
verify(() => mockRepo.deleteItem(...)).called(1);
```

**Action Items:**
- [ ] Add pump after all taps
- [ ] Document if deletion is immediate (no confirmation)
- [ ] Add confirmation dialog tests if applicable

---

### 5. RetirementDashboard Mixes Provider Override and Repository Fetch ⚠️ MEDIUM PRIORITY

**Problem:**
Two sources of truth in tests.

**Example:**
```dart
retirementProvider.overrideWith((ref) => retirementData)
when(() => mockRepo.getRetirementAccounts())
```

**Why This is Bad:**
- Unclear test intent
- Redundant mocking
- Can lead to inconsistent test data

**Fix Strategy:**
Choose one approach:

**Option A: Test Provider (Integration-ish)**
```dart
// Mock repository
when(() => mockRepo.getRetirementAccounts()).thenAnswer((_) async => data);
// Let provider call repo naturally
```

**Option B: Test Pure UI (Unit)**
```dart
// Override provider with test data
retirementProvider.overrideWith((ref) => retirementData);
// No repo mocking needed
```

**Recommendation:** For widget tests, prefer **Option B** (provider override only).

**Action Items:**
- [ ] Audit all widget tests for mixed mocking
- [ ] Standardize on provider override for widget tests
- [ ] Use repo mocking only for provider/usecase tests
- [ ] Document testing strategy in CONTRIBUTING.md

---

## Implementation Plan

### Phase 1: Foundation (Week 1)
1. Create `test/helpers/` directory
2. Add `currency_test_helpers.dart`
3. Add `widget_keys.dart` constants
4. Document testing standards

### Phase 2: Widget Keys (Week 2)
1. Add keys to all major components:
   - Dashboard widgets
   - Analysis screen
   - Settings screens
   - Navigation buttons
2. Update widget tests to use keys

### Phase 3: Currency Assertions (Week 3)
1. Replace all currency text assertions
2. Use exact value matching
3. Add currency formatter tests

### Phase 4: Navigation Tests (Week 4)
1. Update all navigation tests
2. Assert on screen types
3. Add navigation integration tests

### Phase 5: Provider/Mock Cleanup (Week 5)
1. Audit all widget tests
2. Remove redundant mocking
3. Standardize on provider overrides

---

## Testing Standards Going Forward

### Widget Tests
- **DO:** Use semantic keys for finding widgets
- **DO:** Override providers with test data
- **DO:** Assert on exact formatted values
- **DO:** Test behavior, not presentation
- **DON'T:** Assert on UI strings
- **DON'T:** Mix provider override with repo mocking
- **DON'T:** Use partial text matching

### Integration Tests
- **DO:** Test full user flows
- **DO:** Mock external dependencies only
- **DO:** Verify route navigation
- **DON'T:** Test implementation details

### Unit Tests
- **DO:** Test pure functions
- **DO:** Test edge cases
- **DO:** Mock all dependencies
- **DON'T:** Test Flutter widgets

---

## Example: Before and After

### Before (Fragile)
```dart
testWidgets('displays dashboard', (tester) async {
  await tester.pumpWidget(createTestWidget());
  await tester.pumpAndSettle();
  
  expect(find.text('TREND'), findsOneWidget);
  expect(find.textContaining('₹6'), findsAtLeastNWidgets(1));
  
  await tester.tap(find.text('ASSETS'));
  await tester.pumpAndSettle();
  expect(find.text('ASSETS BREAKUP'), findsOneWidget);
});
```

### After (Robust)
```dart
testWidgets('displays dashboard with correct data', (tester) async {
  await tester.pumpWidget(createTestWidget());
  await tester.pumpAndSettle();
  
  // Assert on keys and exact values
  expect(find.byKey(DashboardKeys.trendSection), findsOneWidget);
  expect(findFormattedAmount(650000), findsOneWidget);
  
  // Navigate and verify screen type
  await tester.tap(find.byKey(DashboardKeys.assetsButton));
  await tester.pumpAndSettle();
  expect(find.byType(NetWorthDetailsScreen), findsOneWidget);
});
```

---

## Metrics to Track

- [ ] % of tests using semantic keys vs text
- [ ] % of currency assertions using helpers
- [ ] % of navigation tests verifying screen types
- [ ] Test flakiness rate
- [ ] Test execution time

---

## References

- [Flutter Testing Best Practices](https://docs.flutter.dev/testing/best-practices)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget/introduction)
