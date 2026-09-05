import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/app_flow_provider.dart';
import '../../../providers/jobs_provider.dart';
import '../../../widgets/job_card.dart';
import '../../jobs/private_jobs_screen.dart';
import '../../jobs/government_jobs_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = Provider.of<AuthProvider>(context);
    final flow = Provider.of<AppFlowProvider>(context);
    final jobsProv = Provider.of<JobsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = auth.userName.trim().isNotEmpty ? auth.userName.trim() : 'Candidate';

    final latestList = jobsProv.latestJobs;
    final recommendedList = jobsProv.recommendedJobs;
    final closingSoonList = jobsProv.closingSoonJobs;
    final govtAlertsList = jobsProv.governmentAlerts;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 600));
          },
          color: const Color(0xFF1E3A8A),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // 1. Header with greeting and notification icon
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
                  child: Row(
                    children: [
                      // User Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF1E3A8A),
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'J',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Greeting & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homeGreeting(userName),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.findNextOpportunity,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification Icon with unread badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            onPressed: () {
                              flow.setTabIndex(3); // Navigate to Notifications Tab
                            },
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              size: 24,
                            ),
                            splashRadius: 22,
                          ),
                          if (jobsProv.unreadNotifications > 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE11D48),
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${jobsProv.unreadNotifications}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: InkWell(
                    onTap: () {
                      flow.setTabIndex(1); // Navigate to Search Tab
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF1E3A8A),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.searchJobsPlaceholder,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Color(0xFF1E3A8A),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Quick Categories (Government Jobs, Private Jobs, Internships)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 8),
                  child: SizedBox(
                    height: 104,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _QuickCategoryCard(
                          title: l10n.quickGovtJobs,
                          count: '1,420+ Openings',
                          icon: Icons.account_balance_rounded,
                          accentColor: const Color(0xFFD97706),
                          isSelected: jobsProv.selectedHomeCategory == 'govt',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const GovernmentJobsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _QuickCategoryCard(
                          title: l10n.quickPrivateJobs,
                          count: '3,850+ Openings',
                          icon: Icons.business_center_rounded,
                          accentColor: const Color(0xFF2563EB),
                          isSelected: jobsProv.selectedHomeCategory == 'private',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PrivateJobsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _QuickCategoryCard(
                          title: l10n.quickInternships,
                          count: '640+ Roles',
                          icon: Icons.school_rounded,
                          accentColor: const Color(0xFF0D9488),
                          isSelected: jobsProv.selectedHomeCategory == 'internship',
                          onTap: () {
                            jobsProv.setSelectedHomeCategory(
                              jobsProv.selectedHomeCategory == 'internship' ? 'all' : 'internship',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // 4. Section 1: Latest Jobs
              _SectionHeaderSliver(
                title: l10n.sectionLatestJobs,
                onSeeAll: () {
                  flow.setTabIndex(1);
                },
              ),
              _JobListSliver(jobs: latestList),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 5. Section 2: Recommended For You
              _SectionHeaderSliver(
                title: l10n.sectionRecommended,
                badgeText: 'High Match',
                badgeColor: const Color(0xFF059669),
                onSeeAll: () {
                  flow.setTabIndex(1);
                },
              ),
              _JobListSliver(jobs: recommendedList),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 6. Section 3: Closing Soon
              _SectionHeaderSliver(
                title: l10n.sectionClosingSoon,
                badgeText: l10n.urgentClosing,
                badgeColor: const Color(0xFFE11D48),
                onSeeAll: () {
                  flow.setTabIndex(1);
                },
              ),
              _JobListSliver(jobs: closingSoonList),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 7. Section 4: Government Job Alerts
              _SectionHeaderSliver(
                title: l10n.sectionGovtAlerts,
                badgeText: 'Official',
                badgeColor: const Color(0xFFD97706),
                onSeeAll: () {
                  flow.setTabIndex(1);
                },
              ),
              _JobListSliver(jobs: govtAlertsList),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCategoryCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickCategoryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 155,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withOpacity(isDark ? 0.25 : 0.12)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: accentColor, size: 18),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeaderSliver extends StatelessWidget {
  final String title;
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback onSeeAll;

  const _SectionHeaderSliver({
    required this.title,
    this.badgeText,
    this.badgeColor,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                if (badgeText != null && badgeColor != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor!.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: badgeColor!,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  l10n.seeAll,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobListSliver extends StatelessWidget {
  final List<dynamic> jobs;

  const _JobListSliver({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final job = jobs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: JobCard(job: job),
            );
          },
          childCount: jobs.length,
        ),
      ),
    );
  }
}
