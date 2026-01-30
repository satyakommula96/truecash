import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';

class WeeklySummary extends ConsumerWidget {
  final int thisWeekSpend;
  final int lastWeekSpend;
  final AppColors semantic;

  const WeeklySummary({
    super.key,
    required this.thisWeekSpend,
    required this.lastWeekSpend,
    required this.semantic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacy = ref.watch(privacyProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final diff = thisWeekSpend - lastWeekSpend;
    final percentChange =
        lastWeekSpend > 0 ? ((diff / lastWeekSpend) * 100).round() : 0;
    final isUp = diff > 0;
    final isDown = diff < 0;

    Color changeColor;
    IconData changeIcon;

    if (isUp) {
      changeColor = semantic.overspent;
      changeIcon = Icons.trending_up_rounded;
    } else if (isDown) {
      changeColor = semantic.income;
      changeIcon = Icons.trending_down_rounded;
    } else {
      changeColor = semantic.secondaryText;
      changeIcon = Icons.trending_flat_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: semantic.divider.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "WEEK",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: semantic.secondaryText,
                ),
              ),
              const SizedBox(width: 6),
              Icon(changeIcon, size: 14, color: changeColor),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(thisWeekSpend, isPrivate: isPrivacy),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isUp
                ? "+$percentChange%"
                : isDown
                    ? "$percentChange%"
                    : "—",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: changeColor,
            ),
          ),
        ],
      ),
    );
  }
}
