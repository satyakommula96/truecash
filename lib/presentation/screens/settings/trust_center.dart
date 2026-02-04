import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/backup_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trueledger/domain/usecases/get_local_backups_usecase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:trueledger/core/config/app_config.dart';
import 'package:trueledger/domain/usecases/restore_from_local_file_usecase.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';

final databaseStatsProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(financialRepositoryProvider).getDatabaseStats();
});

class TrustCenterScreen extends ConsumerWidget {
  const TrustCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final statsAsync = ref.watch(databaseStatsProvider);
    final lastBackup = ref.watch(lastBackupTimeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title:
            const Text("Trust", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFraming(context, semantic),
            const SizedBox(height: 32),
            _buildSectionHeader("OUR GUARANTEES", semantic),
            const SizedBox(height: 16),
            _buildGuaranteesGrid(semantic),
            const SizedBox(height: 32),
            _buildSectionHeader("WHAT WE NEVER DO", semantic),
            const SizedBox(height: 16),
            _buildNeverList(semantic),
            const SizedBox(height: 32),
            _buildSectionHeader("DATA HEALTH", semantic),
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) => GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                      label: "Total Records",
                      value: stats['total_records'].toString(),
                      semantic: semantic),
                  _StatCard(
                      label: "Expenses",
                      value: stats['variable'].toString(),
                      semantic: semantic),
                  _StatCard(
                      label: "Income",
                      value: stats['income'].toString(),
                      semantic: semantic),
                  _StatCard(
                      label: "Budgets",
                      value: stats['budgets'].toString(),
                      semantic: semantic),
                ],
              ),
              loading: () => const Center(
                  child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              )),
              error: (e, s) => Text("Error loading stats: $e"),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader("BACKUP CONFIDENCE", semantic),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: semantic.surfaceCombined,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: semantic.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          color: semantic.success, size: 20),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Local Backup Status",
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            Text("Last backup: $lastBackup",
                                style: TextStyle(
                                    color: semantic.secondaryText,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Icon(Icons.update_rounded,
                          size: 14, color: semantic.secondaryText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Next automatic backup: At next application launch",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: semantic.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child:
                      _buildSectionHeader("AVAILABLE LOCAL BACKUPS", semantic),
                ),
                if (!kIsWeb &&
                    (Platform.isWindows ||
                        Platform.isLinux ||
                        Platform.isMacOS))
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        final directory =
                            await getApplicationDocumentsDirectory();
                        final backupPath =
                            '${directory.path}/${AppConfig.backupFolderName}';
                        final backupDir = Directory(backupPath);

                        if (!await backupDir.exists()) {
                          await backupDir.create(recursive: true);
                        }

                        final uri = Uri.file(backupPath);
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Could not open folder: $e")),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.folder_open_rounded, size: 16),
                    label: const Text("VIEW FOLDER",
                        style: TextStyle(fontSize: 10)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ref.watch(localBackupsProvider).when(
                  data: (backups) {
                    if (backups.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            "No local backups found yet.",
                            style: TextStyle(
                                fontSize: 12, color: semantic.secondaryText),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: backups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final file = backups[index];
                        return _buildBackupItem(context, ref, file, semantic);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text("Error: $e"),
                ),
            const SizedBox(height: 48),
            _buildChangePolicy(semantic),
            const SizedBox(height: 24),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "TrueLedger uses SQLCipher AES-256 for database encryption on supported platforms.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: semantic.secondaryText),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppColors semantic) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: semantic.secondaryText,
      ),
    );
  }

  Widget _buildFraming(BuildContext context, AppColors semantic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "This page describes product-level guarantees enforced by design.",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: semantic.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "TrueLedger is built on the principle that your financial life is yours alone. We believe in absolute privacy, which is why your data never leaves your device unless you choose to move it.",
          style: TextStyle(
            fontSize: 15,
            color: semantic.text,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildGuaranteesGrid(AppColors semantic) {
    const guarantees = [
      (
        "No Ads",
        "We will never clutter your experience with advertisements or sponsored content."
      ),
      (
        "No Tracking",
        "We don't track your behavior, location, or usage patterns. You are not a data point."
      ),
      (
        "No Profiling",
        "Your financial habits are private. We don't build profiles for targeting or selling."
      ),
      (
        "100% Local",
        "Your database exists only on your device. We have no 'cloud' access to your logs."
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: guarantees.length,
      itemBuilder: (context, index) {
        final g = guarantees[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: semantic.surfaceCombined,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: semantic.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(g.$1,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 13)),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  g.$2,
                  style: TextStyle(
                      fontSize: 11, color: semantic.secondaryText, height: 1.4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNeverList(AppColors semantic) {
    final nevers = [
      "No ads",
      "No analytics or tracking SDKs",
      "No profiling or behavior scoring",
      "No cross-user comparison",
      "No bank scraping",
      "No selling or sharing user data",
      "All data stays on the user’s device by default",
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: semantic.divider),
      ),
      child: Column(
        children: nevers
            .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: semantic.secondaryText,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: semantic.text,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildChangePolicy(AppColors semantic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: semantic.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Any modification to these guarantees must be documented in release notes.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: semantic.secondaryText,
        ),
      ),
    );
  }

  Widget _buildBackupItem(BuildContext context, WidgetRef ref, BackupFile file,
      AppColors semantic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: semantic.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.history_rounded, size: 20, color: semantic.secondaryText),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy • HH:mm').format(file.date),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(
                  _formatSize(file.size),
                  style: TextStyle(color: semantic.secondaryText, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings_backup_restore_rounded,
                size: 18, color: semantic.secondaryText),
            tooltip: "Restore",
            onPressed: () => _confirmRestore(context, ref, file),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, size: 18),
            onPressed: () {
              // ignore: deprecated_member_use
              Share.shareXFiles([XFile(file.path)],
                  text: 'TrueLedger Auto-Backup (${file.name})');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRestore(
      BuildContext context, WidgetRef ref, BackupFile file) async {
    final semantic = Theme.of(context).extension<AppColors>()!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Restore Data?",
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
            "This will REPLACE all your current data with the data from this backup. This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("CANCEL")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: semantic.overspent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("RESTORE NOW"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    final useCase = ref.read(restoreFromLocalFileUseCaseProvider);
    final result = await useCase(RestoreFromLocalFileParams(path: file.path));

    if (context.mounted) {
      Navigator.pop(context); // Pop loading
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Restore completed successfully!")),
        );
        // Navigate to dashboard and refresh
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Restore failed: ${result.failureOrThrow.message}")),
        );
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final AppColors semantic;

  const _StatCard(
      {required this.label, required this.value, required this.semantic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: semantic.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: semantic.secondaryText)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
