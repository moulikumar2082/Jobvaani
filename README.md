# JobVaani (జాబ్‌వాణి)
> **“Every Opportunity, In Your Language.”**

[![Flutter](https://img.shields.io/badge/Flutter-v3.24-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.5-0175C2?logo=dart)](https://dart.dev)
[![Material 3](https://img.shields.io/badge/Design-Material%203-7C3AED)](https://m3.material.io)
[![Languages](https://img.shields.io/badge/Languages-4%20(EN%2C%20TE%2C%20HI%2C%20PA)-10B981)](#-multilingual-parity)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**JobVaani** is an Indian multilingual smart recruitment and government opportunity discovery platform. It bridges candidates across India with verified corporate technology positions and official government recruitment notices in **English**, **Telugu (తెలుగు)**, **Hindi (हिन्दी)**, and **Punjabi (ਪੰਜਾਬੀ)**.

---

## 🌟 Key Architecture & Features (Steps 1–25)

### 1. 🌐 Multilingual Localization Parity (381 Keys)
* Full translation parity across **English**, **Telugu**, **Hindi**, and **Punjabi** managed via ARB files under `lib/l10n/`.
* Zero hardcoded user-facing strings across all 55 Dart files and the web frontend.
* Type-safe code generation in `AppLocalizations` supporting parameterized strings for salaries, deadlines, vacancies, and filter counts.

### 2. 🤖 AI Job Matching Architecture (Step 20)
* Decoupled multi-tier service and repository pattern:
  - `RecommendationRepository`: Clean interface for fetching AI scorecards and ranked candidate matches.
  - `JobMatchService`: High-level recommendation evaluation logic.
  - `ResumeAnalysisService`: Candidate competency and resume attribute extraction.
* Ready for drop-in integration with a Python / FastAPI NLP microservice.
* Displays **“87% Match”** with:
  - **Matched Skills**: `✓ Python`, `✓ SQL`, `✓ Linux`, `✓ Cybersecurity`
  - **Missing Skills**: `⚠️ Networking` (with an interactive *Upskill* badge).

### 3. 📊 5-Factor Weighted Recommendation Logic (Step 21)
* Transparent, explainable scoring model:
  - **Skill Match** — 40% (weight: 0.40)
  - **Qualification** — 20% (weight: 0.20)
  - **Location** — 15% (weight: 0.15)
  - **Category** — 15% (weight: 0.15)
  - **Experience** — 10% (weight: 0.10)
* Interactive visual breakdown displaying progress bars for each dimension.
* **Mandatory Statutory Disclaimer**: Explicit non-guarantee legal notice stating that scores are algorithmic predictions and do not guarantee employment.

### 4. ⏰ Deadline Alerts Engine (Step 22)
* Multi-milestone alert scheduling:
  - **7 days before deadline**
  - **3 days before deadline**
  - **1 day before deadline** (“Your saved application closes in 1 day.”)
  - **Deadline day** (“Today is the last day to submit your application!”)
* Automated validation filtering out expired jobs.

### 5. 🔔 Firebase Cloud Messaging (FCM) Push Architecture (Step 23)
* `NotificationService` and `INotificationService` abstractions.
* Granular support across 4 alert categories:
  - 🎯 *New Matching Jobs*
  - 🏛️ *Government Job Alerts* (UPSC, SSC, Railway, State PSC)
  - ⏰ *Saved-Job Deadlines*
  - ⚙️ *Important System Notifications*
* Secure device token registration via backend API (`ApiConfig.notificationTokenRegister`) with zero public exposure.

### 6. ⚙️ Settings Hub & Persistence (Step 24)
* Centralized settings screen covering:
  - Language selection (EN, TE, HI, PA)
  - FCM Notification preferences
  - Dark Mode toggle
  - Privacy & Security information
  - About JobVaani
  - Help & Support
  - Logout with confirmation
* Persistent state in `SharedPreferences` across app restarts.

### 7. 🌙 Material 3 Themes & Zero Hardcoded Colors (Step 25)
* Centralized theme system under `lib/core/theme/`:
  - `AppColors`: Brand tokens (`primary #1E3A8A`), Sarkari Amber (`#D97706`), Success Green (`#059669`), Urgency Red (`#E11D48`).
  - `AppColorsExtension`: Type-safe theme extension accessed via `context.colors`.
  - `AppTypography`: Adaptive typographic hierarchy.
  - `ThemeProvider`: Reactive state management with local persistence.

### 8. 📄 Enterprise Resume Vault & Cloud Security (Step 19)
* Full resume lifecycle: **Upload**, **View**, **Replace**, and **Delete**.
* Private Cloud Storage architecture with AES-256 Google Cloud KMS encryption.
* Cryptographic short-lived (15-minute) signed download URLs — strictly zero public URL access.

---

## 📁 Project Structure

```
Jobvaani/
├── lib/
│   ├── core/
│   │   ├── constants/       # App constants, routes, asset paths
│   │   ├── network/         # ApiConfig, endpoints, auth headers
│   │   └── theme/           # AppColors, AppTheme, AppTypography, ThemeProvider
│   ├── data/
│   │   ├── models/          # Job, User, Resume, AI Match, Push Notification models
│   │   └── repositories/    # RecommendationRepository, ResumeRepository, JobsRepository
│   ├── l10n/                # app_en.arb, app_te.arb, app_hi.arb, app_pa.arb
│   ├── providers/           # AuthProvider, JobsProvider, JobMatchProvider
│   ├── services/            # JobMatchService, ResumeAnalysisService, NotificationService
│   ├── views/
│   │   ├── auth/            # Login, Registration, Language selection
│   │   ├── jobs/            # JobDetails, PrivateJobs, GovernmentJobs
│   │   └── tabs/            # Home, Search, Saved, Notifications, Profile, Settings
│   └── widgets/             # JobCard, AiMatchCard, FilterSheet, PushSettingsSheet
├── web/                     # Live interactive web application
│   ├── index.html           # Material 3 responsive mobile viewport shell
│   ├── styles.css           # Centralized CSS design system (Dark/Light themes)
│   ├── translations.js      # 381 localized keys across EN, TE, HI, PA
│   ├── data.js              # Comprehensive verified opportunities dataset
│   └── app.js               # Reactive state engine & FCM simulator
├── l10n.yaml                # Flutter localization configuration
└── pubspec.yaml             # Flutter project dependencies
```

---

## 🚀 Running Locally

### Option A: Interactive Web Version (Hosted)
The application includes a self-contained, responsive web interface located in `web/`:

```bash
# Serve locally via Python
python3 -m http.server 8080 --directory web
```
Open [http://localhost:8080](http://localhost:8080) in your browser.

### Option B: Flutter Mobile App
```bash
# Install Flutter dependencies
flutter pub get

# Generate localizations
flutter gen-l10n

# Run on an emulator, device, or Chrome
flutter run
```

---

## 🔒 Security & Privacy
- **Resume Protection**: Candidate resumes are encrypted with Google Cloud KMS (AES-256-GCM) in private buckets.
- **Access Control**: Short-lived cryptographic signed URLs expire in 15 minutes.
- **FCM Token Privacy**: Device tokens are stored securely in backend databases.

---

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.
