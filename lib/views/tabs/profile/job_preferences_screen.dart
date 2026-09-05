import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';

class JobPreferencesScreen extends StatefulWidget {
  const JobPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<JobPreferencesScreen> createState() => _JobPreferencesScreenState();
}

class _JobPreferencesScreenState extends State<JobPreferencesScreen> {
  late Set<String> _categories;
  late Set<String> _locations;
  late Set<String> _jobTypes;
  late double _minSalaryLpa;
  late String _experienceLevel;
  late Set<String> _govtCategories;
  late bool _notifGovtAlerts;
  late bool _notifJobMatches;
  late bool _notifDeadlines;
  late bool _notifRecommendations;
  bool _isSaving = false;

  // Prominently includes requested examples:
  // Categories: Cybersecurity, Software Development, Government
  final List<String> _categoryOptions = [
    'Cybersecurity',
    'Software Development',
    'Government Jobs',
    'Data Science',
    'AI/ML',
    'Cloud & DevOps',
    'Banking & Finance',
    'Sales & Marketing',
    'HR & Operations',
    'Teaching & Education',
  ];

  // Locations: Bangalore, Hyderabad, Delhi, Pune
  final List<String> _locationOptions = [
    'Bangalore',
    'Hyderabad',
    'Delhi NCR',
    'Pune',
    'Mumbai',
    'Chennai',
    'Kolkata',
    'Noida',
    'Gurugram',
    'Remote',
    'All India',
  ];

  final List<String> _jobTypeOptions = [
    'Full Time',
    'Government',
    'Internship',
    'Contract',
    'Part Time',
    'Remote',
  ];

  final List<String> _experienceOptions = [
    'Fresher (0-1 yr)',
    '1-3 Years',
    '3-5 Years',
    '5-8 Years',
    '8+ Years',
  ];

  final List<String> _govtCategoryOptions = [
    'UPSC',
    'SSC',
    'Railway (RRB)',
    'Banking (IBPS/SBI)',
    'Defence (Army/Navy/Air Force)',
    'Police & Paramilitary',
    'Teaching (KVS/NVS)',
    'PSU (ISRO/ONGC/DRDO)',
    'State Government',
  ];

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _categories = Set<String>.from(auth.jobCategories);
    _locations = Set<String>.from(auth.preferredLocations);
    _jobTypes = Set<String>.from(auth.preferredJobTypes);
    _minSalaryLpa = auth.minSalaryLpa;
    _experienceLevel = auth.experience.isNotEmpty ? auth.experience : '1-3 Years';
    _govtCategories = Set<String>.from(auth.preferredGovtCategories);
    _notifGovtAlerts = auth.notifGovtAlerts;
    _notifJobMatches = auth.notifJobMatches;
    _notifDeadlines = auth.notifDeadlines;
    _notifRecommendations = auth.notifRecommendations;
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    await auth.updateJobPreferencesFull(
      categories: _categories.toList(),
      locations: _locations.toList(),
      jobTypes: _jobTypes.toList(),
      minSalaryLpa: _minSalaryLpa,
      experienceLevel: _experienceLevel,
      govtCategories: _govtCategories.toList(),
      notifGovtAlerts: _notifGovtAlerts,
      notifJobMatches: _notifJobMatches,
      notifDeadlines: _notifDeadlines,
      notifRecommendations: _notifRecommendations,
    );

