import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/jobs_provider.dart';
import '../../widgets/govt_job_card.dart';

class GovernmentJobsScreen extends StatefulWidget {
  final String? initialCategory;

  const GovernmentJobsScreen({Key? key, this.initialCategory}) : super(key: key);

  @override
  State<GovernmentJobsScreen> createState() => _GovernmentJobsScreenState();
}

class _GovernmentJobsScreenState extends State<GovernmentJobsScreen> {
  late String _selectedCategory;
  String _selectedStatus = 'all'; // 'all', 'newAlert', 'open', 'closingSoon', 'expired'
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
      _GovtCategoryMeta(id: 'all', title: l10n.filterAll, icon: Icons.apps_rounded),
      _GovtCategoryMeta(id: 'ssc', title: l10n.catSsc, icon: Icons.assignment_turned_in_rounded),
      _GovtCategoryMeta(id: 'upsc', title: l10n.catUpsc, icon: Icons.account_balance_rounded),
      _GovtCategoryMeta(id: 'railway', title: l10n.catRailway, icon: Icons.train_rounded),
      _GovtCategoryMeta(id: 'banking', title: l10n.catBanking, icon: Icons.account_balance_wallet_rounded),
      _GovtCategoryMeta(id: 'defence', title: l10n.catDefence, icon: Icons.shield_rounded),
      _GovtCategoryMeta(id: 'police', title: l10n.catPolice, icon: Icons.local_police_rounded),
      _GovtCategoryMeta(id: 'teaching', title: l10n.catTeaching, icon: Icons.school_rounded),
      _GovtCategoryMeta(id: 'psu', title: l10n.catPsu, icon: Icons.factory_rounded),
      _GovtCategoryMeta(id: 'state_govt', title: l10n.catStateGovt, icon: Icons.location_city_rounded),
      _GovtCategoryMeta(id: 'other', title: l10n.catOther, icon: Icons.work_spaces_rounded),
    ];

    final statuses = [
      _StatusMeta(id: 'all', title: l10n.filterAll, color: const Color(0xFFD97706)),
      _StatusMeta(id: 'newAlert', title: l10n.statusNew, color: const Color(0xFF059669)),
      _StatusMeta(id: 'open', title: l10n.statusOpen, color: const Color(0xFF2563EB)),
      _StatusMeta(id: 'closingSoon', title: l10n.statusClosingSoon, color: const Color(0xFFE11D48)),
      _StatusMeta(id: 'expired', title: l10n.statusExpired, color: const Color(0xFF64748B)),
    ];

    final jobs = jobsProv.getGovtJobsFiltered(
      category: _selectedCategory,
      status: _selectedStatus,
      query: _searchQuery,
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.govtJobsTitle,
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
                  hintText: '${l10n.searchPlaceholder}...',
                  hintStyle: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFFD97706),
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

          // 2. Status Segment Filter (All, New, Open, Closing Soon, Expired)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: statuses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final st = statuses[index];
                  final isSelected = _selectedStatus == st.id;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedStatus = st.id);
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? st.color
                            : (isDark ? const Color(0xFF1E293B) : Colors.white),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? st.color
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        ),
                      ),
                      child: Text(
                        st.title,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Category Horizontal Pills (All, SSC, UPSC, Railway, Banking, Defence, Police, Teaching, PSU, State Govt, Other)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: SizedBox(
              height: 38,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFD97706)
                            : (isDark ? const Color(0xFF1E293B) : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFD97706)
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
                          const SizedBox(width: 5),
                          Text(
                            cat.title,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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

          // 4. Results Count Header
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
                  '1,420+ Verified Vacancies',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),

          // 5. Jobs List or Empty State
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
                              Icons.account_balance_outlined,
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
                                _selectedStatus = 'all';
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: Text(l10n.reset),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD97706),
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
                      return GovtJobCard(job: jobs[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _GovtCategoryMeta {
  final String id;
  final String title;
  final IconData icon;

  const _GovtCategoryMeta({
    required this.id,
    required this.title,
    required this.icon,
  });
}

class _StatusMeta {
  final String id;
  final String title;
  final Color color;

  const _StatusMeta({
    required this.id,
    required this.title,
    required this.color,
  });
}
