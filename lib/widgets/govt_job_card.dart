import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/govt_job_model.dart';
import '../l10n/app_localizations.dart';
import '../providers/jobs_provider.dart';
import '../views/jobs/govt_job_details_screen.dart';

class GovtJobCard extends StatelessWidget {
  final GovtJobModel job;
  final VoidCallback? onTap;

  const GovtJobCard({
    Key? key,
    required this.job,
    this.onTap,
  }) : super(key: key);

  Color _getStatusColor(GovtJobStatus status) {
    switch (status) {
      case GovtJobStatus.newAlert:
        return const Color(0xFF059669); // Emerald Green
      case GovtJobStatus.open:
        return const Color(0xFF2563EB); // Royal Blue
      case GovtJobStatus.closingSoon:
        return const Color(0xFFE11D48); // Rose Red
      case GovtJobStatus.expired:
        return const Color(0xFF64748B); // Slate Grey
    }
  }

  String _getStatusLabel(GovtJobStatus status, AppLocalizations l10n) {
    switch (status) {
      case GovtJobStatus.newAlert:
        return l10n.statusNew;
      case GovtJobStatus.open:
        return l10n.statusOpen;
      case GovtJobStatus.closingSoon:
        return l10n.statusClosingSoon;
      case GovtJobStatus.expired:
        return l10n.statusExpired;
    }
  }

  IconData _getStatusIcon(GovtJobStatus status) {
    switch (status) {
      case GovtJobStatus.newAlert:
        return Icons.auto_awesome_rounded;
      case GovtJobStatus.open:
        return Icons.check_circle_outline_rounded;
      case GovtJobStatus.closingSoon:
        return Icons.timer_outlined;
      case GovtJobStatus.expired:
        return Icons.history_rounded;
    }
  }

  String _getCategoryLabel(String cat, AppLocalizations l10n) {
    switch (cat.toLowerCase()) {
      case 'ssc':
        return l10n.catSsc;
      case 'upsc':
        return l10n.catUpsc;
      case 'railway':
        return l10n.catRailway;
      case 'banking':
        return l10n.catBanking;
      case 'defence':
        return l10n.catDefence;
      case 'police':
        return l10n.catPolice;
      case 'teaching':
        return l10n.catTeaching;
      case 'psu':
        return l10n.catPsu;
      case 'state_govt':
        return l10n.catStateGovt;
      default:
        return l10n.catOther;
    }
  }

  void _showNotificationModal(BuildContext context, AppLocalizations l10n, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Color(0xFFD97706),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.organization,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.postName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
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
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ModalItem(
                      label: l10n.filterCategory,
                      value: _getCategoryLabel(job.category, l10n),
                      icon: Icons.category_outlined,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    _ModalItem(
                      label: "Vacancies",
                      value: l10n.vacanciesLabel(job.vacancies),
                      icon: Icons.groups_rounded,
                      isDark: isDark,
                      highlightColor: const Color(0xFFD97706),
                    ),
                    const SizedBox(height: 14),
                    _ModalItem(
                      label: l10n.filterQualification,
                      value: job.qualification,
                      icon: Icons.school_outlined,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    if (job.ageLimit != null) ...[
                      _ModalItem(
                        label: "Age Limit",
                        value: job.ageLimit!,
                        icon: Icons.person_outline_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (job.payScale != null) ...[
                      _ModalItem(
                        label: "Salary / Pay Scale",
                        value: job.payScale!,
                        icon: Icons.currency_rupee_rounded,
                        isDark: isDark,
                        highlightColor: const Color(0xFF059669),
                      ),
                      const SizedBox(height: 14),
                    ],
                    _ModalItem(
                      label: l10n.startDateLabel,
                      value: job.applicationStartDate,
                      icon: Icons.calendar_month_outlined,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    _ModalItem(
                      label: l10n.lastDateLabel,
                      value: job.lastDate,
                      icon: Icons.event_busy_outlined,
                      isDark: isDark,
                      highlightColor: job.status == GovtJobStatus.closingSoon ? const Color(0xFFE11D48) : null,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloading official notification PDF...'),
                            backgroundColor: const Color(0xFF1E3A8A),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                      label: Text(l10n.downloadNotification),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E3A8A),
                        side: const BorderSide(color: Color(0xFF1E3A8A)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Redirecting to official government portal...'),
                            backgroundColor: const Color(0xFFD97706),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: Text(l10n.officialApply),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final jobsProv = Provider.of<JobsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSaved = jobsProv.isSaved(job.id);

    final statusColor = _getStatusColor(job.status);
    final statusLabel = _getStatusLabel(job.status, l10n);
    final statusIcon = _getStatusIcon(job.status);
    final categoryLabel = _getCategoryLabel(job.category, l10n);

    return InkWell(
      onTap: onTap ??
          () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GovtJobDetailsScreen(job: job),
                ),
              ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: job.status == GovtJobStatus.closingSoon
                ? const Color(0xFFE11D48).withOpacity(0.35)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: job.status == GovtJobStatus.closingSoon ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Organization & Status Badge & Save Icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: Color(0xFFD97706),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              job.organization,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: Color(0xFFD97706),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Status Badge & Category Tag
                      Row(
                        children: [
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: statusColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 11, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Job Category Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              categoryLabel,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Save Bookmark Icon
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isSaved
                        ? const Color(0xFFD97706)
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  onPressed: () async {
                    final saved = await jobsProv.toggleSave(job.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            saved ? l10n.jobSavedTooltip : l10n.jobRemovedTooltip,
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 2. Post Name
            Text(
              job.postName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.25,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 12),

            // 3. Vacancies & Qualification Chips
            Row(
              children: [
                // Vacancies
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.groups_rounded,
                        size: 14,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.vacanciesLabel(job.vacancies),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Qualification
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 13,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job.qualification,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // 4. Dates: Application Start Date & Last Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline_rounded,
                      size: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.startDateLabel}: ${job.applicationStartDate}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: 13,
                      color: job.status == GovtJobStatus.closingSoon
                          ? const Color(0xFFE11D48)
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.lastDateLabel}: ${job.lastDate}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: job.status == GovtJobStatus.closingSoon ? FontWeight.w800 : FontWeight.w600,
                        color: job.status == GovtJobStatus.closingSoon
                            ? const Color(0xFFE11D48)
                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;
  final Color? highlightColor;

  const _ModalItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: highlightColor ?? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: highlightColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
