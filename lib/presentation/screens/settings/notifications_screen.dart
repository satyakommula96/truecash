import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

class RefreshIntent extends Intent {
  const RefreshIntent();
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  Future<void> _cancelNotification(
      int id, String title, AppColors semantic) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: semantic.surfaceCombined.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: semantic.divider, width: 1.5)),
          title: Text('CANCEL NOTIFICATION',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.2,
                  color: semantic.text)),
          content: Text(
            'Are you sure you want to cancel "$title"?',
            style: TextStyle(
                color: semantic.text,
                fontWeight: FontWeight.w700,
                fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('NO',
                  style: TextStyle(
                      color: semantic.secondaryText,
                      fontWeight: FontWeight.w900,
                      fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: semantic.overspent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('YES',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.cancelNotification(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('NOTIFICATION "$title" CANCELLED'),
            backgroundColor: semantic.overspent,
          ),
        );
      }
    }
  }

  Future<void> _cancelAllNotifications(AppColors semantic) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: semantic.surfaceCombined.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: semantic.divider, width: 1.5)),
          title: Text('CANCEL ALL NOTIFICATIONS',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.2,
                  color: semantic.overspent)),
          content: const Text(
            'Are you sure you want to cancel all scheduled notifications?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('NO',
                  style: TextStyle(
                      color: semantic.secondaryText,
                      fontWeight: FontWeight.w900,
                      fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: semantic.overspent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('YES, CANCEL ALL',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('ALL NOTIFICATIONS CANCELLED'),
            backgroundColor: semantic.overspent,
          ),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(pendingNotificationsProvider);
    await ref.read(pendingNotificationsProvider.future);
  }

  IconData _getNotificationIcon(String? title) {
    if (title == null) return Icons.notifications_outlined;
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('reminder')) return Icons.alarm_rounded;
    if (lowerTitle.contains('credit') || lowerTitle.contains('bill')) {
      return Icons.credit_card_rounded;
    }
    if (lowerTitle.contains('daily')) return Icons.today_rounded;
    if (lowerTitle.contains('recurring') || lowerTitle.contains('automatic')) {
      return Icons.autorenew_rounded;
    }
    return Icons.notifications_rounded;
  }

  Color _getNotificationColor(String? title, AppColors semantic) {
    if (title == null) return semantic.primary;
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('daily')) return semantic.success;
    if (lowerTitle.contains('credit') || lowerTitle.contains('bill')) {
      return semantic.warning;
    }
    return semantic.primary;
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final notificationsAsync = ref.watch(pendingNotificationsProvider);

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyR):
            const RefreshIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR):
            const RefreshIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          RefreshIntent: CallbackAction<RefreshIntent>(
            onInvoke: (intent) => _handleRefresh(),
          ),
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('NOTIFICATIONS'),
            centerTitle: true,
            actions: [
              notificationsAsync.when(
                data: (notifications) {
                  if (notifications.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded),
                      tooltip: 'Cancel All',
                      onPressed: () => _cancelAllNotifications(semantic),
                    );
                  }
                  return const SizedBox();
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
                onPressed: _handleRefresh,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: semantic.primary,
            child: notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: _buildErrorState(semantic),
                ),
              ),
              data: (notifications) {
                if (notifications.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: _buildEmptyState(semantic),
                    ),
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final iconColor =
                        _getNotificationColor(notification.title, semantic);

                    return _buildNotificationItem(
                        notification, index, iconColor, semantic);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
      dynamic notification, int index, Color color, AppColors semantic) {
    return HoverWrapper(
      onTap: () {}, // No action for now
      borderRadius: 24,
      glowColor: color.withValues(alpha: 0.3),
      glowOpacity: 0.05,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: semantic.surfaceCombined.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: semantic.divider, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getNotificationIcon(notification.title),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (notification.title ?? 'UNTITLED').toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: semantic.text,
                        letterSpacing: 0.5),
                  ),
                  if (notification.body != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: semantic.secondaryText,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildCancelButton(
                () => _cancelNotification(
                      notification.id,
                      notification.title ?? 'Notification',
                      semantic,
                    ),
                semantic),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (50 * index).ms)
        .slideX(begin: 0.05, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildCancelButton(VoidCallback onTap, AppColors semantic) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: semantic.overspent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.close_rounded, size: 18, color: semantic.overspent),
      ),
    );
  }

  Widget _buildEmptyState(AppColors semantic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: semantic.divider.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 64,
              color: semantic.secondaryText.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'NO SCHEDULED ALERTS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: semantic.text,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifications will appear here once scheduled',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: semantic.secondaryText,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildErrorState(AppColors semantic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: semantic.overspent,
            ),
            const SizedBox(height: 16),
            Text(
              'ERROR LOADING NOTIFICATIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: semantic.text,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
