import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/utils/date_helper.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/domain/models/models.dart';

class PaymentCalendar extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> bills;
  final AppColors semantic;

  const PaymentCalendar(
      {super.key, required this.bills, required this.semantic});

  @override
  ConsumerState<PaymentCalendar> createState() => _PaymentCalendarState();
}

class _PaymentCalendarState extends ConsumerState<PaymentCalendar> {
  late DateTime _focusedMonth;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  List<Map<String, dynamic>> _getEventsForDay(
      int day, List<String> paidLabels) {
    final targetDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    final events = <Map<String, dynamic>>[];

    for (var bill in widget.bills) {
      final dueDateStr = bill['due']?.toString() ?? '';

      if (bill['isRecurring'] == false) {
        final nextDue = DateHelper.getNextOccurrence(dueDateStr);
        if (nextDue != null) {
          if (nextDue.year != targetDate.year ||
              nextDue.month != targetDate.month ||
              nextDue.day != targetDate.day) {
            continue;
          }
        }
      }

      final date = _parseDueDate(dueDateStr);
      if (date != null) {
        if (date.year == targetDate.year &&
            date.month == targetDate.month &&
            date.day == targetDate.day) {
          final billCopy = Map<String, dynamic>.from(bill);
          final name = (billCopy['name'] ?? billCopy['title'] ?? '')
              .toString()
              .toLowerCase();

          if (billCopy['type'] == 'CREDIT DUE') {
            final isCurrentMonth = _focusedMonth.year == DateTime.now().year &&
                _focusedMonth.month == DateTime.now().month;
            if (!isCurrentMonth) {
              billCopy['isPaid'] = false;
            }
          } else if (name.isNotEmpty) {
            billCopy['isPaid'] = paidLabels.any((label) {
              final l = label.toLowerCase();
              return l.contains(name) || name.contains(l);
            });
          }
          events.add(billCopy);
        }
      }
    }
    return events;
  }

