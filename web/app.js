// JobVaani Interactive Web Engine
// Supporting Steps 1-25: Multilingual, AI Job Matching, 5-Factor Scoring, Deadline Alerts, FCM Push, Dark Mode

document.addEventListener('DOMContentLoaded', () => {
  // App State
  let currentLang = localStorage.getItem('jobvaani_lang') || 'en';
  let isDarkMode = localStorage.getItem('jobvaani_theme_mode') === 'dark';
  let currentTab = 'screen-home';
  let savedJobIds = new Set(JSON.parse(localStorage.getItem('jobvaani_saved_jobs') || '["job_cyber_sec_ops_05", "job_upsc_02"]'));
  let activeCategory = 'all';
  let searchQuery = '';
  let notifications = [...INITIAL_NOTIFICATIONS];
  let currentUser = { ...INITIAL_USER };

  // DOM Elements Cache
  const viewport = document.getElementById('app-viewport');
  const screens = document.querySelectorAll('.screen');
  const navItems = document.querySelectorAll('.nav-item');
  const statusTime = document.getElementById('status-time');
  const themeIcon = document.getElementById('theme-icon');
  const themeToggleCheck = document.getElementById('theme-toggle-check');
  const currentThemeLabel = document.getElementById('current-theme-label');
  const currentLanguageLabel = document.getElementById('current-language-label');
  const headerUnreadCount = document.getElementById('header-unread-count');
  const navUnreadBadge = document.getElementById('nav-unread-badge');

  // Initialize Clock
  function updateClock() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    if (statusTime) statusTime.textContent = `${hours}:${minutes}`;
  }
  setInterval(updateClock, 10000);
  updateClock();

  // Translation Helper
  function t(key, fallback = '') {
    if (window.APP_TRANSLATIONS && window.APP_TRANSLATIONS[currentLang] && window.APP_TRANSLATIONS[currentLang][key]) {
      return window.APP_TRANSLATIONS[currentLang][key];
    }
    if (window.APP_TRANSLATIONS && window.APP_TRANSLATIONS['en'] && window.APP_TRANSLATIONS['en'][key]) {
      return window.APP_TRANSLATIONS['en'][key];
    }
    return fallback || key;
  }

  // Theme Management
  function applyTheme(dark) {
    isDarkMode = dark;
    if (dark) {
      document.body.classList.add('dark-mode');
      if (themeIcon) themeIcon.textContent = 'light_mode';
      if (themeToggleCheck) themeToggleCheck.textContent = 'toggle_on';
      if (currentThemeLabel) currentThemeLabel.textContent = t('activeDarkContrast', 'Active (Material 3 Dark)');
      localStorage.setItem('jobvaani_theme_mode', 'dark');
    } else {
      document.body.classList.remove('dark-mode');
      if (themeIcon) themeIcon.textContent = 'dark_mode';
      if (themeToggleCheck) themeToggleCheck.textContent = 'toggle_off';
      if (currentThemeLabel) currentThemeLabel.textContent = t('activeLightContrast', 'Standard Light');
      localStorage.setItem('jobvaani_theme_mode', 'light');
    }
  }

  // Language Management
  function applyLanguage(lang) {
    currentLang = lang;
    localStorage.setItem('jobvaani_lang', lang);

    // Update active lang card in modal
    document.querySelectorAll('.lang-card').forEach(card => {
      card.classList.toggle('active', card.getAttribute('data-lang') === lang);
    });

    const langNames = {
      en: 'English (English)',
      te: 'తెలుగు (Telugu)',
      hi: 'हिन्दी (Hindi)',
      pa: 'ਪੰਜਾਬੀ (Punjabi)'
    };
    if (currentLanguageLabel) {
      currentLanguageLabel.textContent = langNames[lang] || 'English';
    }

    // Apply translations across UI elements
    updateStaticTranslations();
    renderHeroAIJob();
    renderHomeJobs();
    renderSearchResults();
    renderSavedJobs();
    renderNotifications();
  }

  function updateStaticTranslations() {
    // Header
    const homeGreeting = document.getElementById('home-greeting');
    if (homeGreeting) {
      const greetingMap = {
        en: `Namaste, ${currentUser.name.split(' ')[0]} 👋`,
        te: `నమస్కారం, ${currentUser.name.split(' ')[0]} 👋`,
        hi: `नमस्ते, ${currentUser.name.split(' ')[0]} 👋`,
        pa: `ਸਤਿ ਸ੍ਰੀ ਅਕਾਲ, ${currentUser.name.split(' ')[0]} 👋`
      };
      homeGreeting.textContent = greetingMap[currentLang] || `Namaste, ${currentUser.name.split(' ')[0]} 👋`;
    }

    const homeSub = document.getElementById('home-subheading');
    if (homeSub) homeSub.textContent = t('appTagline', 'Every Opportunity, In Your Language');

    // Nav Labels
    const navHome = document.getElementById('nav-lbl-home');
    if (navHome) navHome.textContent = t('navHome', 'Home');
    const navSearch = document.getElementById('nav-lbl-search');
    if (navSearch) navSearch.textContent = t('navSearch', 'Search');
    const navSaved = document.getElementById('nav-lbl-saved');
    if (navSaved) navSaved.textContent = t('navSaved', 'Saved');
    const navNotif = document.getElementById('nav-lbl-notif');
    if (navNotif) navNotif.textContent = t('navNotifications', 'Alerts');
    const navProfile = document.getElementById('nav-lbl-profile');
    if (navProfile) navProfile.textContent = t('navProfile', 'Profile');

    // Chips
    const chipAll = document.getElementById('chip-all');
    if (chipAll) chipAll.textContent = t('filterAll', 'All Jobs');
    const chipAi = document.getElementById('chip-ai-match');
    if (chipAi) chipAi.textContent = t('aiRecommended', 'AI Recommended');
    const chipGovt = document.getElementById('chip-govt');
    if (chipGovt) chipGovt.textContent = t('governmentCategory', 'Government');
    const chipCyber = document.getElementById('chip-cyber');
    if (chipCyber) chipCyber.textContent = t('cybersecurityCategory', 'Cybersecurity');
    const chipSoft = document.getElementById('chip-software');
    if (chipSoft) chipSoft.textContent = t('softwareDevCategory', 'Software');

    // Section Titles
    const secAi = document.getElementById('sec-ai-recommended');
    if (secAi) secAi.textContent = t('topAiMatchTitle', '✨ Top AI Match For You');
    const secOpp = document.getElementById('sec-opportunities');
    if (secOpp) secOpp.textContent = t('exploreOpportunities', 'Explore Opportunities');

    // Search Page
    const searchTitle = document.getElementById('search-title');
    if (searchTitle) searchTitle.textContent = t('searchTitle', 'Search & Filter');
    const searchSub = document.getElementById('search-sub');
    if (searchSub) searchSub.textContent = t('searchSubtitle', 'Find verified corporate & government postings');

    // Saved Page
    const savedTitle = document.getElementById('saved-title');
    if (savedTitle) savedTitle.textContent = t('savedJobs', 'Saved Applications');
    const savedSub = document.getElementById('saved-sub');
    if (savedSub) savedSub.textContent = t('savedJobsSubtitle', 'Track active deadlines and exam dates');

    // Notifications Page
    const notifTitle = document.getElementById('notif-title');
    if (notifTitle) notifTitle.textContent = t('notifications', 'Notifications Hub');

    // Profile & Settings
    const profTitle = document.getElementById('profile-title');
    if (profTitle) profTitle.textContent = t('profileAndSettings', 'Profile & Settings');
    const secVault = document.getElementById('sec-resume-vault');
    if (secVault) secVault.textContent = t('secureResumeVault', '📄 Secure Resume Vault');
    const secSettings = document.getElementById('sec-app-settings');
    if (secSettings) secSettings.textContent = t('settingsTitle', 'App Settings');

    const setLang = document.getElementById('set-lang-title');
    if (setLang) setLang.textContent = t('settingsLanguage', 'App Language');
    const setTheme = document.getElementById('set-theme-title');
    if (setTheme) setTheme.textContent = t('settingsDarkMode', 'Dark Mode');
    const setPush = document.getElementById('set-notif-title');
    if (setPush) setPush.textContent = t('settingsNotifications', 'Push Notifications');
    const setPref = document.getElementById('set-pref-title');
    if (setPref) setPref.textContent = t('settingsJobPreferences', 'Job & Career Preferences');
    const setPriv = document.getElementById('set-privacy-title');
    if (setPriv) setPriv.textContent = t('settingsPrivacy', 'Privacy & Security');
    const setAbout = document.getElementById('set-about-title');
    if (setAbout) setAbout.textContent = t('settingsAbout', 'About JobVaani');
    const setLogout = document.getElementById('set-logout-title');
    if (setLogout) setLogout.textContent = t('settingsLogout', 'Log Out');
  }

  // Tab Navigation
  function switchTab(targetId) {
    currentTab = targetId;
    screens.forEach(screen => {
      screen.classList.toggle('active', screen.id === targetId);
    });
    navItems.forEach(item => {
      item.classList.toggle('active', item.getAttribute('data-target') === targetId);
    });
    if (viewport) viewport.scrollTop = 0;
  }

  // Render Step 20 & 21 Top AI Match Hero Card
  function renderHeroAIJob() {
    const container = document.getElementById('home-ai-hero-card');
    if (!container) return;

    // We use Paytm Cybersecurity Ops (id: job_cyber_sec_ops_05) as the primary 87% Match role
    const job = JOBS_DATA.find(j => j.id === 'job_cyber_sec_ops_05') || JOBS_DATA[0];
    const isSaved = savedJobIds.has(job.id);

    container.innerHTML = `
      <div class="ai-match-banner">
        <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:12px;">
          <div style="display:flex; gap:12px; align-items:center;">
            <div class="match-circle">
              <span>87%</span>
            </div>
            <div class="match-heading">
              <div style="display:flex; align-items:center; gap:6px;">
                <h4>${job.title}</h4>
              </div>
              <p style="font-size:12.5px; color:var(--text-secondary); font-weight:600; margin-top:2px;">
                ${job.company} • ${job.location}
              </p>
              <div class="match-grade-badge">
                <span class="material-symbols-rounded" style="font-size:14px;">verified</span>
                ${t('highMatchBadge', 'High Match Recommendation')}
              </div>
            </div>
          </div>
          <button class="save-btn ${isSaved ? 'saved' : ''}" data-job-id="${job.id}" title="Bookmark Job">
            <span class="material-symbols-rounded">${isSaved ? 'bookmark' : 'bookmark_border'}</span>
          </button>
        </div>

        <!-- Matched vs Missing Skills (Step 20) -->
        <div class="skills-container">
          <div class="skills-label">
            <span class="material-symbols-rounded" style="color:var(--success-green); font-size:16px;">check_circle</span>
            <span>${t('matchedSkillsTitle', 'Matched Skills')} (4):</span>
          </div>
          <div class="skill-chips-row">
            <span class="skill-chip matched">✓ Python</span>
            <span class="skill-chip matched">✓ SQL</span>
            <span class="skill-chip matched">✓ Linux</span>
            <span class="skill-chip matched">✓ Cybersecurity</span>
          </div>

          <div class="skills-label" style="margin-top:10px;">
            <span class="material-symbols-rounded" style="color:var(--sarkari-amber); font-size:16px;">warning</span>
            <span>${t('missingSkillsTitle', 'Missing Skills')} (1):</span>
          </div>
          <div class="skill-chips-row">
            <span class="skill-chip missing">
              Networking
              <span class="upskill-tag">${t('upskillBadge', 'Upskill')}</span>
            </span>
          </div>
        </div>

        <!-- 5-Factor Weighted Scoring Breakdown (Step 21) -->
        <div class="weighted-factors-box">
          <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
            <span style="font-size:12px; font-weight:800; color:var(--text-primary); display:flex; align-items:center; gap:6px;">
              <span class="material-symbols-rounded" style="font-size:16px; color:var(--primary-light);">analytics</span>
              ${t('weightedBreakdownTitle', '5-Factor Weighted Recommendation')}
            </span>
            <span style="font-size:11px; font-weight:800; color:var(--success-green);">Score: 87.0%</span>
          </div>

          <!-- Factor 1: Skill Match 40% -->
          <div class="factor-row">
            <div class="factor-header">
              <span>${t('factorSkill', 'Skill Match')} (40%)</span>
              <span>32.0 / 40.0 pts</span>
            </div>
            <div class="factor-progress-bar">
              <div class="factor-fill" style="width: 80%; background: #10b981;"></div>
            </div>
          </div>

          <!-- Factor 2: Qualification 20% -->
          <div class="factor-row">
            <div class="factor-header">
              <span>${t('factorQualification', 'Qualification')} (20%)</span>
              <span>20.0 / 20.0 pts</span>
            </div>
            <div class="factor-progress-bar">
              <div class="factor-fill" style="width: 100%; background: #3b82f6;"></div>
            </div>
          </div>

          <!-- Factor 3: Location 15% -->
          <div class="factor-row">
            <div class="factor-header">
              <span>${t('factorLocation', 'Location')} (15%)</span>
              <span>15.0 / 15.0 pts</span>
            </div>
            <div class="factor-progress-bar">
              <div class="factor-fill" style="width: 100%; background: #6366f1;"></div>
            </div>
          </div>

          <!-- Factor 4: Category 15% -->
          <div class="factor-row">
            <div class="factor-header">
              <span>${t('factorCategory', 'Category')} (15%)</span>
              <span>15.0 / 15.0 pts</span>
            </div>
            <div class="factor-progress-bar">
              <div class="factor-fill" style="width: 100%; background: #f59e0b;"></div>
            </div>
          </div>

          <!-- Factor 5: Experience 10% -->
          <div class="factor-row" style="margin-bottom:0;">
            <div class="factor-header">
              <span>${t('factorExperience', 'Experience')} (10%)</span>
              <span>5.0 / 10.0 pts</span>
            </div>
            <div class="factor-progress-bar">
              <div class="factor-fill" style="width: 50%; background: #0d9488;"></div>
            </div>
          </div>
        </div>

        <!-- Mandatory Statutory Disclaimer (Step 21) -->
        <div class="disclaimer-banner">
          <span class="material-symbols-rounded" style="font-size:16px; color:var(--text-muted); flex-shrink:0;">info</span>
          <span>${t('recommendationDisclaimer', 'Recommendation score is an algorithmic prediction based on your profile and resume data. It is not an employment guarantee or selection assurance.')}</span>
        </div>

        <div style="display:flex; gap:10px; margin-top:14px;">
          <button class="btn-outlined" style="padding:10px; font-size:12.5px; flex:1;" onclick="openJobDetails('${job.id}')">
            ${t('viewDetailsBtn', 'View Details')}
          </button>
          <button class="btn-primary" style="padding:10px; font-size:12.5px; flex:1;" onclick="window.open('${job.applyUrl}', '_blank')">
            <span class="material-symbols-rounded" style="font-size:16px;">launch</span>
            ${t('applyNowBtn', 'Apply Now')}
          </button>
        </div>
      </div>
    `;

    // Bind Bookmark button
    const heroBookmark = container.querySelector('.save-btn');
    if (heroBookmark) {
      heroBookmark.addEventListener('click', (e) => {
        e.stopPropagation();
        toggleSaveJob(job.id);
      });
    }
  }

  // Render Opportunities Feed
  function renderHomeJobs() {
    const container = document.getElementById('home-jobs-list');
    if (!container) return;

    let filtered = JOBS_DATA.filter(job => {
      if (activeCategory === 'all') return true;
      if (activeCategory === 'recommended') return job.isRecommended || job.matchPercentage >= 80;
      if (activeCategory === 'government') return job.category === 'government';
      if (activeCategory === 'cybersecurity') return job.subCategory === 'cybersecurity' || job.skills.includes('Cybersecurity');
      if (activeCategory === 'software') return job.subCategory === 'software' || job.skills.includes('Python') || job.skills.includes('Flutter');
      return true;
    });

    const countLabel = document.getElementById('home-jobs-count');
    if (countLabel) countLabel.textContent = `${filtered.length} positions`;

    container.innerHTML = filtered.map(job => createJobCardHtml(job)).join('');
    attachJobCardEvents(container);
  }

  // Create Job Card HTML
  function createJobCardHtml(job) {
    const isSaved = savedJobIds.has(job.id);
    const isGovt = job.category === 'government';
    const logoChar = isGovt ? '🏛️' : (job.company ? job.company[0] : '💼');
    const deadlineColor = job.isClosingSoon ? 'deadline-urgency' : '';

    return `
      <div class="job-card" data-job-id="${job.id}">
        <div class="job-header">
          <div class="company-logo ${isGovt ? 'govt' : ''}">
            <span>${logoChar}</span>
          </div>
          <div class="job-info">
            <h4 class="job-title">${job.title}</h4>
            <div class="company-name">
              <span>${job.company || job.organization}</span>
              ${isGovt ? '<span class="material-symbols-rounded" style="font-size:14px; color:var(--sarkari-amber);">verified</span>' : ''}
            </div>
          </div>
          <button class="save-btn ${isSaved ? 'saved' : ''}" data-save-id="${job.id}" title="Save Opportunity">
            <span class="material-symbols-rounded">${isSaved ? 'bookmark' : 'bookmark_border'}</span>
          </button>
        </div>

        <div class="job-meta-row">
          <span class="meta-pill">📍 ${job.location}</span>
          <span class="meta-pill salary">💰 ${job.salary || 'Govt Scale'}</span>
          <span class="meta-pill ${deadlineColor}">⏰ ${job.deadline}</span>
          ${job.matchPercentage ? `<span class="meta-pill match-score">✨ ${job.matchPercentage}% Match</span>` : ''}
        </div>

        <div style="display:flex; justify-content:space-between; align-items:center; margin-top:8px; border-top:1px solid var(--border-subtle); padding-top:8px;">
          <span style="font-size:11.5px; color:var(--text-muted);">
            ${isGovt ? `Vacancies: ${job.vacancies}` : `Experience: ${job.experienceLevel}`}
          </span>
          <span style="font-size:12px; font-weight:700; color:var(--primary-light); display:flex; align-items:center; gap:2px;">
            ${t('viewDetails', 'Details')} <span class="material-symbols-rounded" style="font-size:14px;">arrow_forward</span>
          </span>
        </div>
      </div>
    `;
  }

  function attachJobCardEvents(container) {
    // Open details on card click
    container.querySelectorAll('.job-card').forEach(card => {
      card.addEventListener('click', (e) => {
        if (e.target.closest('.save-btn')) return;
        const jobId = card.getAttribute('data-job-id');
        openJobDetails(jobId);
      });
    });

    // Save bookmark toggle
    container.querySelectorAll('.save-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const jobId = btn.getAttribute('data-save-id');
        toggleSaveJob(jobId);
      });
    });
  }

  // Toggle Save Job
  function toggleSaveJob(jobId) {
    if (savedJobIds.has(jobId)) {
      savedJobIds.delete(jobId);
      showToast('Removed from Saved Opportunities');
    } else {
      savedJobIds.add(jobId);
      showToast('Saved! Automated deadline alerts active.');
    }
    localStorage.setItem('jobvaani_saved_jobs', JSON.stringify([...savedJobIds]));
    renderHeroAIJob();
    renderHomeJobs();
    renderSearchResults();
    renderSavedJobs();
  }

  // Render Saved Applications Screen
  function renderSavedJobs() {
    const container = document.getElementById('saved-jobs-list');
    if (!container) return;

    const savedJobs = JOBS_DATA.filter(j => savedJobIds.has(j.id));
    if (savedJobs.length === 0) {
      container.innerHTML = `
        <div style="text-align:center; padding:40px 20px; color:var(--text-muted);">
          <span class="material-symbols-rounded" style="font-size:48px; margin-bottom:8px; opacity:0.6;">bookmark_border</span>
          <h4 style="font-size:15px; font-weight:800; color:var(--text-primary);">${t('noSavedJobsTitle', 'No Saved Jobs Yet')}</h4>
          <p style="font-size:12px; margin-top:4px;">Tap the bookmark icon on any position to track deadlines & exam alerts here.</p>
        </div>
      `;
      return;
    }

    container.innerHTML = savedJobs.map(job => {
      const isClosingSoon = job.isClosingSoon;
      return `
        <div class="job-card" data-job-id="${job.id}">
          <div style="display:flex; justify-content:space-between; align-items:flex-start;">
            <div>
              <span style="font-size:10.5px; font-weight:800; color:${isClosingSoon ? 'var(--urgency-red)' : 'var(--success-green)'}; text-transform:uppercase;">
                ${isClosingSoon ? '🚨 Deadline Approaching (1-3 Days)' : '✅ Application Window Open'}
              </span>
              <h4 class="job-title" style="margin-top:2px;">${job.title}</h4>
              <p style="font-size:12px; color:var(--text-secondary); margin-top:2px;">${job.company || job.organization} • ${job.location}</p>
            </div>
            <button class="save-btn saved" data-save-id="${job.id}" title="Remove Bookmark">
              <span class="material-symbols-rounded">bookmark</span>
            </button>
          </div>
          <div class="job-meta-row" style="margin:10px 0;">
            <span class="meta-pill ${isClosingSoon ? 'deadline-urgency' : ''}">⏰ Deadline: ${job.deadline}</span>
            <span class="meta-pill salary">💰 ${job.salary || 'Govt Scale'}</span>
          </div>
          <div style="display:flex; gap:8px;">
            <button class="btn-outlined" style="padding:8px 12px; font-size:12px; flex:1;" onclick="openJobDetails('${job.id}')">
              ${t('viewDetails', 'Details')}
            </button>
            <button class="btn-primary" style="padding:8px 12px; font-size:12px; flex:1;" onclick="window.open('${job.applyUrl}', '_blank')">
              <span class="material-symbols-rounded" style="font-size:14px;">launch</span> ${t('applyNow', 'Apply Now')}
            </button>
          </div>
        </div>
      `;
    }).join('');

    attachJobCardEvents(container);
  }

  // Render Search Results
  function renderSearchResults() {
    const container = document.getElementById('search-results-list');
    if (!container) return;

    const sectorFilter = document.getElementById('filter-type-select')?.value || 'all';
    const locFilter = document.getElementById('filter-location-select')?.value || 'all';
    const expFilter = document.getElementById('filter-exp-select')?.value || 'all';

    let results = JOBS_DATA.filter(job => {
      const q = searchQuery.toLowerCase().trim();
      const matchesQuery = !q ||
        job.title.toLowerCase().includes(q) ||
        (job.company && job.company.toLowerCase().includes(q)) ||
        (job.organization && job.organization.toLowerCase().includes(q)) ||
        job.location.toLowerCase().includes(q) ||
        job.skills.some(s => s.toLowerCase().includes(q));

      const matchesSector = sectorFilter === 'all' || job.category === sectorFilter;
      const matchesLoc = locFilter === 'all' || job.location.includes(locFilter);
      const matchesExp = expFilter === 'all' || job.experienceLevel === expFilter;

      return matchesQuery && matchesSector && matchesLoc && matchesExp;
    });

    const label = document.getElementById('search-results-label');
    if (label) label.textContent = `${results.length} positions matched`;

    if (results.length === 0) {
      container.innerHTML = `
        <div style="text-align:center; padding:40px 20px; color:var(--text-muted);">
          <span class="material-symbols-rounded" style="font-size:48px; margin-bottom:8px; opacity:0.6;">manage_search</span>
          <h4 style="font-size:15px; font-weight:800; color:var(--text-primary);">${t('noSearchResults', 'No Positions Found')}</h4>
          <p style="font-size:12px; margin-top:4px;">Try loosening filters or searching for "Python", "Government", or "UPSC".</p>
        </div>
      `;
      return;
    }

    container.innerHTML = results.map(job => createJobCardHtml(job)).join('');
    attachJobCardEvents(container);
  }

  // Open Job Details Modal (Steps 20, 21, 22)
  window.openJobDetails = function(jobId) {
    const job = JOBS_DATA.find(j => j.id === jobId);
    if (!job) return;

    const modal = document.getElementById('modal-job-details');
    const content = document.getElementById('modal-job-content');
    const title = document.getElementById('detail-company-title');

    if (title) title.textContent = job.company || job.organization;

    const isSaved = savedJobIds.has(job.id);
    const isGovt = job.category === 'government';
    const matchScore = job.matchPercentage || (isGovt ? 82 : 78);

    content.innerHTML = `
      <div style="margin-bottom:16px;">
        <span style="font-size:11px; font-weight:800; color:var(--primary-light); text-transform:uppercase;">
          ${job.jobType} • ${isGovt ? 'Government of India' : 'Corporate'}
        </span>
        <h3 style="font-size:18px; font-weight:900; color:var(--text-primary); margin-top:4px;">${job.title}</h3>
        <p style="font-size:13px; color:var(--text-secondary); margin-top:3px;">
          📍 ${job.location} • 💰 ${job.salary || 'Official Govt Scale'}
        </p>
      </div>

      <!-- Match Score & AI Insights (Steps 20 & 21) -->
      <div class="ai-match-banner" style="margin-bottom:18px;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
          <div style="display:flex; align-items:center; gap:10px;">
            <div class="match-circle" style="width:48px; height:48px; font-size:16px;">
              ${matchScore}%
            </div>
            <div>
              <h5 style="font-size:14px; font-weight:800; color:var(--text-primary);">${t('aiRecommendationScore', 'AI Profile Match Score')}</h5>
              <span style="font-size:11px; color:var(--success-green); font-weight:700;">● ${matchScore >= 80 ? 'High Compatibility' : 'Moderate Compatibility'}</span>
            </div>
          </div>
          <span class="material-symbols-rounded" style="color:var(--primary-light); font-size:24px;">psychology</span>
        </div>

        <!-- Skills Breakdown -->
        <div class="skills-label" style="font-size:12px; margin-top:8px;">
          <span>${t('requiredSkills', 'Required Qualifications & Skills')}:</span>
        </div>
        <div class="skill-chips-row">
          ${job.skills.map(s => {
            const hasSkill = currentUser.skills.some(userSkill => userSkill.toLowerCase() === s.toLowerCase());
            return hasSkill
              ? `<span class="skill-chip matched">✓ ${s}</span>`
              : `<span class="skill-chip missing">${s} <span class="upskill-tag">Learn</span></span>`;
          }).join('')}
        </div>

        <!-- 5-Factor Weighted Score Model (Step 21) -->
        <div class="weighted-factors-box" style="margin-top:12px;">
          <div style="font-size:11.5px; font-weight:800; color:var(--text-primary); margin-bottom:6px;">
            ${t('weightedScoringModel', 'Weighted Scoring Model (100% Total)')}
          </div>
          <div class="factor-row">
            <div class="factor-header"><span>Skill Match (40%)</span><span>${(matchScore * 0.4).toFixed(1)} / 40.0</span></div>
            <div class="factor-progress-bar"><div class="factor-fill" style="width:${matchScore}%; background:#10b981;"></div></div>
          </div>
          <div class="factor-row">
            <div class="factor-header"><span>Qualification (20%)</span><span>20.0 / 20.0</span></div>
            <div class="factor-progress-bar"><div class="factor-fill" style="width:100%; background:#3b82f6;"></div></div>
          </div>
          <div class="factor-row">
            <div class="factor-header"><span>Location (15%)</span><span>15.0 / 15.0</span></div>
            <div class="factor-progress-bar"><div class="factor-fill" style="width:100%; background:#6366f1;"></div></div>
          </div>
          <div class="factor-row">
            <div class="factor-header"><span>Category (15%)</span><span>15.0 / 15.0</span></div>
            <div class="factor-progress-bar"><div class="factor-fill" style="width:100%; background:#f59e0b;"></div></div>
          </div>
          <div class="factor-row" style="margin-bottom:0;">
            <div class="factor-header"><span>Experience (10%)</span><span>8.0 / 10.0</span></div>
            <div class="factor-progress-bar"><div class="factor-fill" style="width:80%; background:#0d9488;"></div></div>
          </div>
        </div>

        <!-- Statutory Non-Guarantee Disclaimer (Step 21 Requirement) -->
        <div class="disclaimer-banner">
          <span class="material-symbols-rounded" style="font-size:15px; color:var(--text-muted); flex-shrink:0;">info</span>
          <span>${t('recommendationDisclaimer', 'Recommendation score is an algorithmic prediction based on your profile and resume data. It is not an employment guarantee or selection assurance.')}</span>
        </div>
      </div>

      <!-- Description & Eligibility -->
      <div style="margin-bottom:16px;">
        <h4 style="font-size:14px; font-weight:800; color:var(--text-primary); margin-bottom:6px;">
          ${t('jobDescription', 'Job Overview')}
        </h4>
        <p style="font-size:12.5px; line-height:1.6; color:var(--text-secondary);">
          ${job.description}
        </p>
      </div>

      <div style="margin-bottom:16px;">
        <h4 style="font-size:14px; font-weight:800; color:var(--text-primary); margin-bottom:6px;">
          ${t('eligibilityCriteria', 'Eligibility & Educational Criteria')}
        </h4>
        <p style="font-size:12.5px; line-height:1.6; color:var(--text-secondary);">
          ${job.eligibility}
        </p>
      </div>

      ${job.responsibilities ? `
        <div style="margin-bottom:18px;">
          <h4 style="font-size:14px; font-weight:800; color:var(--text-primary); margin-bottom:6px;">
            ${t('keyResponsibilities', 'Key Responsibilities')}
          </h4>
          <ul style="padding-left:18px; font-size:12.5px; line-height:1.6; color:var(--text-secondary);">
            ${job.responsibilities.map(r => `<li>${r}</li>`).join('')}
          </ul>
        </div>
      ` : ''}

      <!-- Action Buttons -->
      <div style="display:flex; gap:10px; margin-top:20px; border-top:1px solid var(--border-color); padding-top:16px;">
        <button class="btn-outlined" style="flex:1;" onclick="toggleSaveJob('${job.id}'); closeModals();">
          <span class="material-symbols-rounded" style="font-size:18px;">${isSaved ? 'bookmark_remove' : 'bookmark_add'}</span>
          ${isSaved ? 'Remove Saved' : 'Save Application'}
        </button>
        <button class="btn-primary" style="flex:1.4;" onclick="window.open('${job.applyUrl}', '_blank')">
          <span class="material-symbols-rounded" style="font-size:18px;">launch</span>
          ${t('applyOnlinePortal', 'Apply on Official Portal')}
        </button>
      </div>
    `;

    openModal('modal-job-details');
  };

  // Render Notifications Screen (Step 23 FCM Integration)
  function renderNotifications(filter = 'all') {
    const container = document.getElementById('notifications-list');
    if (!container) return;

    let filtered = notifications;
    if (filter === 'match') filtered = notifications.filter(n => n.type === 'newJobMatch' || n.type === 'recommendation');
    if (filter === 'government') filtered = notifications.filter(n => n.type === 'govtJobAlert');
    if (filter === 'deadline') filtered = notifications.filter(n => n.type === 'deadlineReminder');
    if (filter === 'system') filtered = notifications.filter(n => n.type === 'system');

    // Update unread badges
    const unreadCount = notifications.filter(n => !n.isRead).length;
    if (headerUnreadCount) {
      headerUnreadCount.textContent = unreadCount;
      headerUnreadCount.style.display = unreadCount > 0 ? 'flex' : 'none';
    }
    if (navUnreadBadge) {
      navUnreadBadge.textContent = unreadCount;
      navUnreadBadge.style.display = unreadCount > 0 ? 'flex' : 'none';
    }

    const countAll = document.getElementById('notif-count-all');
    if (countAll) countAll.textContent = notifications.length;

    if (filtered.length === 0) {
      container.innerHTML = `
        <div style="text-align:center; padding:40px 20px; color:var(--text-muted);">
          <span class="material-symbols-rounded" style="font-size:48px; margin-bottom:8px; opacity:0.6;">notifications_off</span>
          <h4 style="font-size:15px; font-weight:800; color:var(--text-primary);">${t('noNotificationsTitle', 'No Notifications')}</h4>
          <p style="font-size:12px; margin-top:4px;">Use the FCM Simulator above to test real-time push alerts!</p>
        </div>
      `;
      return;
    }

    container.innerHTML = filtered.map(notif => {
      const typeIcons = {
        newJobMatch: { icon: 'auto_awesome', color: 'var(--success-green)', bg: 'rgba(5,150,105,0.1)' },
        recommendation: { icon: 'psychology', color: 'var(--primary-light)', bg: 'rgba(59,130,246,0.1)' },
        govtJobAlert: { icon: 'account_balance', color: 'var(--sarkari-amber)', bg: 'rgba(217,119,6,0.1)' },
        deadlineReminder: { icon: 'alarm', color: 'var(--urgency-red)', bg: 'rgba(225,29,72,0.1)' },
        system: { icon: 'info', color: 'var(--indigo-accent)', bg: 'rgba(99,102,241,0.1)' }
      };
      const meta = typeIcons[notif.type] || typeIcons.system;
      const timeStr = formatRelativeTime(notif.timestamp);

      return `
        <div class="notification-card ${notif.isRead ? '' : 'unread'}" data-notif-id="${notif.id}">
          <div style="width:40px; height:40px; border-radius:10px; background:${meta.bg}; color:${meta.color}; display:flex; align-items:center; justify-content:center; flex-shrink:0;">
            <span class="material-symbols-rounded" style="font-size:20px;">${meta.icon}</span>
          </div>
          <div style="flex:1;">
            <div style="display:flex; justify-content:space-between; align-items:center;">
              <h5 style="font-size:13.5px; font-weight:800; color:var(--text-primary);">${notif.title}</h5>
              <span style="font-size:10.5px; color:var(--text-muted);">${timeStr}</span>
            </div>
            <p style="font-size:12px; color:var(--text-secondary); margin-top:3px; line-height:1.45;">${notif.message}</p>
            ${notif.relatedJobId ? `
              <div style="margin-top:8px;">
                <button class="btn-outlined" style="padding:4px 10px; font-size:11px; width:auto;" onclick="openJobDetails('${notif.relatedJobId}')">
                  View Job Details →
                </button>
              </div>
            ` : ''}
          </div>
          ${!notif.isRead ? '<div class="badge-dot" style="margin-top:6px;"></div>' : ''}
        </div>
      `;
    }).join('');

    // Mark as read on click
    container.querySelectorAll('.notification-card').forEach(card => {
      card.addEventListener('click', (e) => {
        if (e.target.tagName === 'BUTTON') return;
        const id = card.getAttribute('data-notif-id');
        const notif = notifications.find(n => n.id === id);
        if (notif && !notif.isRead) {
          notif.isRead = true;
          renderNotifications(filter);
        }
      });
    });
  }

  // Relative Time Formatter
  function formatRelativeTime(isoString) {
    const diffMs = Date.now() - new Date(isoString).getTime();
    const mins = Math.floor(diffMs / 60000);
    if (mins < 1) return 'Just now';
    if (mins < 60) return `${mins}m ago`;
    const hours = Math.floor(mins / 60);
    if (hours < 24) return `${hours}h ago`;
    return `${Math.floor(hours / 24)}d ago`;
  }

  // Simulate Firebase Cloud Messaging (FCM) Push (Step 23)
  window.simulateFCM = function(type) {
    const templates = {
      match: {
        title: '🎯 FCM Push: New 92% Match Found',
        message: 'Google Security Operations (Bengaluru) matches 4 of your core skills: Python, Linux, SQL, Cloud.',
        type: 'newJobMatch',
        relatedJobId: 'job_cyber_sec_ops_05'
      },
      govt: {
        title: '🏛️ FCM Push: UPSC CDS II Exam Alert',
        message: 'Union Public Service Commission published Combined Defence Services II 459 Posts. Deadline in 14 days.',
        type: 'govtJobAlert',
        relatedJobId: 'job_upsc_02'
      },
      deadline: {
        title: '⏰ FCM Push: Application Closes in 24h',
        message: 'Your saved application for UPSC Civil Services closes tomorrow at 18:00 IST. Complete registration now.',
        type: 'deadlineReminder',
        relatedJobId: 'job_upsc_cse_2026'
      },
      system: {
        title: '⚙️ FCM Push: Security Token Re-authenticated',
        message: 'Your Google Cloud KMS encryption keys for resume storage were rotated successfully.',
        type: 'system'
      }
    };

    const payload = templates[type] || templates.system;
    const newNotif = {
      id: `fcm_push_${Date.now()}`,
      title: payload.title,
      message: payload.message,
      type: payload.type,
      timestamp: new Date().toISOString(),
      relatedJobId: payload.relatedJobId,
      isRead: false
    };

    notifications.unshift(newNotif);
    renderNotifications();

    // Trigger visual floating push alert toast
    showPushBanner(payload.title, payload.message, payload.relatedJobId);
  };

  function showPushBanner(title, message, jobId) {
    const banner = document.createElement('div');
    banner.style.cssText = `
      position: absolute;
      top: 50px;
      left: 16px;
      right: 16px;
      background: rgba(15, 23, 42, 0.95);
      backdrop-filter: blur(8px);
      border: 1.5px solid var(--primary-light);
      border-radius: 16px;
      padding: 12px 14px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.5);
      z-index: 200;
      color: #fff;
      animation: slideDown 0.3s cubic-bezier(0.16, 1, 0.3, 1);
      display: flex;
      gap: 10px;
      align-items: center;
      cursor: pointer;
    `;

    banner.innerHTML = `
      <div style="width:36px; height:36px; border-radius:10px; background:var(--primary); display:flex; align-items:center; justify-content:center; font-size:18px;">
        🔔
      </div>
      <div style="flex:1;">
        <div style="display:flex; justify-content:space-between; align-items:center;">
          <h5 style="font-size:12.5px; font-weight:800;">${title}</h5>
          <span style="font-size:10px; color:#94a3b8;">FCM Push</span>
        </div>
        <p style="font-size:11px; color:#cbd5e1; margin-top:2px;">${message}</p>
      </div>
    `;

    banner.addEventListener('click', () => {
      banner.remove();
      if (jobId) openJobDetails(jobId);
      else switchTab('screen-notifications');
    });

    viewport.appendChild(banner);
    setTimeout(() => {
      if (banner.parentNode) {
        banner.style.animation = 'fadeOut 0.3s forwards';
        setTimeout(() => banner.remove(), 300);
      }
    }, 5500);
  }

  // Toast Notification
  function showToast(msg) {
    const toast = document.createElement('div');
    toast.style.cssText = `
      position: absolute;
      bottom: 84px;
      left: 20px;
      right: 20px;
      background: rgba(15, 23, 42, 0.92);
      color: #fff;
      padding: 10px 16px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 700;
      text-align: center;
      z-index: 150;
      box-shadow: 0 4px 14px rgba(0,0,0,0.4);
      animation: fadeIn 0.2s ease;
    `;
    toast.textContent = msg;
    viewport.appendChild(toast);
    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transition = 'opacity 0.25s ease';
      setTimeout(() => toast.remove(), 250);
    }, 2400);
  }

  // Modal Sheet Controls
  window.openModal = function(id) {
    const modal = document.getElementById(id);
    if (modal) modal.classList.add('open');
  };

  window.closeModals = function() {
    document.querySelectorAll('.modal-overlay').forEach(m => m.classList.remove('open'));
  };

  window.savePushSettings = function() {
    currentUser.notifJobMatches = document.getElementById('chk-notif-matches')?.checked ?? true;
    currentUser.notifGovtAlerts = document.getElementById('chk-notif-govt')?.checked ?? true;
    currentUser.notifDeadlines = document.getElementById('chk-notif-deadlines')?.checked ?? true;
    currentUser.notifRecommendations = document.getElementById('chk-notif-system')?.checked ?? true;
    closeModals();
    showToast('FCM Notification preferences saved securely to backend!');
  };

  // Event Listeners Registration
  // 1. Navigation Items
  navItems.forEach(item => {
    item.addEventListener('click', () => {
      const target = item.getAttribute('data-target');
      switchTab(target);
    });
  });

  // 2. Header Buttons
  document.getElementById('btn-open-lang')?.addEventListener('click', () => openModal('modal-language'));
  document.getElementById('btn-toggle-theme')?.addEventListener('click', () => applyTheme(!isDarkMode));
  document.getElementById('btn-header-notif')?.addEventListener('click', () => switchTab('screen-notifications'));

  // 3. Category Horizontal Chips
  document.querySelectorAll('#home-category-chips .chip').forEach(chip => {
    chip.addEventListener('click', () => {
      document.querySelectorAll('#home-category-chips .chip').forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      activeCategory = chip.getAttribute('data-category');
      renderHomeJobs();
    });
  });

  // 4. Search Page Inputs
  const homeSearchTrigger = document.getElementById('home-search-trigger');
  homeSearchTrigger?.addEventListener('click', () => switchTab('screen-search'));

  const searchInput = document.getElementById('search-input');
  const btnClearSearch = document.getElementById('btn-clear-search');
  searchInput?.addEventListener('input', (e) => {
    searchQuery = e.target.value;
    if (btnClearSearch) btnClearSearch.style.display = searchQuery ? 'flex' : 'none';
    renderSearchResults();
  });

  btnClearSearch?.addEventListener('click', () => {
    if (searchInput) searchInput.value = '';
    searchQuery = '';
    btnClearSearch.style.display = 'none';
    renderSearchResults();
  });

  document.getElementById('filter-type-select')?.addEventListener('change', renderSearchResults);
  document.getElementById('filter-location-select')?.addEventListener('change', renderSearchResults);
  document.getElementById('filter-exp-select')?.addEventListener('change', renderSearchResults);

  // 5. Language Modal Cards
  document.querySelectorAll('.lang-card').forEach(card => {
    card.addEventListener('click', () => {
      const lang = card.getAttribute('data-lang');
      applyLanguage(lang);
      showToast(`Language switched to ${card.querySelector('.lang-native').textContent}`);
    });
  });

  // 6. Settings Items
  document.getElementById('item-settings-language')?.addEventListener('click', () => openModal('modal-language'));
  document.getElementById('item-settings-darkmode')?.addEventListener('click', () => applyTheme(!isDarkMode));
  document.getElementById('item-settings-push')?.addEventListener('click', () => openModal('modal-push-settings'));
  document.getElementById('btn-open-push-settings')?.addEventListener('click', () => openModal('modal-push-settings'));
  document.getElementById('item-settings-about')?.addEventListener('click', () => openModal('modal-about'));
  document.getElementById('item-settings-privacy')?.addEventListener('click', () => openModal('modal-resume-view'));
  document.getElementById('btn-resume-info')?.addEventListener('click', () => openModal('modal-resume-view'));
  document.getElementById('btn-view-resume-modal')?.addEventListener('click', () => openModal('modal-resume-view'));

  document.getElementById('btn-replace-resume')?.addEventListener('click', () => {
    showToast('Select replacement PDF (AES-256 Cloud KMS encrypted)');
  });
  document.getElementById('btn-delete-resume')?.addEventListener('click', () => {
    if (confirm('Are you sure you want to delete your encrypted resume?')) {
      showToast('Resume removed securely.');
    }
  });

  document.getElementById('item-settings-logout')?.addEventListener('click', () => {
    if (confirm('Are you sure you want to log out of JobVaani?')) {
      showToast('Logged out securely.');
    }
  });

  // 7. Notification Category Filters
  document.querySelectorAll('#notif-category-chips .chip').forEach(chip => {
    chip.addEventListener('click', () => {
      document.querySelectorAll('#notif-category-chips .chip').forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      const filter = chip.getAttribute('data-filter');
      renderNotifications(filter);
    });
  });

  // 8. FCM Simulator Buttons
  document.getElementById('btn-sim-match')?.addEventListener('click', () => simulateFCM('match'));
  document.getElementById('btn-sim-govt')?.addEventListener('click', () => simulateFCM('govt'));
  document.getElementById('btn-sim-deadline')?.addEventListener('click', () => simulateFCM('deadline'));
  document.getElementById('btn-sim-system')?.addEventListener('click', () => simulateFCM('system'));

  // 9. Close Modal on Overlay Click
  document.querySelectorAll('.modal-overlay').forEach(overlay => {
    overlay.addEventListener('click', (e) => {
      if (e.target === overlay) closeModals();
    });
  });

  // Initial Boot
  applyTheme(isDarkMode);
  applyLanguage(currentLang);
  switchTab('screen-home');
});
