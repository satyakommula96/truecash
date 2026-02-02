import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/domain/services/intelligence_service.dart';
// import 'package:trueledger/domain/models/models.dart'; // Unnecessary

final insightsProvider = Provider<List<AIInsight>>((ref) {
  final dashboardValues = ref.watch(dashboardProvider).asData?.value;
  if (dashboardValues == null) return [];

  final service = ref.watch(intelligenceServiceProvider);

  return service.generateInsights(
    summary: dashboardValues.summary,
    trendData: dashboardValues.trendData,
    budgets: dashboardValues.budgets,
    categorySpending: dashboardValues.categorySpending,
  );
});
