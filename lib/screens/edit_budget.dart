import 'package:flutter/material.dart';

import '../models/models.dart';
import '../logic/currency_helper.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/repository_providers.dart';

class EditBudgetScreen extends ConsumerStatefulWidget {
  final Budget budget;
  const EditBudgetScreen({super.key, required this.budget});

  @override
  ConsumerState<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends ConsumerState<EditBudgetScreen> {
  late TextEditingController limitCtrl;

  @override
  void initState() {
    super.initState();
    limitCtrl =
        TextEditingController(text: widget.budget.monthlyLimit.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ${widget.budget.category} Budget"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _delete,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            TextField(
              controller: limitCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monthly Limit",
                prefixText: "${CurrencyHelper.symbol} ",
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.05),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("UPDATE BUDGET",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _update() async {
    final repo = ref.read(financialRepositoryProvider);
    await repo.updateBudget(widget.budget.id, int.parse(limitCtrl.text));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final repo = ref.read(financialRepositoryProvider);
    await repo.deleteItem('budgets', widget.budget.id);
    if (mounted) Navigator.pop(context);
  }
}
