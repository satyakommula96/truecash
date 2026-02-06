import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/category_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

class ManageCategoriesScreen extends ConsumerStatefulWidget {
  final String? initialType;
  const ManageCategoriesScreen({super.key, this.initialType});

  @override
  ConsumerState<ManageCategoriesScreen> createState() =>
      _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState
    extends ConsumerState<ManageCategoriesScreen> {
  late String selectedType;
  final types = ['Variable', 'Fixed', 'Income', 'Investment', 'Subscription'];
  final categoryCtrl = TextEditingController();
  String? lastAddedCategory;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialType ?? 'Variable';
  }

  @override
  void dispose() {
    categoryCtrl.dispose();
    super.dispose();
  }

  void _addCategory() async {
    final name = categoryCtrl.text.trim();
    if (name.isEmpty) return;

    final repo = ref.read(financialRepositoryProvider);
    await repo.addCategory(name, selectedType);
    categoryCtrl.clear();
    ref.invalidate(categoriesProvider(selectedType));

    setState(() {
      lastAddedCategory = name;
    });

    if (mounted) {
      final semantic = Theme.of(context).extension<AppColors>()!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$name ADDED TO $selectedType".toUpperCase()),
          backgroundColor: semantic.primary,
        ),
      );
    }
  }

  void _deleteCategory(TransactionCategory category) async {
    final repo = ref.read(financialRepositoryProvider);
    await repo.deleteCategory(category.id!);
    ref.invalidate(categoriesProvider(category.type));

    if (mounted) {
      final semantic = Theme.of(context).extension<AppColors>()!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${category.name} DELETED".toUpperCase()),
          backgroundColor: semantic.overspent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final categoriesAsync = ref.watch(categoriesProvider(selectedType));

    return Scaffold(
      appBar: AppBar(
        title: const Text("CATEGORIES"),
        centerTitle: true,
        actions: [
          if (lastAddedCategory != null)
            IconButton(
              icon: Icon(Icons.check_circle_rounded, color: semantic.income),
              onPressed: () => Navigator.pop(context, lastAddedCategory),
              tooltip: "Use $lastAddedCategory",
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildTypeSelector(semantic),
          _buildAddInput(semantic),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) return _buildEmptyState(semantic);
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return _buildCategoryItem(cat, index, semantic);
                  },
                );
              },
              loading: () => Center(
                  child: CircularProgressIndicator(color: semantic.primary)),
              error: (err, stack) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(AppColors semantic) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: types.map((t) {
            final active = selectedType == t;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AnimatedContainer(
                duration: 300.ms,
                curve: Curves.easeOutQuart,
                child: ChoiceChip(
                  label: Text(t.toUpperCase()),
                  selected: active,
                  onSelected: (_) => setState(() => selectedType = t),
                  selectedColor: semantic.primary,
                  backgroundColor:
                      semantic.surfaceCombined.withValues(alpha: 0.5),
                  side: BorderSide(
                    color: active ? Colors.transparent : semantic.divider,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: active ? Colors.white : semantic.secondaryText,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAddInput(AppColors semantic) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: categoryCtrl,
              style: TextStyle(
                  color: semantic.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 14),
              decoration: InputDecoration(
                hintText: "Add new category...",
                hintStyle: TextStyle(
                    color: semantic.secondaryText.withValues(alpha: 0.5),
                    fontSize: 14),
                filled: true,
                fillColor: semantic.surfaceCombined.withValues(alpha: 0.5),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: semantic.divider, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: semantic.divider, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: semantic.primary, width: 2),
                ),
              ),
              onSubmitted: (_) => _addCategory(),
            ),
          ),
          const SizedBox(width: 12),
          HoverWrapper(
            onTap: _addCategory,
            borderRadius: 16,
            child: Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: semantic.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: semantic.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child:
                  const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
      TransactionCategory cat, int index, AppColors semantic) {
    return HoverWrapper(
      onTap: () => Navigator.pop(context, cat.name),
      borderRadius: 20,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
        decoration: BoxDecoration(
          color: semantic.surfaceCombined.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: semantic.divider, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: semantic.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(cat.name.isNotEmpty ? cat.name[0].toUpperCase() : "?",
                  style: TextStyle(
                      color: semantic.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                cat.name.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: semantic.text,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            _buildActionIcon(Icons.check_circle_outline_rounded,
                () => Navigator.pop(context, cat.name), semantic,
                color: semantic.income),
            const SizedBox(width: 8),
            _buildActionIcon(Icons.delete_outline_rounded,
                () => _deleteCategory(cat), semantic,
                color: semantic.overspent),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 40).ms)
        .slideX(begin: 0.05, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap, AppColors semantic,
      {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (color ?? semantic.text).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: color ?? semantic.text),
      ),
    );
  }

  Widget _buildEmptyState(AppColors semantic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: semantic.divider.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.category_rounded,
              size: 48,
              color: semantic.secondaryText.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "NO CATEGORIES YET",
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: semantic.text,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          Text(
            "Add your first category for $selectedType",
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: semantic.secondaryText),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}
