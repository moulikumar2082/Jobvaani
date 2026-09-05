import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/jobs_provider.dart';
import '../../widgets/job_card.dart';

class PrivateJobsScreen extends StatefulWidget {
  final String? initialCategory;

  const PrivateJobsScreen({Key? key, this.initialCategory}) : super(key: key);

  @override
  State<PrivateJobsScreen> createState() => _PrivateJobsScreenState();
}

class _PrivateJobsScreenState extends State<PrivateJobsScreen> {
  late String _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'all';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final jobsProv = Provider.of<JobsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      _CategoryMeta(id: 'all', title: l10n.filterAll, icon: Icons.apps_rounded),
      _CategoryMeta(id: 'software_dev', title: l10n.catSoftwareDev, icon: Icons.code_rounded),
      _CategoryMeta(id: 'cybersecurity', title: l10n.catCybersecurity, icon: Icons.security_rounded),
      _CategoryMeta(id: 'data_science', title: l10n.catDataScience, icon: Icons.analytics_rounded),
      _CategoryMeta(id: 'ai_ml', title: l10n.catAiMl, icon: Icons.psychology_rounded),
      _CategoryMeta(id: 'cloud', title: l10n.catCloud, icon: Icons.cloud_rounded),
      _CategoryMeta(id: 'devops', title: l10n.catDevOps, icon: Icons.all_inclusive_rounded),
      _CategoryMeta(id: 'testing', title: l10n.catTesting, icon: Icons.bug_report_rounded),
      _CategoryMeta(id: 'sales', title: l10n.catSales, icon: Icons.trending_up_rounded),
      _CategoryMeta(id: 'marketing', title: l10n.catMarketing, icon: Icons.campaign_rounded),
      _CategoryMeta(id: 'finance', title: l10n.catFinance, icon: Icons.account_balance_wallet_rounded),
      _CategoryMeta(id: 'hr', title: l10n.catHr, icon: Icons.badge_rounded),
      _CategoryMeta(id: 'other', title: l10n.catOther, icon: Icons.work_spaces_rounded),
    ];

    final jobs = jobsProv.getPrivateJobsBySubCategory(
      _selectedCategory,
      query: _searchQuery,
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.privateJobsTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
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
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
                decoration: InputDecoration(
                  hintText: l10n.searchJobsPlaceholder,
                  hintStyle: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // 2. Horizontal Subcategories Scroller (12 Categories)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == cat.id;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedCategory = cat.id);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : (isDark ? const Color(0xFF1E293B) : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat.icon,
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Header info & count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.searchResultsCount(jobs.length),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  '3,850+ Verified Roles',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),

          // 4. Jobs List or Empty State
          Expanded(
            child: jobs.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.business_center_outlined,
                              size: 34,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noSearchResults,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.noSearchResultsSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _selectedCategory = 'all';
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: Text(l10n.reset),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 6, bottom: 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return JobCard(job: jobs[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryMeta {
  final String id;
  final String title;
  final IconData icon;

  const _CategoryMeta({
    required this.id,
    required this.title,
    required this.icon,
  });
}
