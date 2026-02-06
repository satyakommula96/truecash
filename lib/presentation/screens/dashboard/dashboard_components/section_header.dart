import 'package:flutter/material.dart';
import 'package:trueledger/core/theme/theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String sub;
  final AppColors semantic;
  final VoidCallback? onAdd;

  const SectionHeader({
    super.key,
    required this.title,
    required this.sub,
    required this.semantic,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: semantic.secondaryText,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: semantic.text,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),
          if (onAdd != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: semantic.divider, width: 1.5),
                    color: semantic.surfaceCombined.withValues(alpha: 0.3),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 22,
                    color: semantic.text,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