    setState(() => _isSaving = false);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.preferencesSavedSuccess)),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        elevation: 0,
        title: Text(
          l10n.jobPreferences,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _savePreferences,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E3A8A)),
                  )
                : Text(
                    l10n.saveChanges,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withOpacity(isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD97706).withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tune_rounded, color: Color(0xFFD97706), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.jobPreferences,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.jobPreferencesSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 1. Preferred Categories
            _buildSectionCard(
              title: l10n.preferredCategoriesLabel,
              subtitle: 'Select industries & career domains',
              icon: Icons.category_outlined,
              iconColor: const Color(0xFFD97706),
              isDark: isDark,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categoryOptions.map((cat) {
                  final isSelected = _categories.contains(cat);
                  return FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                    ),
                    selectedColor: const Color(0xFFD97706),
                    backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFFD97706)
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _categories.add(cat);
                        } else {
                          _categories.remove(cat);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Preferred Locations
            _buildSectionCard(
              title: l10n.preferredLocationsLabel,
              subtitle: 'Preferred cities and remote work',
              icon: Icons.location_on_outlined,
              iconColor: const Color(0xFF2563EB),
              isDark: isDark,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _locationOptions.map((loc) {
                  final isSelected = _locations.contains(loc);
                  return FilterChip(
                    avatar: Icon(
                      Icons.place_outlined,
                      size: 15,
                      color: isSelected ? Colors.white : const Color(0xFF2563EB),
                    ),
                    label: Text(loc),
                    selected: isSelected,
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                    ),
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _locations.add(loc);
                        } else {
                          _locations.remove(loc);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Job Types
            _buildSectionCard(
              title: l10n.preferredJobTypesLabel,
              subtitle: 'Employment & contractual structure',
              icon: Icons.work_history_outlined,
              iconColor: const Color(0xFF0D9488),
              isDark: isDark,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _jobTypeOptions.map((type) {
                  final isSelected = _jobTypes.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                    ),
                    selectedColor: const Color(0xFF0D9488),
                    backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF0D9488)
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _jobTypes.add(type);
                        } else {
                          _jobTypes.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 4. Minimum Salary
            _buildSectionCard(
              title: l10n.filterSalary,
              subtitle: 'Annual base CTC expectation',
              icon: Icons.currency_rupee_rounded,
              iconColor: const Color(0xFF059669),
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _minSalaryLpa == 0
                            ? l10n.anySalary
                            : '₹${_minSalaryLpa.toStringAsFixed(0)} Lakhs / annum (₹${_minSalaryLpa.toStringAsFixed(0)}L LPA)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _minSalaryLpa == 0 ? 'Any' : 'Min ₹${_minSalaryLpa.toStringAsFixed(0)}L',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF059669),
                      inactiveTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      thumbColor: const Color(0xFF059669),
                      overlayColor: const Color(0xFF059669).withOpacity(0.2),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _minSalaryLpa,
                      min: 0,
                      max: 30,
                      divisions: 30,
                      label: _minSalaryLpa == 0 ? l10n.anySalary : '₹${_minSalaryLpa.toStringAsFixed(0)}L LPA',
                      onChanged: (val) {
                        setState(() => _minSalaryLpa = val);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹0 (Any)',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                      ),
                      Text(
                        '₹15L LPA',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                      ),
                      Text(
                        '₹30L+ LPA',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Experience Level
            _buildSectionCard(
              title: l10n.filterExperience,
              subtitle: 'Current professional experience',
              icon: Icons.timeline_rounded,
              iconColor: const Color(0xFF1E3A8A),
              isDark: isDark,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _experienceOptions.map((exp) {
                  final isSelected = _experienceLevel == exp;
                  return ChoiceChip(
                    label: Text(exp),
                    selected: isSelected,
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                    ),
                    selectedColor: const Color(0xFF1E3A8A),
                    backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF1E3A8A)
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _experienceLevel = exp);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 6. Government Job Categories
            _buildSectionCard(
              title: l10n.govtCategoriesPreference,
              subtitle: 'Civil services, defence, PSUs & public sector alerts',
              icon: Icons.account_balance_rounded,
              iconColor: const Color(0xFFB45309),
              isDark: isDark,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _govtCategoryOptions.map((gcat) {
                  final isSelected = _govtCategories.contains(gcat);
                  return FilterChip(
                    avatar: Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: isSelected ? Colors.white : const Color(0xFFB45309),
                    ),
                    label: Text(gcat),
                    selected: isSelected,
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                    ),
                    selectedColor: const Color(0xFFB45309),
                    backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFFB45309)
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _govtCategories.add(gcat);
                        } else {
                          _govtCategories.remove(gcat);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 7. Notification Preferences
            _buildSectionCard(
              title: l10n.notificationPreferences,
              subtitle: 'Alert channels and push notification preferences',
              icon: Icons.notifications_active_outlined,
              iconColor: const Color(0xFF7C3AED),
              isDark: isDark,
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: l10n.notifGovtAlertsTitle,
                    subtitle: l10n.notifGovtAlertsSubtitle,
                    icon: Icons.account_balance_outlined,
                    value: _notifGovtAlerts,
                    onChanged: (val) => setState(() => _notifGovtAlerts = val),
                    isDark: isDark,
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: l10n.notifJobMatchesTitle,
                    subtitle: l10n.notifJobMatchesSubtitle,
                    icon: Icons.work_outline_rounded,
                    value: _notifJobMatches,
                    onChanged: (val) => setState(() => _notifJobMatches = val),
                    isDark: isDark,
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: l10n.notifDeadlinesTitle,
                    subtitle: l10n.notifDeadlinesSubtitle,
                    icon: Icons.timer_outlined,
                    value: _notifDeadlines,
                    onChanged: (val) => setState(() => _notifDeadlines = val),
                    isDark: isDark,
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: l10n.notifRecommendationsTitle,
                    subtitle: l10n.notifRecommendationsSubtitle,
                    icon: Icons.auto_awesome_outlined,
                    value: _notifRecommendations,
                    onChanged: (val) => setState(() => _notifRecommendations = val),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 8. Save CTA Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _savePreferences,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_rounded, size: 20),
                label: Text(
                  _isSaving ? l10n.saving : l10n.savePreferences,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 1,
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF7C3AED)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: const Color(0xFF7C3AED),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
