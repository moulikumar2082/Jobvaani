const INITIAL_USER = {
  name: "Mowli Kumar",
  email: "mowlikumar@gmail.com",
  phone: "+91 98765 43210",
  education: "B.Tech in Computer Science & Engineering",
  college: "National Institute of Technology",
  gradYear: "2025",
  experience: "1-3 Years",
  minSalaryLpa: 6.0,
  skills: ["Flutter", "Dart", "Python", "Cybersecurity", "Cloud / AWS", "SQL", "Linux"],
  locations: ["Bengaluru", "Hyderabad", "Remote", "Delhi NCR"],
  categories: ["Software Development", "Cybersecurity", "Government Jobs"],
  jobTypes: ["Full Time", "Government"],
  govtCategories: ["UPSC", "SSC", "Railway", "Banking", "PSU"],
  resumeFileName: "Mowli_Kumar_Software_Engineer_CV.pdf",
  resumeUploadedAt: "2026-09-01T10:00:00Z",
  resumeSizeBytes: 1474560,
  resumeSizeFormatted: "1.4 MB",
  resumeEncrypted: true,
  resumeKmsKey: "AES-256-GCM (Google Cloud KMS)",
  notifGovtAlerts: true,
  notifJobMatches: true,
  notifDeadlines: true,
  notifRecommendations: true,
  isProfileCompleted: true,
  fcmToken: "fcm_jv_98273641209_sec_tok_prod_in"
};

