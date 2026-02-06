import 'package:flutter/material.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/screens/net_worth/net_worth_details.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

class AssetLiabilityCard extends ConsumerWidget {
  final MonthlySummary summary;
  final AppColors semantic;
  final VoidCallback onLoad;

  const AssetLiabilityCard({
    super.key,
    required this.summary,
    required this.semantic,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivate = ref.watch(privacyProvider);
    final totalAssets =
        (summary.netWorth + summary.creditCardDebt + summary.loansTotal)
            .toDouble();
    final totalLiabilities =
        (summary.creditCardDebt + summary.loansTotal).toDouble();

    return Row(
      children: [
        Expanded(
          child: _buildCard(
            context,
            title: "ASSETS",
            value: totalAssets,
            color: semantic.income,
            icon: Icons.account_balance_rounded,
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NetWorthDetailsScreen(
                          viewMode: NetWorthView.assets)));
              onLoad();
            },
            isPrivate: isPrivate,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCard(
            context,
            title: "LIABILITIES",
            value: totalLiabilities,
            color: semantic.overspent,
            icon: Icons.receipt_long_rounded,
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NetWorthDetailsScreen(
                          viewMode: NetWorthView.liabilities)));
              onLoad();
            },
            isPrivate: isPrivate,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required double value,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrivate,
  }) {
    return HoverWrapper(
      onTap: onTap,
      borderRadius: 24,
      glowColor: color,
      glowOpacity: 0.1,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: semantic.surfaceCombined.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: semantic.divider, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: semantic.secondaryText,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                CurrencyFormatter.format(value, isPrivate: isPrivate),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
