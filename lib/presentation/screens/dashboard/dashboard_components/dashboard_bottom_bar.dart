import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/cards/credit_cards.dart';
import 'package:trueledger/presentation/screens/transactions/monthly_history.dart';
import 'package:trueledger/presentation/screens/analysis/analysis_screen.dart';
import 'package:trueledger/presentation/screens/loans/loans.dart';

class DashboardBottomBar extends StatelessWidget {
  final VoidCallback onLoad;

  const DashboardBottomBar({
    super.key,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final padding = MediaQuery.of(context).padding;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + padding.bottom),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: semantic.surfaceCombined.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: semantic.divider, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildActionIcon(
                  context,
                  Icons.account_balance_rounded,
                  "Accounts",
                  semantic.income,
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoansScreen())),
                  semantic,
                ),
                _buildActionIcon(
                  context,
                  Icons.credit_card_rounded,
                  "Cards",
                  semantic.primary,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CreditCardsScreen())),
                  semantic,
                ),
                _buildActionIcon(
                  context,
                  Icons.auto_graph_rounded,
                  "Analysis",
                  const Color(0xFFA855F7),
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AnalysisScreen())),
                  semantic,
                ),
                _buildActionIcon(
                  context,
                  Icons.history_toggle_off_rounded,
                  "History",
                  semantic.warning,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MonthlyHistoryScreen())),
                  semantic,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(BuildContext context, IconData icon, String label,
      Color iconColor, VoidCallback onTap, AppColors semantic) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: iconColor.withValues(alpha: 0.9)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: semantic.secondaryText,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
