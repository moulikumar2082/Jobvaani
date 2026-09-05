import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _collegeController;
  late TextEditingController _customSkillController;

  late String _selectedQualification;
  late String _selectedGradYear;
  late String _selectedExperience;
  late List<String> _skills;
  late Set<String> _preferredLocations;
  late Set<String> _preferredCategories;
  late Set<String> _preferredJobTypes;
  bool _isSaving = false;

  final List<String> _qualificationOptions = [
    'Graduate (B.Tech / B.E.)',
    'Graduate (B.Sc / BCA / B.Com)',
    'Post Graduate (M.Tech / M.E.)',
    'Post Graduate (MBA / PGDM)',
    'Post Graduate (M.Sc / MCA)',
    'Diploma / Polytechnic',
    '12th Pass / Intermediate',
    '10th Pass',
    'Doctorate (Ph.D)',
    'Other Graduate',
  ];

  final List<String> _gradYearOptions = [
    '2028 or later',
    '2027',
    '2026',
    '2025',
    '2024',
    '2023',
    '2022',
    '2021',
    '2020 or earlier',
  ];

  final List<String> _experienceOptions = [
    'Fresher (0-1 yr)',
    '1-3 Years',
    '3-5 Years',
    '5-8 Years',
    '8+ Years',
  ];

  final List<String> _suggestedColleges = [
    'IIT Bombay',
    'IIT Madras',
    'NIT Trichy',
    'Osmania University',
    'JNTU Hyderabad',
    'Delhi University',
    'Anna University',
    'BITS Pilani',
  ];

  final List<String> _suggestedSkills = [
    'Flutter',
    'Dart',
    'Python',
    'Java',
    'Cybersecurity',
    'SQL',
    'Cloud / AWS',
    'DevOps',
    'Machine Learning',
    'React',
    'Data Analytics',
    'UI/UX Design',
  ];

  final List<String> _locationOptions = [
    'Bengaluru',
    'Hyderabad',
    'New Delhi',
    'Mumbai',
    'Pune',
    'Chennai',
    'Kolkata',
    'Noida',
    'Gurugram',
    'Remote',
  ];

  final List<String> _categoryOptions = [
    'Software Development',
    'Cybersecurity',
    'Data Science',
    'AI/ML',
    'Cloud & DevOps',
    'Government (Sarkari)',
    'Banking',
    'Railway',
    'Defence',
    'Police',
    'Teaching',
    'Sales & Marketing',
    'Finance',
    'HR',
  ];

  final List<String> _jobTypeOptions = [
    'Full Time',
    'Government',
    'Internship',
    'Contract',
    'Part Time',
  ];

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: auth.userName);
    _collegeController = TextEditingController(text: auth.college);
    _customSkillController = TextEditingController();

    // Ensure qualification matches an option or is added
    if (_qualificationOptions.contains(auth.education)) {
      _selectedQualification = auth.education;
    } else if (auth.education.isNotEmpty) {
      _selectedQualification = auth.education;
      _qualificationOptions.insert(0, auth.education);
    } else {
      _selectedQualification = _qualificationOptions.first;
    }

    // Ensure graduation year matches or is added
    if (_gradYearOptions.contains(auth.graduationYear)) {
      _selectedGradYear = auth.graduationYear;
    } else if (auth.graduationYear.isNotEmpty) {
      _selectedGradYear = auth.graduationYear;
      _gradYearOptions.insert(0, auth.graduationYear);
    } else {
      _selectedGradYear = '2025';
    }

    // Experience
    if (_experienceOptions.contains(auth.experience)) {
      _selectedExperience = auth.experience;
    } else if (auth.experience.isNotEmpty) {
      _selectedExperience = auth.experience;
      _experienceOptions.insert(0, auth.experience);
    } else {
      _selectedExperience = '1-3 Years';
    }

    _skills = List<String>.from(auth.skills);
    _preferredLocations = Set<String>.from(auth.preferredLocations);
    _preferredCategories = Set<String>.from(auth.jobCategories);
    _preferredJobTypes = Set<String>.from(auth.preferredJobTypes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    _customSkillController.dispose();
    super.dispose();
  }

  void _addCustomSkill() {
    final text = _customSkillController.text.trim();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() {
        _skills.add(text);
        _customSkillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_skills.contains(skill)) {
        _skills.remove(skill);
      } else {
        _skills.add(skill);
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    await auth.updateFullProfile(
      name: _nameController.text.trim(),
      qualification: _selectedQualification,
      college: _collegeController.text.trim(),
      graduationYear: _selectedGradYear,
      skills: _skills,
      experience: _selectedExperience,
      preferredLocations: _preferredLocations.toList(),
      preferredCategories: _preferredCategories.toList(),
      preferredJobTypes: _preferredJobTypes.toList(),
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
              Expanded(child: Text(l10n.profileUpdatedSuccess)),
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
          l10n.editProfile,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Basic Details Card
              _buildSectionCard(
                title: l10n.basicDetails,
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF1E3A8A),
                isDark: isDark,
                children: [
                  // Full Name
                  _buildFieldLabel(l10n.fullName, isDark),
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: _buildInputDecoration(
                      hintText: l10n.fullName,
                      icon: Icons.badge_outlined,
                      isDark: isDark,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return l10n.fullName;
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Academic & Education Details Card (Qualification, College, Graduation Year)
              _buildSectionCard(
                title: l10n.academicDetails,
                icon: Icons.school_outlined,
                iconColor: const Color(0xFF059669),
                isDark: isDark,
                children: [
                  // Qualification Dropdown
                  _buildFieldLabel(l10n.qualificationLabel, isDark),
                  DropdownButtonFormField<String>(
                    value: _selectedQualification,
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: _buildInputDecoration(
                      hintText: l10n.selectQualification,
                      icon: Icons.school_rounded,
                      isDark: isDark,
                    ),
                    items: _qualificationOptions.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt,
                        child: Text(
                          opt,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedQualification = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // College / University Text Field
                  _buildFieldLabel(l10n.college, isDark),
                  TextFormField(
                    controller: _collegeController,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: _buildInputDecoration(
                      hintText: l10n.collegeHint,
                      icon: Icons.account_balance_outlined,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // College Suggestions Chips
                  Text(
                    l10n.recommendedInstitutions,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _suggestedColleges.map((college) {
                      final isSelected = _collegeController.text.trim() == college;
                      return ActionChip(
                        avatar: Icon(
                          Icons.add_rounded,
                          size: 14,
                          color: isSelected ? Colors.white : const Color(0xFF059669),
                        ),
                        label: Text(
                          college,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                          ),
                        ),
                        backgroundColor: isSelected
                            ? const Color(0xFF059669)
                            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF059669) : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _collegeController.text = college;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Graduation Year Dropdown
                  _buildFieldLabel(l10n.graduationYear, isDark),
                  DropdownButtonFormField<String>(
                    value: _selectedGradYear,
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: _buildInputDecoration(
                      hintText: l10n.selectGraduationYear,
                      icon: Icons.calendar_today_rounded,
                      isDark: isDark,
                    ),
                    items: _gradYearOptions.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt,
                        child: Text(opt),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedGradYear = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Experience Level Card (Single Choice Chips)
              _buildSectionCard(
                title: l10n.filterExperience,
                icon: Icons.work_outline_rounded,
                iconColor: const Color(0xFFD97706),
                isDark: isDark,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _experienceOptions.map((opt) {
                      final isSelected = _selectedExperience == opt;
                      return ChoiceChip(
                        label: Text(opt),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
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
                          if (selected) {
                            setState(() => _selectedExperience = opt);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Skills & Expertise Card (Interactive Chips + Custom Add + Suggestions)
              _buildSectionCard(
                title: l10n.skillsSection,
                icon: Icons.psychology_outlined,
                iconColor: const Color(0xFF2563EB),
                isDark: isDark,
                children: [
                  // Active Skills Removable Chips
                  if (_skills.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills.map((skill) {
                        return Chip(
                          label: Text(
                            '#$skill',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.12),
                          deleteIcon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF1E3A8A)),
                          onDeleted: () => _removeSkill(skill),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Color(0xFF93C5FD)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Add Custom Skill Input Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customSkillController,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.addCustomSkillHint,
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Icon(Icons.tag_rounded, size: 18),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onSubmitted: (_) => _addCustomSkill(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addCustomSkill,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        child: Text(
                          l10n.addSkill,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Suggested Skills Chips
                  Text(
                    l10n.suggestedSkills,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _suggestedSkills.map((skill) {
                      final isSelected = _skills.contains(skill);
                      return FilterChip(
                        label: Text(skill),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                        ),
                        selectedColor: const Color(0xFF2563EB),
                        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          ),
                        ),
                        onSelected: (_) => _toggleSkill(skill),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Career & Job Preferences Card (Locations, Categories, Job Types)
              _buildSectionCard(
                title: l10n.careerPreferences,
                icon: Icons.tune_rounded,
                iconColor: const Color(0xFF0D9488),
                isDark: isDark,
                children: [
                  // Preferred Locations
                  _buildFieldLabel(l10n.preferredLocationsLabel, isDark),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _locationOptions.map((loc) {
                      final isSelected = _preferredLocations.contains(loc);
                      return FilterChip(
                        avatar: Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isSelected ? Colors.white : const Color(0xFF2563EB),
                        ),
                        label: Text(loc),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                        ),
                        selectedColor: const Color(0xFF2563EB),
                        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _preferredLocations.add(loc);
                            } else {
                              _preferredLocations.remove(loc);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Preferred Categories
                  _buildFieldLabel(l10n.preferredCategoriesLabel, isDark),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _categoryOptions.map((cat) {
                      final isSelected = _preferredCategories.contains(cat);
                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                        ),
                        selectedColor: const Color(0xFF0D9488),
                        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF0D9488)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _preferredCategories.add(cat);
                            } else {
                              _preferredCategories.remove(cat);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Preferred Job Types
                  _buildFieldLabel(l10n.preferredJobTypesLabel, isDark),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _jobTypeOptions.map((type) {
                      final isSelected = _preferredJobTypes.contains(type);
                      return FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                        ),
                        selectedColor: const Color(0xFFD97706),
                        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFD97706)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _preferredJobTypes.add(type);
                            } else {
                              _preferredJobTypes.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 6. Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_rounded, size: 20),
                  label: Text(
                    _isSaving ? l10n.saving : l10n.saveChanges,
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
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required List<Widget> children,
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    required bool isDark,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 13,
        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      ),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF1E3A8A)),
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
