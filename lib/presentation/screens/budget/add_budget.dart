import 'package:flutter/material.dart';

import 'package:trueledger/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final categoryCtrl = TextEditingController();
  final limitCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Budget")),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            TextField(
              controller: categoryCtrl,
              decoration:
                  const InputDecoration(labelText: "Category (e.g. Food)"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: limitCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monthly Limit",
                prefixText: "${CurrencyFormatter.symbol} ",
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text("CREATE BUDGET"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final category = categoryCtrl.text.trim();
    final limitText = limitCtrl.text.trim();

    if (category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Category cannot be empty")));
      return;
    }
    if (limitText.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Limit cannot be empty")));
      return;
    }

    final limit = int.tryParse(limitText);
    if (limit == null || limit < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter a valid non-negative limit")));
      return;
    }

    final repo = ref.read(financialRepositoryProvider);
    await repo.addBudget(category, limit);
    if (mounted) Navigator.pop(context);
  }
}
