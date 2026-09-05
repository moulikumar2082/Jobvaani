import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/models/notification_model.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/jobs_provider.dart';
import '../services/notification_service.dart';

/// Modal sheet to inspect FCM device token, toggle push channels,
/// and simulate incoming push notifications for testing (Step 23).
class PushNotificationSettingsSheet extends StatefulWidget {
  const PushNotificationSettingsSheet({Key? key}) : super(key: key);

  @override
  State<PushNotificationSettingsSheet> createState() =>
      _PushNotificationSettingsSheetState();
}

class _PushNotificationSettingsSheetState
    extends State<PushNotificationSettingsSheet> {
  String? _fcmToken;
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await NotificationService.instance.getDeviceToken();
    if (mounted) {
      setState(() {
        _fcmToken = token;
      });
    }
  }

  Future<void> _simulatePush(NotificationType type, BuildContext context) async {
    setState(() => _isSimulating = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final payload = await NotificationService.instance.simulateIncomingPush(type);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.notifications_active_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${payload.title}: ${payload.body}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E3A8A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context);

    final maskedToken = _fcmToken != null && _fcmToken!.length > 18
        ? '${_fcmToken!.substring(0, 10)}••••••••${_fcmToken!.substring(_fcmToken!.length - 8)}'
        : (_fcmToken ?? 'Generating token...');

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cloud_sync_rounded,
                    color: Color(0xFF1E3A8A),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.fcmSettingsTitle,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF059669),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.permissionGranted,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // FCM Device Token Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.fcmTokenLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (_fcmToken != null) {
                            Clipboard.setData(ClipboardData(text: _fcmToken!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.fcmTokenCopied),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.copy_rounded,
                                size: 14, color: Color(0xFF1E3A8A)),
                            const SizedBox(width: 4),
                            Text(
                              l10n.copyJobLink,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    maskedToken,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.shield_rounded, size: 13, color: Color(0xFF059669)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.fcmTokenSecurelyStored,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 4 Supported Notification Channels
            Text(
              l10n.notificationSettings,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),

            _buildChannelTile(
              icon: Icons.work_outline_rounded,
              color: const Color(0xFF1E3A8A),
              title: l10n.channelNewJobMatches,
              value: auth.notifJobMatches,
              onChanged: (val) => auth.updateNotificationSettings(jobMatches: val),
              isDark: isDark,
            ),
            _buildChannelTile(
              icon: Icons.account_balance_outlined,
              color: const Color(0xFFD97706),
              title: l10n.channelGovtAlerts,
              value: auth.notifGovtAlerts,
              onChanged: (val) => auth.updateNotificationSettings(govtAlerts: val),
              isDark: isDark,
            ),
            _buildChannelTile(
              icon: Icons.timer_outlined,
              color: const Color(0xFFE11D48),
              title: l10n.channelDeadlines,
              value: auth.notifDeadlines,
              onChanged: (val) => auth.updateNotificationSettings(deadlines: val),
              isDark: isDark,
            ),
            _buildChannelTile(
              icon: Icons.info_outline_rounded,
              color: const Color(0xFF059669),
              title: l10n.channelSystem,
              value: auth.notifRecommendations,
              onChanged: (val) => auth.updateNotificationSettings(recommendations: val),
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // Simulate Push Alerts Testing Section
            Text(
              l10n.simulatePushAlert,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSimulateButton(
                  label: l10n.channelNewJobMatches,
                  icon: Icons.work_outline_rounded,
                  type: NotificationType.newJobMatch,
                  context: context,
                ),
                _buildSimulateButton(
                  label: l10n.channelGovtAlerts,
                  icon: Icons.account_balance_outlined,
                  type: NotificationType.govtJobAlert,
                  context: context,
                ),
                _buildSimulateButton(
                  label: l10n.channelDeadlines,
                  icon: Icons.timer_outlined,
                  type: NotificationType.deadlineReminder,
                  context: context,
                ),
                _buildSimulateButton(
                  label: l10n.channelSystem,
                  icon: Icons.notifications_none_rounded,
                  type: NotificationType.system,
                  context: context,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelTile({
    required IconData icon,
    required Color color,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: const Color(0xFF1E3A8A),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSimulateButton({
    required String label,
    required IconData icon,
    required NotificationType type,
    required BuildContext context,
  }) {
    return OutlinedButton.icon(
      onPressed: _isSimulating ? null : () => _simulatePush(type, context),
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