const JOBS_DATA = [
  {
    id: 'job_cyber_sec_ops_05',
    title: "Cybersecurity Operations & Infrastructure Engineer",
    company: "Paytm Security Labs",
    organization: "One97 Communications Ltd",
    location: "Noida / Delhi NCR",
    salary: "₹18L - ₹28L LPA",
    minSalaryLpa: 18.0,
    jobType: "Full Time",
    category: "private",
    subCategory: "cybersecurity",
    deadline: "20 Sep 2026",
    deadlineDate: "2026-09-20",
    postedDate: "2026-09-04",
    matchPercentage: 87,
    experienceLevel: "1-3 Years",
    qualification: "Graduate",
    skills: ["Python", "SQL", "Linux", "Cybersecurity", "Networking"],
    vacancies: 6,
    isClosingSoon: false,
    isGovernmentAlert: false,
    isRecommended: true,
    description: "Safeguard high-throughput payment microservices against advanced persistent threats. Monitor SIEM telemetry, automate incident response playbooks with Python, and configure secure Linux bastions.",
    eligibility: "B.Tech/BE in CS/IT or BCA/MCA with knowledge of Linux administration, SQL queries, Python automation, and computer networking fundamentals.",
    responsibilities: [
      "Monitor SIEM alerts, correlate network telemetry, and triage security incidents in real time.",
      "Develop Python automation scripts for threat hunting, log parsing, and endpoint validation.",
      "Harden Linux servers, bastion hosts, and cloud container environments.",
      "Conduct vulnerability assessments and collaborate with DevSecOps engineering teams."
    ],
    applyUrl: "https://paytm.com/careers",
    // 5-Factor Weighted Scoring Breakdown (Step 21):
    weightedBreakdown: {
      skillScore: 0.80, // 4 of 5 skills (Python, SQL, Linux, Cybersecurity; missing Networking) = 32%
      qualScore: 1.00,  // Meets Graduate = 20%
      locScore: 0.80,   // Delhi NCR matches preferred location = 12%
      catScore: 1.00,   // Cybersecurity matches preferred category = 15%
      expScore: 0.80,   // 1-3 years fit = 8%
      // Total: 32 + 20 + 12 + 15 + 8 = 87% Match
      matchedSkills: ["Python", "SQL", "Linux", "Cybersecurity"],
      missingSkills: ["Networking"]
    }
  },
  {
    id: 'job_isro_01',
    title: "Scientist / Engineer 'SC' (Computer Science)",
    company: "ISRO",
    organization: "Department of Space, Govt. of India",
    location: "Bengaluru, Karnataka",
    salary: "₹12L - ₹16L LPA (Level 10)",
    minSalaryLpa: 12.0,
    jobType: "Government",
    category: "govt",
    subCategory: "software_dev",
    deadline: "12 Oct 2026",
    deadlineDate: "2026-10-12",
    postedDate: "2026-09-03",
    matchPercentage: 96,
    experienceLevel: "Fresher",
    qualification: "Graduate",
    skills: ["C++", "Python", "Operating Systems", "Computer Networks", "Algorithms"],
    vacancies: 68,
    isClosingSoon: false,
    isGovernmentAlert: true,
    isRecommended: true,
    description: "Contribute to India's premier space missions. Design real-time telemetry processing software, orbital simulation models, and mission control systems at URSC/ISTRAC.",
    eligibility: "B.E./B.Tech or equivalent in Computer Science with minimum 65% marks or 6.84 CGPA.",
    responsibilities: [
      "Architect mission-critical real-time telemetry pipelines and command transmission software.",
      "Implement flight software validation algorithms using C++ and hardware-in-the-loop simulators.",
      "Adhere to aerospace software engineering and statutory defense verification standards."
    ],
    applyUrl: "https://isro.gov.in/careers",
    weightedBreakdown: {
      skillScore: 0.90,
      qualScore: 1.00,
      locScore: 1.00,
      catScore: 1.00,
      expScore: 1.00,
      matchedSkills: ["Python", "Computer Networks", "Algorithms"],
      missingSkills: ["C++", "Operating Systems"]
    }
  },
  {
    id: 'job_swiggy_03',
    title: "Senior Mobile Flutter Engineer",
    company: "Swiggy",
    organization: "Swiggy India Pvt Ltd",
    location: "Bengaluru / Remote",
    salary: "₹28L - ₹42L LPA",
    minSalaryLpa: 28.0,
    jobType: "Full Time",
    category: "private",
    subCategory: "software_dev",
    deadline: "15 Oct 2026",
    deadlineDate: "2026-10-15",
    postedDate: "2026-09-02",
    matchPercentage: 95,
    experienceLevel: "3-5 Years",
    qualification: "Graduate",
    skills: ["Flutter", "Dart", "State Management", "REST APIs", "CI/CD", "Clean Architecture"],
    vacancies: 4,
    isClosingSoon: false,
    isGovernmentAlert: false,
    isRecommended: true,
    description: "Build delightful hyper-local delivery experiences serving 50M+ Indian consumers. Craft high-performance mobile UI, optimize cold-start latency, and scale state management pipelines.",
    eligibility: "B.Tech in CS/IT with 3+ years of production experience shipping Flutter applications to App Store and Google Play.",
    responsibilities: [
      "Architect modular, testable UI features using clean architecture and state management.",
      "Collaborate with product managers and UX designers to craft fluid micro-animations.",
      "Benchmark application startup time, frame rendering rates, and memory footprint."
    ],
    applyUrl: "https://careers.swiggy.com",
    weightedBreakdown: {
      skillScore: 1.00,
      qualScore: 1.00,
      locScore: 1.00,
      catScore: 1.00,
      expScore: 0.80,
      matchedSkills: ["Flutter", "Dart", "REST APIs"],
      missingSkills: ["State Management", "CI/CD"]
    }
  },
  {
    id: 'job_upsc_02',
    title: "Assistant Executive Engineer (Telecom)",
    company: "UPSC",
    organization: "Union Public Service Commission",
    location: "New Delhi / Pan India",
    salary: "₹10L - ₹14L LPA (Level 10)",
    minSalaryLpa: 10.0,
    jobType: "Government",
    category: "govt",
    subCategory: "engineering",
    deadline: "Tomorrow (06 Sep 2026)",
    deadlineDate: "2026-09-06",
    postedDate: "2026-08-20",
    matchPercentage: 88,
    experienceLevel: "Fresher",
    qualification: "Graduate",
    skills: ["Telecommunications", "Signal Processing", "Wireless Networks", "Statutory Compliance"],
    vacancies: 240,
    isClosingSoon: true,
    isGovernmentAlert: true,
    isRecommended: false,
    description: "Plan, engineer, and inspect national telecommunication infrastructure, spectrum allocation, and satellite relay networks across central ministries.",
    eligibility: "Degree in Engineering in Electronics / Telecommunication from an AICTE recognized university.",
    responsibilities: [
      "Manage central telecom infrastructure projects and departmental statutory inspections.",
      "Verify compliance with radio frequency regulations and government security frameworks."
    ],
    applyUrl: "https://upsconline.nic.in",
    weightedBreakdown: {
      skillScore: 0.70,
      qualScore: 1.00,
      locScore: 1.00,
      catScore: 1.00,
      expScore: 1.00,
      matchedSkills: ["Wireless Networks", "Statutory Compliance"],
      missingSkills: ["Telecommunications", "Signal Processing"]
    }
  },
  {
    id: 'job_flipkart_ds_05',
    title: "Lead Data Scientist (E-Commerce & Supply Chain)",
    company: "Flipkart",
    organization: "Flipkart Internet Pvt Ltd",
    location: "Bengaluru, Karnataka",
    salary: "₹26L - ₹38L LPA",
    minSalaryLpa: 26.0,
    jobType: "Full Time",
    category: "private",
    subCategory: "data_science",
    deadline: "14 Oct 2026",
    deadlineDate: "2026-10-14",
    postedDate: "2026-09-01",
    matchPercentage: 82,
    experienceLevel: "3-5 Years",
    qualification: "Post Graduate",
    skills: ["Python", "SQL", "Machine Learning", "PyTorch", "Big Data", "Distributed Computing"],
    vacancies: 3,
    isClosingSoon: false,
    isGovernmentAlert: false,
    isRecommended: false,
    description: "Build predictive recommendation engines, dynamic pricing algorithms, and delivery route optimization models handling peak festival traffic.",
    eligibility: "Master's or Ph.D in Computer Science, Statistics, or related discipline with 3+ years machine learning modeling experience.",
    responsibilities: [
      "Formulate mathematical models for warehouse routing, stock prediction, and dispatch forecasting.",
      "Deploy scalable ML models with sub-50ms inference latency."
    ],
    applyUrl: "https://flipkartcareers.com",
    weightedBreakdown: {
      skillScore: 0.70,
      qualScore: 0.80,
      locScore: 1.00,
      catScore: 0.85,
      expScore: 0.80,
      matchedSkills: ["Python", "SQL"],
      missingSkills: ["Machine Learning", "PyTorch", "Distributed Computing"]
    }
  }
];

