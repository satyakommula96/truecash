import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/utils/date_helper.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

class UpcomingBills extends StatelessWidget {
  final List<Map<String, dynamic>> bills;
  final AppColors semantic;

  const UpcomingBills({
    super.key,
    required this.bills,
    required this.semantic,
  });

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text("All bills are clear",
              style: TextStyle(
                  color: semantic.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: bills.asMap().entries.map((entry) {
          final index = entry.key;
          final b = entry.value;
          final isOverdue = DateHelper.isOverdue(b['due'].toString());

          return Padding(
            padding: EdgeInsets.only(right: 16, left: index == 0 ? 0 : 0),
            child: HoverWrapper(
              borderRadius: 24,
              glowColor: isOverdue ? semantic.overspent : semantic.primary,
              glowOpacity: 0.1,
              child: Container(
                width: 160,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: semantic.surfaceCombined.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: semantic.divider, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            (isOverdue ? semantic.overspent : semantic.primary)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        b['type'].toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          color:
                              isOverdue ? semantic.overspent : semantic.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      b['title'].toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: semantic.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        CurrencyFormatter.format(b['amount']),
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: semantic.text),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateHelper.formatDue(b['due'].toString()),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isOverdue
                            ? semantic.overspent
                            : semantic.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: (100 * index).ms, duration: 600.ms)
                .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuint),
          );
        }).toList(),
      ),
    );
  }
}
