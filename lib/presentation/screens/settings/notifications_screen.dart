import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:trueledger/presentation/providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<fln.PendingNotificationRequest> _notifications = [];
  bool _isLoading = true;
  bool _isSupported = true;
  String _unsupportedMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final notificationService = ref.read(notificationServiceProvider);
    try {
      final notifications = await notificationService.getPendingNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
        _isSupported = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSupported = false;
        _unsupportedMessage =
            'Viewing scheduled notifications is not supported on this platform.';
      });
    }
  }

  Future<void> _cancelNotification(int id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Notification'),
        content: Text('Are you sure you want to cancel "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.cancelNotification(id);
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification "$title" cancelled')),
        );
      }
    }
  }

  Future<void> _cancelAllNotifications() async {
    if (_notifications.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel All Notifications'),
        content: Text(
            'Are you sure you want to cancel all ${_notifications.length} notification(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.cancelAllNotifications();
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications cancelled')),
        );
      }
    }
  }

  IconData _getNotificationIcon(String? title) {
    if (title == null) return Icons.notifications_outlined;
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('reminder')) {
      return Icons.alarm_outlined;
    } else if (lowerTitle.contains('credit') || lowerTitle.contains('bill')) {
      return Icons.credit_card_outlined;
    } else if (lowerTitle.contains('daily')) {
      return Icons.today_outlined;
    }
    return Icons.notifications_outlined;
  }

  Color _getNotificationColor(String? title) {
    if (title == null) return Colors.blue;
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('daily')) {
      return Colors.green;
    } else if (lowerTitle.contains('credit') || lowerTitle.contains('bill')) {
      return Colors.orange;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Notifications'),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Cancel All',
              onPressed: _cancelAllNotifications,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isSupported
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 64,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Not Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _unsupportedMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Notifications are still working, but viewing scheduled ones is not supported on Linux.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.outline.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Scheduled Notifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Notifications will appear here once scheduled',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          final iconColor =
                              _getNotificationColor(notification.title);

                          return Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? colorScheme.surfaceContainerHighest
                                  : colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: isDark ? 0.3 : 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getNotificationIcon(notification.title),
                                  color: iconColor,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                notification.title ?? 'Untitled Notification',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (notification.body != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      notification.body!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colorScheme.outline,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer
                                          .withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'ID: ${notification.id}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.red.shade400,
                                ),
                                tooltip: 'Cancel',
                                onPressed: () => _cancelNotification(
                                  notification.id,
                                  notification.title ?? 'Notification',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
