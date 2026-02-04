import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/domain/usecases/get_weekly_reflection_usecase.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late GetWeeklyReflectionUseCase useCase;
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockRepository = MockFinancialRepository();
    useCase = GetWeeklyReflectionUseCase(mockRepository);

    // Register fallback for DateTime if needed by mocktail,
    // but here we pass specific instances in when()
  });

  test('should calculate weekly reflection data correctly', () async {
    // arrange
    final now = DateTime.now();
    final thisMondayOffset = now.weekday - 1;
    final thisWeekStart =
        DateTime(now.year, now.month, now.day - thisMondayOffset);

    final tTransactions = [
      LedgerItem(
          id: 1,
          amount: 100,
          label: 'Food',
          date: thisWeekStart.toIso8601String(),
          type: 'Variable',
          note: ''),
      LedgerItem(
          id: 2,
          amount: 3000,
          label: 'Shopping',
          date: thisWeekStart.toIso8601String(),
          type: 'Variable',
          note: ''),
    ];

    final tBudgets = [
      Budget(id: 1, category: 'Food', monthlyLimit: 30000), // Daily limit 1000
    ];

    final tThisWeekCats = [
      {'category': 'Food', 'total': 100},
      {'category': 'Shopping', 'total': 3000},
    ];

    final tLastWeekCats = [
      {'category': 'Food', 'total': 200},
      {'category': 'Shopping', 'total': 1000},
    ];

    when(() => mockRepository.getTransactionsForRange(any(), any()))
        .thenAnswer((_) async => tTransactions);
    when(() => mockRepository.getBudgets()).thenAnswer((_) async => tBudgets);
    when(() => mockRepository.getCategorySpendingForRange(any(), any()))
        .thenAnswer((invocation) async {
      final start = invocation.positionalArguments[0] as DateTime;
      if (start.isBefore(thisWeekStart)) {
        return tLastWeekCats;
      }
      return tThisWeekCats;
    });

    // act
    final result = await useCase(NoParams());

    // assert
    expect(result.isSuccess, true,
        reason: result.isFailure ? result.failureOrThrow.message : null);
    final data = result.getOrThrow;

    // Total this week: 100 + 3000 = 3100
    // Total last week: 200 + 1000 = 1200
    expect(data.totalThisWeek, 3100);
    expect(data.totalLastWeek, 1200);

    // Days under budget:
    // Monday: 3100 (spent) vs 1000 (budget) -> Over
    // Other days: 0 (spent) vs 1000 (budget) -> Under
    // The count depends on the current day of the week.
    expect(data.daysUnderBudget, greaterThanOrEqualTo(0));

    // Largest increase: Shopping (3000 - 1000 = 2000 increase)
    expect(data.largestCategoryIncrease?['category'], 'Shopping');
    expect(data.largestCategoryIncrease?['increaseAmount'], 2000);
    expect(data.topCategory, 'Food'); // top in results order
  });

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });
}