const GOVT_JOBS_DATA = [
  {
    id: "govt_ssc_01",
    organization: "Staff Selection Commission (SSC)",
    department: "Central Secretariat Service / CBDT / CBIC",
    postName: "Assistant Section Officer / Inspector",
    vacancies: 17727,
    qualification: "Graduate",
    ageLimit: "18 to 32 Years",
    applicationFee: "₹100 (Women / SC / ST Exempted)",
    selectionProcess: "Tier-I (Computer Based), Tier-II (Objective & Typing), Document Verification",
    startDate: "24 Jun 2026",
    lastDate: "24 Jul 2026",
    jobCategory: "SSC",
    status: "Open",
    notificationUrl: "https://ssc.gov.in/notifications/cgl-2026.pdf",
    officialWebsite: "https://ssc.gov.in",
    applyUrl: "https://ssc.gov.in/apply",
    description: "SSC Combined Graduate Level (CGL) 2026 recruitment for Group B and Group C posts in ministries, departments, and organizations of the Government of India."
  },
  {
    id: "govt_railway_01",
    organization: "Railway Recruitment Board (RRB)",
    department: "Ministry of Railways, Govt. of India",
    postName: "Junior Engineer (Information Technology)",
    vacancies: 7951,
    qualification: "Diploma / B.Tech (CS/IT)",
    ageLimit: "18 to 36 Years",
    applicationFee: "₹500 (₹400 refundable on CBT-1 attendance)",
    selectionProcess: "CBT Stage-1, CBT Stage-2, Document Verification & Medical Exam",
    startDate: "15 Jul 2026",
    lastDate: "15 Aug 2026",
    jobCategory: "Railway",
    status: "Open",
    notificationUrl: "https://indianrailways.gov.in/notif/rrb-je-2026.pdf",
    officialWebsite: "https://indianrailways.gov.in",
    applyUrl: "https://rrbapply.gov.in",
    description: "Recruitment of Junior Engineers across 21 Railway Recruitment Boards. Selected candidates oversee train management systems, track monitoring sensors, and station IT infrastructure."
  },
  {
    id: "govt_banking_01",
    organization: "State Bank of India (SBI)",
    department: "Central Recruitment & Promotion Department",
    postName: "Probationary Officer (PO) & Specialist Officer",
    vacancies: 2000,
    qualification: "Any Graduate",
    ageLimit: "21 to 30 Years",
    applicationFee: "₹750 (SC/ST/PwBD Nil)",
    selectionProcess: "Prelims, Mains, Psychometric Test, Interview & Group Discussion",
    startDate: "01 Sep 2026",
    lastDate: "27 Sep 2026",
    jobCategory: "Banking",
    status: "New",
    notificationUrl: "https://sbi.co.in/careers/crpd-po-2026.pdf",
    officialWebsite: "https://sbi.co.in/careers",
    applyUrl: "https://sbi.co.in/careers/current-openings",
    description: "Recruitment of Probationary Officers across pan-India branches. Fast-track leadership training program with rapid promotion ladders into executive management."
  },
  {
    id: "govt_defence_01",
    organization: "DRDO (RAC)",
    department: "Ministry of Defence, Govt. of India",
    postName: "Scientist 'B' (Cyber & Electronics)",
    vacancies: 420,
    qualification: "B.Tech (ECE/CSE) with GATE Score",
    ageLimit: "Up to 35 Years",
    applicationFee: "₹100",
    selectionProcess: "GATE Score Shortlisting followed by Personal Interview",
    startDate: "10 Aug 2026",
    lastDate: "10 Sep 2026",
    jobCategory: "Defence",
    status: "Closing Soon",
    notificationUrl: "https://drdo.gov.in/notifications/scientist-b-2026.pdf",
    officialWebsite: "https://drdo.gov.in",
    applyUrl: "https://rac.gov.in",
    description: "Direct recruitment for Scientist 'B' positions in premier defense research laboratories developing radar systems, missile guidance software, and tactical cyber defense."
  }
];