  DateTime? _parseDueDate(String due) {
    return DateHelper.parseDue(due, relativeTo: _focusedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth(_focusedMonth);
    final firstDayWeekday =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;

    final isTouch = Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android;

    final monthStr = DateFormat('yyyy-MM').format(_focusedMonth);
    final paidLabelsAsync = ref.watch(paidLabelsProvider(monthStr));
    final paidLabels = paidLabelsAsync.value ?? [];

    final mainContent = AnimatedContainer(
      duration: 300.ms,
      curve: Curves.easeOutQuint,
      // ignore: deprecated_member_use
      transform: Matrix4.identity()..scale(_isHovered ? 1.01 : 1.0),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: _isHovered
                ? widget.semantic.secondaryText.withValues(alpha: 0.5)
                : widget.semantic.divider),
        boxShadow: [
          if (_isHovered)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    DateFormat('MMMM yyyy').format(_focusedMonth).toUpperCase(),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: widget.semantic.secondaryText)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                              _focusedMonth.year, _focusedMonth.month - 1);
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                              _focusedMonth.year, _focusedMonth.month + 1);
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                  ],
                )
              ],
            ),
          ),
          _buildSummaryBar(paidLabels),
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: daysInMonth + (firstDayWeekday - 1),
            itemBuilder: (context, index) {
              if (index < firstDayWeekday - 1) {
                return const SizedBox();
              }
              final day = index - (firstDayWeekday - 1) + 1;
              final events = _getEventsForDay(day, paidLabels);
              final isToday = day == DateTime.now().day &&
                  _focusedMonth.month == DateTime.now().month &&
                  _focusedMonth.year == DateTime.now().year;

              final allPaid =
                  events.isNotEmpty && events.every((e) => e['isPaid'] == true);

              return InkWell(
                onTap: events.isNotEmpty
                    ? () => _showDayDetails(day, events)
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: 400.ms,
                  decoration: BoxDecoration(
                    color: isToday
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1)
                        : (allPaid
                            ? Colors.green.withValues(alpha: 0.05)
                            : (events.isNotEmpty
                                ? widget.semantic.surfaceCombined
                                : Colors.transparent)),
                    borderRadius: BorderRadius.circular(12),
                    border: isToday
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary)
                        : (allPaid
                            ? Border.all(
                                color: Colors.green.withValues(alpha: 0.2))
                            : null),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("$day",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: events.isNotEmpty || isToday
                                    ? FontWeight.w900
                                    : FontWeight.normal,
                                color: allPaid
                                    ? Colors.green
                                    : (events.isNotEmpty || isToday
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                        : Colors.grey))),
                        if (events.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          if (allPaid)
                            const Icon(Icons.check_rounded,
                                size: 10, color: Colors.green)
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: events.take(4).map((e) {
                                Color dotColor = widget.semantic.secondaryText;
                                if (e['isPaid'] == true) {
                                  dotColor = widget.semantic.divider;
                                } else {
                                  if (e['type'] == 'CREDIT DUE') {
                                    dotColor = Colors.red;
                                  } else if (e['type'] == 'LOAN EMI') {
                                    dotColor = Colors.orange;
                                  } else if (e['type'] == 'SUBSCRIPTION') {
                                    dotColor = widget.semantic.overspent;
                                  }
                                }

                                return Container(
                                  width: 3,
                                  height: 3,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                      color: dotColor, shape: BoxShape.circle),
                                );
                              }).toList(),
                            )
                        ]
                      ],
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (index % 7 * 50).ms, duration: 400.ms)
                  .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack);
            },
          )
        ],
      ),
    ).animate().fadeIn(duration: 800.ms);

    if (isTouch) {
      return mainContent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: mainContent,
    );
  }

  Widget _buildSummaryBar(List<String> paidLabels) {
    final isPrivate = ref.watch(privacyProvider);
    double totalSum = 0;
    double totalPaid = 0;

    final daysInMonth = _getDaysInMonth(_focusedMonth);
    for (int d = 1; d <= daysInMonth; d++) {
      final events = _getEventsForDay(d, paidLabels);
      for (var e in events) {
        final amount = (e['amount'] as num).toDouble();
        totalSum += amount;
        if (e['isPaid'] == true) {
          totalPaid += amount;
        }
      }
    }

    final totalDue = totalSum - totalPaid;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: widget.semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
                "TOTAL DUE", totalDue, widget.semantic.overspent, isPrivate),
          ),
          Container(
            width: 1,
            height: 24,
            color: widget.semantic.divider,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child:
                _buildSummaryItem("PAID", totalPaid, Colors.green, isPrivate),
          ),
          const SizedBox(width: 8),
          if (totalSum > 0)
            CircularProgressIndicator(
              value: totalPaid / totalSum,
              strokeWidth: 3,
              backgroundColor: widget.semantic.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                  totalDue == 0 ? Colors.green : widget.semantic.overspent),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSummaryItem(
      String label, double amount, Color color, bool isPrivate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
              isPrivate
                  ? "•••"
                  : CurrencyFormatter.format(amount, compact: true),
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w900, color: color)),
        ),
      ],
    );
  }

  void _showDayDetails(int day, List<Map<String, dynamic>> events) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd-MM-yyyy').format(
                        DateTime(_focusedMonth.year, _focusedMonth.month, day)),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: widget.semantic.secondaryText),
                  ),
                  const SizedBox(height: 16),
                  ...events.map((e) => _buildDetailItem(e, day)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleMarkAsPaid(Map<String, dynamic> bill, int day) async {
    final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    final dateStr = date.toIso8601String();

    final name = bill['name'] ?? bill['title'] ?? 'Bill';
    final amount = (bill['amount'] as num).toDouble();
    final type = bill['type'];

    String txType = 'Variable';
    String category = 'Others';
    Set<TransactionTag> tags = {};

    if (type == 'LOAN EMI' || type == 'BORROWING DUE') {
      txType = 'Fixed';
      category = 'EMI / Payment: $name';
      tags = {TransactionTag.loanEmi};
    } else if (type == 'SUBSCRIPTION') {
      txType = 'Variable';
      category = 'Subscription';
      tags = {TransactionTag.transfer};
    } else if (type == 'CREDIT DUE') {
      txType = 'Fixed';
      category = 'Credit Card Payment: $name';
      tags = {TransactionTag.transfer};

      final idStr = bill['id'] as String;
      if (idStr.startsWith('cc_')) {
        final id = int.tryParse(idStr.substring(3));
        if (id != null) {
          await ref
              .read(financialRepositoryProvider)
              .payCreditCardBill(id, amount);
        }
      }
    } else if (type == 'INVESTMENT DUE') {
      txType = 'Investment';
      category = 'Investment';
      tags = {TransactionTag.transfer};
    } else if (type == 'RECURRING INCOME') {
      txType = 'Income';
      category = 'Income';
      tags = {TransactionTag.income};
    } else if (type == 'RECURRING EXPENSE') {
      txType = 'Variable';
      category = 'Others';
      tags = {TransactionTag.transfer};
    }

    try {
      await ref.read(financialRepositoryProvider).addEntry(
            txType,
            amount,
            category,
            "Payment for $name (via Calendar)",
            dateStr,
            tags: tags,
          );

      // Refresh data
      ref.invalidate(dashboardProvider);
      final monthStr = DateFormat('yyyy-MM').format(_focusedMonth);
      ref.invalidate(paidLabelsProvider(monthStr));

      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$name marked as paid"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to mark as paid: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailItem(Map<String, dynamic> bill, int day) {
    IconData icon = Icons.receipt_long;
    Color color = widget.semantic.secondaryText;

    if (bill['type'] == 'SUBSCRIPTION') {
      icon = Icons.subscriptions;
      color = widget.semantic.overspent;
    } else if (bill['type'] == 'LOAN EMI') {
      icon = Icons.account_balance;
      color = Colors.orange;
    } else if (bill['type'] == 'CREDIT DUE') {
      icon = Icons.credit_card;
      color = Colors.red;
    } else if (bill['type'] == 'BORROWING DUE') {
      icon = Icons.person;
      color = Colors.purple;
    }

    final isPaid = bill['isPaid'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.semantic.surfaceCombined
            .withValues(alpha: isPaid ? 0.4 : 1.0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isPaid
                ? widget.semantic.divider.withValues(alpha: 0.2)
                : widget.semantic.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isPaid ? 0.05 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(isPaid ? Icons.check_circle_rounded : icon,
                color: isPaid ? widget.semantic.secondaryText : color,
                size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill['name'] ?? bill['title'] ?? 'Bill',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: isPaid ? TextDecoration.lineThrough : null,
                      color: isPaid
                          ? widget.semantic.secondaryText
                          : Theme.of(context).colorScheme.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  bill['type'].toString().toUpperCase(),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color:
                          widget.semantic.secondaryText.withValues(alpha: 0.6),
                      letterSpacing: 1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(bill['amount']),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    decoration: isPaid ? TextDecoration.lineThrough : null,
                    color: isPaid
                        ? widget.semantic.secondaryText
                        : widget.semantic.overspent),
              ),
              if (isPaid)
                Text(
                  "PAID",
                  style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Colors.green.shade700,
                      letterSpacing: 1),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: GestureDetector(
                    onTap: () => _handleMarkAsPaid(bill, day),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded,
                              size: 10, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            "MARK PAID",
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: Colors.green.shade700,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
