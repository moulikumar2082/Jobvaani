import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/job_filter_criteria.dart';
import '../../providers/jobs_provider.dart';
import 'filter_chip_group.dart';

class AdvancedFilterSheet extends StatefulWidget {
  const AdvancedFilterSheet({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AdvancedFilterSheet(),
    );
  }

  @override
  State<AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<AdvancedFilterSheet> {
  late String _selectedCategory;
  late String _selectedJobType;
  late String _selectedLocation;
  late double _selectedMinSalary;
  late String _selectedExperience;
  late String _selectedQualification;
  late List<String> _selectedSkills;
  late String _selectedPostedDate;
  late String _selectedDeadline;

  @override
  void initState() {
    super.initState();
    final criteria = Provider.of<JobsProvider>(context, listen: false).filterCriteria;
    _selectedCategory = criteria.category ?? 'all';
    _selectedJobType = criteria.jobType ?? 'All Job Types';
    _selectedLocation = criteria.location ?? 'All Locations';
    _selectedMinSalary = criteria.minSalaryLpa ?? 0.0;
    _selectedExperience = criteria.experience ?? '';
    _selectedQualification = criteria.qualification ?? '';
    _selectedSkills = List.from(criteria.skills);
    _selectedPostedDate = criteria.postedDateFilter ?? 'all';
    _selectedDeadline = criteria.deadlineFilter ?? 'all';
  }

  void _clearAll() {
    setState(() {
      _selectedCategory = 'all';
      _selectedJobType = 'All Job Types';
      _selectedLocation = 'All Locations';
      _selectedMinSalary = 0.0;
      _selectedExperience = '';
      _selectedQualification = '';
      _selectedSkills.clear();
      _selectedPostedDate = 'all';
      _selectedDeadline = 'all';
    });
  }

  void _applyFilters() {
    final criteria = JobFilterCriteria(
      category: _selectedCategory,
      jobType: _selectedJobType == 'All Job Types' ? null : _selectedJobType,
      location: _selectedLocation == 'All Locations' ? null : _selectedLocation,
      minSalaryLpa: _selectedMinSalary > 0 ? _selectedMinSalary : null,
      experience: _selectedExperience.isEmpty ? null : _selectedExperience,
      qualification: _selectedQualification.isEmpty ? null : _selectedQualification,
      skills: _selectedSkills,
      postedDateFilter: _selectedPostedDate,
      deadlineFilter: _selectedDeadline,
    );

    Provider.of<JobsProvider>(context, listen: false).setFilterCriteria(criteria);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = ['all', 'govt', 'private', 'internship'];
    final categoryLabels = {
      'all': l10n.filterAll,
      'govt': l10n.quickGovtJobs,
      'private': l10n.quickPrivateJobs,
      'internship': l10n.quickInternships,
    };

    final jobTypes = ['All Job Types', 'Full Time', 'Government', 'Internship', 'Contract'];
    final locations = [
      'All Locations',
      'Bengaluru',
      'New Delhi',
      'Hyderabad',
      'Mumbai',
      'Chennai',
      'Remote',
    ];

    final experienceOptions = [
      l10n.fresherExperience,
      l10n.midExperience,
      l10n.seniorExperience,
      l10n.leadExperience,
    ];

    final qualificationOptions = [
      '10th/12th Pass',
      'Diploma',
      'Graduate',
      'Post Graduate',
    ];

    final skillOptions = [
      'Flutter',
      'Python',
      'Java',
      'C++',
      'SQL',
      'Algorithms',
      'AWS',
      'Telecom',
      'Quantitative Aptitude',
      'Reasoning',
    ];

    final postedDateOptions = ['all', '24h', 'week', 'month'];
    final postedDateLabels = {
      'all': l10n.anyTime,
      '24h': l10n.past24Hours,
      'week': l10n.pastWeek,
      'month': l10n.pastMonth,
    };

    final deadlineOptions = ['all', '3days', 'week', 'month'];
    final deadlineLabels = {
      'all': l10n.anyTime,
      '3days': l10n.closingIn3Days,
      'week': l10n.closingThisWeek,
      'month': l10n.closingThisMonth,
    };

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle & Header
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 12),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.filterTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _clearAll,
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFFE11D48)),
                      label: Text(
                        l10n.clearFilters,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable filter groups
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Category
                  FilterChipGroup(
                    title: l10n.filterCategory,
                    options: categories.map((c) => categoryLabels[c] ?? c).toList(),
                    selectedOptions: [categoryLabels[_selectedCategory] ?? _selectedCategory],
                    onSelected: (label) {
                      final key = categoryLabels.entries.firstWhere((e) => e.value == label).key;
                      setState(() => _selectedCategory = key);
                    },
                  ),
                  const SizedBox(height: 22),

                  // 2. Job Type
                  FilterChipGroup(
                    title: l10n.filterJobType,
                    options: jobTypes,
                    selectedOptions: [_selectedJobType],
                    onSelected: (type) => setState(() => _selectedJobType = type),
                  ),
                  const SizedBox(height: 22),

                  // 3. Location
                  FilterChipGroup(
                    title: l10n.filterLocation,
                    options: locations,
                    selectedOptions: [_selectedLocation],
                    onSelected: (loc) => setState(() => _selectedLocation = loc),
                  ),
                  const SizedBox(height: 22),

                  // 4. Salary Range Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.filterSalary,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            _selectedMinSalary == 0.0
                                ? l10n.filterAll
                                : '₹${_selectedMinSalary.toStringAsFixed(0)}L+ LPA',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _selectedMinSalary,
                        min: 0.0,
                        max: 30.0,
                        divisions: 6,
                        activeColor: const Color(0xFF1E3A8A),
                        inactiveColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        label: _selectedMinSalary == 0.0
                            ? 'All'
                            : '₹${_selectedMinSalary.toStringAsFixed(0)}L+',
                        onChanged: (val) => setState(() => _selectedMinSalary = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 5. Experience Level
                  FilterChipGroup(
                    title: l10n.filterExperience,
                    options: experienceOptions,
                    selectedOptions: _selectedExperience.isNotEmpty ? [_selectedExperience] : [],
                    onSelected: (exp) {
                      setState(() {
                        _selectedExperience = _selectedExperience == exp ? '' : exp;
                      });
                    },
                  ),
                  const SizedBox(height: 22),

                  // 6. Qualification
                  FilterChipGroup(
                    title: l10n.filterQualification,
                    options: qualificationOptions,
                    selectedOptions: _selectedQualification.isNotEmpty ? [_selectedQualification] : [],
                    onSelected: (q) {
                      setState(() {
                        _selectedQualification = _selectedQualification == q ? '' : q;
                      });
                    },
                  ),
                  const SizedBox(height: 22),

                  // 7. Skills (Multi-Select)
                  FilterChipGroup(
                    title: l10n.filterSkills,
                    options: skillOptions,
                    selectedOptions: _selectedSkills,
                    isMultiSelect: true,
                    onSelected: (skill) {
                      setState(() {
                        if (_selectedSkills.contains(skill)) {
                          _selectedSkills.remove(skill);
                        } else {
                          _selectedSkills.add(skill);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 22),

                  // 8. Posted Date
                  FilterChipGroup(
                    title: l10n.filterPostedDate,
                    options: postedDateOptions.map((p) => postedDateLabels[p] ?? p).toList(),
                    selectedOptions: [postedDateLabels[_selectedPostedDate] ?? _selectedPostedDate],
                    onSelected: (label) {
                      final key = postedDateLabels.entries.firstWhere((e) => e.value == label).key;
                      setState(() => _selectedPostedDate = key);
                    },
                  ),
                  const SizedBox(height: 22),

                  // 9. Deadline
                  FilterChipGroup(
                    title: l10n.filterDeadline,
                    options: deadlineOptions.map((d) => deadlineLabels[d] ?? d).toList(),
                    selectedOptions: [deadlineLabels[_selectedDeadline] ?? _selectedDeadline],
                    onSelected: (label) {
                      final key = deadlineLabels.entries.firstWhere((e) => e.value == label).key;
                      setState(() => _selectedDeadline = key);
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  l10n.applyFilters,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
