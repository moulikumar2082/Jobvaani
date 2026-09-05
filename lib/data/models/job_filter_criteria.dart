class JobFilterCriteria {
  final String? category; // 'all', 'govt', 'private', 'internship'
  final String? jobType; // 'All Job Types', 'Full Time', 'Government', 'Internship', 'Remote'
  final String? location; // 'All Locations', 'Bengaluru, Karnataka', etc.
  final double? minSalaryLpa; // e.g. 0, 3, 6, 10, 15, 25
  final String? experience; // 'Fresher', '1-3 Years', '3-5 Years', '5+ Years'
  final String? qualification; // '10th/12th Pass', 'Diploma', 'Graduate', 'Post Graduate'
  final List<String> skills;
  final String? postedDateFilter; // 'all', '24h', 'week', 'month'
  final String? deadlineFilter; // 'all', '3days', 'week', 'month'
  final String sortBy; // 'latest', 'match', 'deadline'

  const JobFilterCriteria({
    this.category,
    this.jobType,
    this.location,
    this.minSalaryLpa,
    this.experience,
    this.qualification,
    this.skills = const [],
    this.postedDateFilter,
    this.deadlineFilter,
    this.sortBy = 'latest',
  });

  bool get hasActiveFilters {
    return (category != null && category != 'all') ||
        (jobType != null && jobType != 'All Job Types') ||
        (location != null && location != 'All Locations') ||
        (minSalaryLpa != null && minSalaryLpa! > 0) ||
        (experience != null && experience!.isNotEmpty) ||
        (qualification != null && qualification!.isNotEmpty) ||
        skills.isNotEmpty ||
        (postedDateFilter != null && postedDateFilter != 'all') ||
        (deadlineFilter != null && deadlineFilter != 'all');
  }

  int get activeFilterCount {
    int count = 0;
    if (category != null && category != 'all') count++;
    if (jobType != null && jobType != 'All Job Types') count++;
    if (location != null && location != 'All Locations') count++;
    if (minSalaryLpa != null && minSalaryLpa! > 0) count++;
    if (experience != null && experience!.isNotEmpty) count++;
    if (qualification != null && qualification!.isNotEmpty) count++;
    if (skills.isNotEmpty) count += skills.length;
    if (postedDateFilter != null && postedDateFilter != 'all') count++;
    if (deadlineFilter != null && deadlineFilter != 'all') count++;
    return count;
  }

  JobFilterCriteria copyWith({
    String? category,
    String? jobType,
    String? location,
    double? minSalaryLpa,
    String? experience,
    String? qualification,
    List<String>? skills,
    String? postedDateFilter,
    String? deadlineFilter,
    String? sortBy,
    bool clearCategory = false,
    bool clearJobType = false,
    bool clearLocation = false,
    bool clearMinSalary = false,
    bool clearExperience = false,
    bool clearQualification = false,
    bool clearPostedDate = false,
    bool clearDeadline = false,
  }) {
    return JobFilterCriteria(
      category: clearCategory ? null : (category ?? this.category),
      jobType: clearJobType ? null : (jobType ?? this.jobType),
      location: clearLocation ? null : (location ?? this.location),
      minSalaryLpa: clearMinSalary ? null : (minSalaryLpa ?? this.minSalaryLpa),
      experience: clearExperience ? null : (experience ?? this.experience),
      qualification: clearQualification ? null : (qualification ?? this.qualification),
      skills: skills ?? this.skills,
      postedDateFilter: clearPostedDate ? null : (postedDateFilter ?? this.postedDateFilter),
      deadlineFilter: clearDeadline ? null : (deadlineFilter ?? this.deadlineFilter),
      sortBy: sortBy ?? this.sortBy,
    );
  }

  static const empty = JobFilterCriteria();
}
