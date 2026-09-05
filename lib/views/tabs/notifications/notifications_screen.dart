import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/notification_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/jobs_provider.dart';
import '../../jobs/job_details_screen.dart';
import '../../jobs/govt_job_details_screen.dart';
import '../../../widgets/push_notification_settings_sheet.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all'; // 'all', 'unread', 'match', 'govt', 'deadline'

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notif, JobsProvider jobsProv) {
    // 1. Mark as read
    jobsProv.markNotificationAsRead(notif.id);

    // 2. Route if related job exists
    if (notif.relatedJobId != null) {
      if (notif.targetRoute == 'govt_job_details') {
        final govtJob = jobsProv.getGovtJobById(notif.relatedJobId!);
        if (govtJob != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GovtJobDetailsScreen(job: govtJob),
            ),
          );
          return;
        }
      }

      final job = jobsProv.getJobById(notif.relatedJobId!);
      if (job != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => JobDetailsScreen(job: job),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final jobsProv = Provider.of<JobsProvider>(context);

    final allNotifs = jobsProv.notifications;
    final unreadCount = jobsProv.unreadNotifications;

    // Filter notifications
    List<NotificationModel> displayNotifs = allNotifs;
    if (_selectedFilter == 'unread') {
      displayNotifs = allNotifs.where((n) => !n.isRead).toList();
    } else if (_selectedFilter == 'match') {
      displayNotifs = allNotifs.where((n) => n.type == NotificationType.newJobMatch).toList();
    } else if (_selectedFilter == 'govt') {
      displayNotifs = allNotifs.where((n) => n.type == NotificationType.govtJobAlert).toList();
    } else if (_selectedFilter == 'deadline') {
      displayNotifs = allNotifs.where((n) => n.type == NotificationType.deadlineReminder).toList();
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Text(
              l10n.notificationsTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                jobsProv.markAllNotificationsAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.allReadSuccess),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: Text(
                l10n.markAllAsRead,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: l10n.fcmSettingsTitle,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const PushNotificationSettingsSheet(),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFilterChip(
                  label: '${l10n.filterAll} (${allNotifs.length})',
                  isSelected: _selectedFilter == 'all',
                  onSelected: () => setState(() => _selectedFilter = 'all'),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '${l10n.filterUnread} ($unreadCount)',
                  isSelected: _selectedFilter == 'unread',
                  onSelected: () => setState(() => _selectedFilter = 'unread'),
                  isDark: isDark,
                  hasBadge: unreadCount > 0,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: l10n.notifTypeNewJobMatch,
                  isSelected: _selectedFilter == 'match',
                  onSelected: () => setState(() => _selectedFilter = 'match'),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: l10n.notifTypeGovtAlert,
                  isSelected: _selectedFilter == 'govt',
                  onSelected: () => setState(() => _selectedFilter = 'govt'),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: l10n.notifTypeDeadlineReminder,
                  isSelected: _selectedFilter == 'deadline',
                  onSelected: () => setState(() => _selectedFilter = 'deadline'),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
      body: displayNotifs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 38,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.noNotifications,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noNotificationsDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              physics: const BouncingScrollPhysics(),
              itemCount: displayNotifs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, index) {
                final notif = displayNotifs[index];
                return _NotificationCard(
                  notif: notif,
                  timeAgo: _formatTimeAgo(notif.timestamp),
                  onTap: () => _handleNotificationTap(context, notif, jobsProv),
                  onToggleRead: () => jobsProv.toggleNotificationRead(notif.id),
                );
              },
            ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required bool isDark,
    bool hasBadge = false,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
        color: isSelected
            ? Colors.white
            : (hasBadge
                ? const Color(0xFFE11D48)
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569))),
      ),
      selectedColor: const Color(0xFF1E3A8A),
      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF1E3A8A)
            : (hasBadge
                ? const Color(0xFFE11D48).withOpacity(0.4)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notif;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback onToggleRead;

  const _NotificationCard({
    required this.notif,
    required this.timeAgo,
    required this.onTap,
    required this.onToggleRead,
  });

  _NotifStyle _getStyle(NotificationType type, AppLocalizations l10n) {
    switch (type) {
      case NotificationType.newJobMatch:
        return _NotifStyle(
          icon: Icons.auto_awesome_rounded,
          color: const Color(0xFF059669),
          label: l10n.notifTypeNewJobMatch,
        );
      case NotificationType.govtJobAlert:
        return _NotifStyle(
          icon: Icons.account_balance_rounded,
          color: const Color(0xFFD97706),
          label: l10n.notifTypeGovtAlert,
        );
      case NotificationType.deadlineReminder:
        return _NotifStyle(
          icon: Icons.timer_outlined,
          color: const Color(0xFFE11D48),
          label: l10n.notifTypeDeadlineReminder,
        );
      case NotificationType.recommendation:
        return _NotifStyle(
          icon: Icons.thumb_up_alt_outlined,
          color: const Color(0xFF2563EB),
          label: l10n.notifTypeRecommendation,
        );
      case NotificationType.system:
      default:
        return _NotifStyle(
          icon: Icons.notifications_active_outlined,
          color: const Color(0xFF7C3AED),
          label: l10n.notifTypeSystem,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = _getStyle(notif.type, l10n);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead
              ? (isDark ? const Color(0xFF1E293B) : Colors.white)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F7FF)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead
                ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                : const Color(0xFF1E3A8A).withOpacity(0.4),
            width: notif.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: style.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(style.icon, color: style.color, size: 20),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type pill & timestamp row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: style.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          style.label,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: style.color,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          if (!notif.isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E3A8A),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    notif.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: notif.isRead ? FontWeight.w700 : FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Message body
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    ),
                  ),

                  // Action hint
                  if (notif.relatedJobId != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          l10n.viewDetails,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: Color(0xFF1E3A8A),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifStyle {
  final IconData icon;
  final Color color;
  final String label;

  const _NotifStyle({
    required this.icon,
    required this.color,
    required this.label,
  });
}
