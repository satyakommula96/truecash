import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/theme.dart';

import 'dashboard_components/budget_section.dart';
import 'dashboard_components/trend_chart.dart';
import 'add_budget.dart';
import '../logic/currency_helper.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/repository_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  List<Budget> budgets = [];
  List<Map<String, dynamic>> trendData = [];
  List<Map<String, dynamic>> categoryData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final repo = ref.read(financialRepositoryProvider);
    final b = await repo.getBudgets();
    final t = await repo.getSpendingTrend();
    final c = await repo.getCategorySpending();
    if (mounted) {
      setState(() {
        budgets = b;
        trendData = t;
        categoryData = c;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("ANALYSIS & BUDGETS")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddBudgetScreen()));
          load();
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, 100 + MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (trendData.length >= 2) ...[
                    _buildInsightCard(trendData, semantic)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuint),
                    const SizedBox(height: 32),
                  ],
                  Text("SPENDING TREND",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: semantic.secondaryText))
                      .animate()
                      .fadeIn(delay: 200.ms),
                  const SizedBox(height: 16),
                  TrendChart(trendData: trendData, semantic: semantic)
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuint),
                  const SizedBox(height: 32),
                  Text("SPENDING BY CATEGORY",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: semantic.secondaryText))
                      .animate()
                      .fadeIn(delay: 600.ms),
                  const SizedBox(height: 16),
                  _buildCategoryBreakdown(categoryData, semantic),
                  const SizedBox(height: 32),
                  Text("LIVE TRACKING",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: semantic.secondaryText))
                      .animate()
                      .fadeIn(delay: 800.ms),
                  const SizedBox(height: 24),
                  BudgetSection(
                          budgets: budgets, semantic: semantic, onLoad: load)
                      .animate()
                      .fadeIn(delay: 1000.ms),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryBreakdown(
      List<Map<String, dynamic>> data, AppColors semantic) {
    if (data.isEmpty) {
      return const Text("No spending data yet.",
          style: TextStyle(color: Colors.grey));
    }

    // Find max value for progress bar calculation
    final maxVal = data.fold<int>(0,
        (prev, e) => (e['total'] as int) > prev ? (e['total'] as int) : prev);

    return Column(
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final total = item['total'] as int;
        final progress = maxVal == 0 ? 0.0 : total / maxVal;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['category'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  Text(CurrencyHelper.format(total),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: semantic.divider.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 8,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              semantic.expense,
                              semantic.expense.withValues(alpha: 0.7)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: semantic.expense.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]),
                    )
                        .animate()
                        .shimmer(
                            duration: 1200.ms,
                            color: Colors.white.withValues(alpha: 0.2))
                        .scaleX(
                            begin: 0,
                            end: 1,
                            duration: 800.ms,
                            curve: Curves.easeOutQuint,
                            alignment: Alignment.centerLeft),
                  ],
                );
              })
            ],
          ),
        )
            .animate()
            .fadeIn(delay: (20 * index).ms, duration: 400.ms)
            .slideX(begin: 0.05, end: 0, curve: Curves.easeOutQuint);
      }).toList(),
    );
  }

  Widget _buildInsightCard(
      List<Map<String, dynamic>> data, AppColors semantic) {
    if (data.length < 2) return const SizedBox();
    final current = data[0]['total'] as int;
    final last = data[1]['total'] as int;
    final diff = current - last;
    final isIncrease = diff > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: isIncrease
                ? [
                    semantic.overspent.withValues(alpha: 0.2),
                    semantic.overspent.withValues(alpha: 0.05)
                  ]
                : [
                    semantic.income.withValues(alpha: 0.2),
                    semantic.income.withValues(alpha: 0.05)
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isIncrease
                ? semantic.overspent.withValues(alpha: 0.3)
                : semantic.income.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  isIncrease
                      ? Icons.warning_amber_rounded
                      : Icons.thumb_up_alt_outlined,
                  color: isIncrease ? semantic.overspent : semantic.income),
              const SizedBox(width: 12),
              Text("MONTHLY INSIGHT",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: semantic.secondaryText)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              isIncrease
                  ? "Spending is up by ${CurrencyHelper.format(diff.abs())} compared to last month."
                  : "Great job! Spending decreased by ${CurrencyHelper.format(diff.abs())}.",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}
