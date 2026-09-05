import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/jobs_provider.dart';
import '../../../widgets/job_card.dart';
import '../../../widgets/filters/advanced_filter_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final jobsProv = Provider.of<JobsProvider>(context, listen: false);
    _searchController = TextEditingController(text: jobsProv.searchQuery);
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

    final results = jobsProv.searchResults;
    final criteria = jobsProv.filterCriteria;
    final hasFilters = criteria.hasActiveFilters;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          l10n.searchTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          // Filter Trigger Button with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () => AdvancedFilterSheet.show(context),
                icon: const Icon(Icons.tune_rounded, color: Color(0xFF1E3A8A)),
                tooltip: l10n.filterTitle,
              ),
              if (hasFilters)
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
                      '${criteria.activeFilterCount}',
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
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Field Container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                onChanged: (val) => jobsProv.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: l10n.searchJobsPlaceholder,
                  hintStyle: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF1E3A8A),
                    size: 22,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            jobsProv.setSearchQuery('');
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.tune_rounded,
                          color: hasFilters ? const Color(0xFFE11D48) : const Color(0xFF1E3A8A),
                          size: 20,
                        ),
                        onPressed: () => AdvancedFilterSheet.show(context),
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // 2. Quick Filter Category Pills
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              physics: const BouncingScrollPhysics(),
              children: [
                _QuickFilterChip(
                  label: l10n.filterAll,
                  isSelected: criteria.category == null || criteria.category == 'all',
                  onTap: () {
                    jobsProv.setFilterCriteria(criteria.copyWith(category: 'all'));
                  },
                ),
                const SizedBox(width: 8),
                _QuickFilterChip(
                  label: l10n.quickGovtJobs,
                  isSelected: criteria.category == 'govt',
                  icon: Icons.account_balance_rounded,
                  onTap: () {
                    jobsProv.setFilterCriteria(
                      criteria.copyWith(
                        category: criteria.category == 'govt' ? 'all' : 'govt',
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _QuickFilterChip(
                  label: l10n.quickPrivateJobs,
                  isSelected: criteria.category == 'private',
                  icon: Icons.business_center_rounded,
                  onTap: () {
                    jobsProv.setFilterCriteria(
                      criteria.copyWith(
                        category: criteria.category == 'private' ? 'all' : 'private',
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _QuickFilterChip(
                  label: l10n.quickInternships,
                  isSelected: criteria.category == 'internship',
                  icon: Icons.school_rounded,
                  onTap: () {
                    jobsProv.setFilterCriteria(
                      criteria.copyWith(
                        category: criteria.category == 'internship' ? 'all' : 'internship',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 3. Active Filters Indicator & Results Count Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.searchResultsCount(results.length),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    if (hasFilters) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.activeFiltersCount(criteria.activeFilterCount),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                // Sort Menu
                PopupMenuButton<String>(
                  onSelected: (sort) {
                    jobsProv.setFilterCriteria(criteria.copyWith(sortBy: sort));
                  },
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sort_rounded,
                        size: 16,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getSortLabel(criteria.sortBy, l10n),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'latest',
                      child: Text(l10n.sortLatest),
                    ),
                    PopupMenuItem(
                      value: 'match',
                      child: Text(l10n.sortMatch),
                    ),
                    PopupMenuItem(
                      value: 'deadline',
                      child: Text(l10n.sortDeadline),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 4. Results List or Empty State
          Expanded(
            child: results.isEmpty
                ? _EmptySearchResults(
                    onClearFilters: () {
                      _searchController.clear();
                      jobsProv.setSearchQuery('');
                      jobsProv.clearFilters();
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return JobCard(job: results[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String sort, AppLocalizations l10n) {
    switch (sort) {
      case 'match':
        return l10n.sortMatch;
      case 'deadline':
        return l10n.sortDeadline;
      case 'latest':
      default:
        return l10n.sortLatest;
    }
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData? icon;
  final VoidCallback onTap;

  const _QuickFilterChip({
    required this.label,
    required this.isSelected,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E3A8A)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1E3A8A)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
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
  }
}

class _EmptySearchResults extends StatelessWidget {
  final VoidCallback onClearFilters;

  const _EmptySearchResults({required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 38,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.noSearchResults,
              textAlign: TextAlign.center,
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(l10n.clearFilters),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