const INITIAL_NOTIFICATIONS = [
  {
    id: 'notif_01',
    title: 'New Job Match: 98% Match',
    message: 'New Cybersecurity job matches your profile: Security Operations & Threat Hunter at Paytm.',
    type: 'newJobMatch',
    timestamp: new Date(Date.now() - 15 * 60 * 1000).toISOString(),
    relatedJobId: 'job_cyber_sec_ops_05',
    isRead: false
  },
  {
    id: 'notif_02',
    title: 'Deadline Alert: 1 Day Left',
    message: 'Your saved application closes in 1 day: UPSC Assistant Executive Engineer. Complete your submission before the portal closes.',
    type: 'deadlineReminder',
    timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
    relatedJobId: 'job_upsc_02',
    isRead: false
  },
  {
    id: 'notif_03',
    title: 'Government Job Alert',
    message: "ISRO Scientist / Engineer 'SC' (Computer Science) 68 openings published at URSC/ISTRAC. Apply online.",
    type: 'govtJobAlert',
    timestamp: new Date(Date.now() - 5 * 60 * 60 * 1000).toISOString(),
    relatedJobId: 'job_isro_01',
    isRead: true
  },
  {
    id: 'notif_04',
    title: 'Top Recommendation For You',
    message: 'Senior Mobile Flutter Engineer opening at Swiggy India (₹28L - ₹42L LPA) matches your technical profile.',
    type: 'recommendation',
    timestamp: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
    relatedJobId: 'job_swiggy_03',
    isRead: true
  },
  {
    id: 'notif_05',
    title: 'SSC CGL 2026 Notification',
    message: 'Staff Selection Commission announces 17,727 vacancies for Inspector / ASO across central ministries.',
    type: 'govtJobAlert',
    timestamp: new Date(Date.now() - 48 * 60 * 60 * 1000).toISOString(),
    relatedJobId: 'govt_ssc_01',
    isRead: true
  },
  {
    id: 'notif_06',
    title: 'Welcome to JobVaani 🎉',
    message: 'Your native language preference is set. You will receive verified government alerts, instant job matches, and deadline reminders here.',
    type: 'system',
    timestamp: new Date(Date.now() - 72 * 60 * 60 * 1000).toISOString(),
    isRead: true
  }
];

const ALL_SKILLS_LIST = [
  "Python", "Java", "C++", "SQL", "Cybersecurity", "Linux", "AWS", "React",
  "Flutter", "Networking", "Dart", "Docker", "Kubernetes", "Git", "REST APIs",
  "HTML/CSS", "JavaScript", "TypeScript", "Node.js", "MongoDB", "PostgreSQL",
  "Data Structures", "Algorithms", "Machine Learning", "System Design"
];
