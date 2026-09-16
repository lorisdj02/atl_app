<p align="center">
  <img src="images/logo_horizontal.png" alt="ATL Logo" width="320"/>
</p>

<h1 align="center">ATL — Mobile App</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.9-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/State_Mgmt-Provider-6C63FF?style=for-the-badge" alt="Provider"/>
  <img src="https://img.shields.io/badge/HTTP-Dio-EF4444?style=for-the-badge" alt="Dio"/>
  <img src="https://img.shields.io/badge/Payments-Stripe-635BFF?style=for-the-badge&logo=stripe&logoColor=white" alt="Stripe"/>
  <img src="https://img.shields.io/badge/i18n-EN_|_IT-F59E0B?style=for-the-badge" alt="i18n"/>
  <img src="https://img.shields.io/badge/Platform-Android_|_iOS-34D399?style=for-the-badge" alt="Platform"/>
</p>

<p align="center">
  <strong>A full-featured Flutter mobile application for sports tournament management, field booking, and real-time match coordination.</strong><br/>
  Built around a robust <strong>Role-Based Access Control (RBAC)</strong> system with 5 distinct user roles, Stripe payment integration, and full i18n support.
</p>

---

> ⚙️ **Backend Architecture:** This app consumes a custom Java Spring Boot REST API. [View the backend repository here](#)

---

## 📸 Visual Showcase & Core Flows

> GIF demos are grouped by RBAC role and loaded on-demand via accordions to keep this page performant.

<details>
<summary><strong>💳 Hero Flow — End-to-End Stripe Checkout</strong></summary>
<br/>

The primary monetization flow. A Player selects a tournament, reviews fees (tournament participation, lobby booking, or private booking), and completes a full Stripe Checkout session — all handled in-app with real-time session status tracking (`pending → completed → expired → failed`).

<p align="center">
  <img src="[INSERT_LINK_TO_STRIPE_GIF_HERE]" alt="Stripe Checkout Flow" width="300"/>
</p>

</details>

---

<details>
<summary><strong>⚽ Player — Home Dashboard & Promotion System</strong></summary>
<br/>

The Player home surfaces upcoming matches, team callups, tournament standings, and the **Growth Path** — a gamified promotion ladder where players track milestones and unlock progression tiers based on performance ratings.

<p align="center">
  <img src="[INSERT_LINK_TO_PLAYER_HOME_GIF_HERE]" alt="Player Home & Promotion" width="300"/>
</p>

</details>

<details>
<summary><strong>🧑‍💼 Player — Profile & Account Management</strong></summary>
<br/>

Full profile lifecycle: avatar upload via `image_picker`, personal data editing, wallet management (personal / prize / invite balances), achievement tracking, match statistics, and review history.

<p align="center">
  <img src="[INSERT_LINK_TO_PLAYER_PROFILE_GIF_HERE]" alt="Player Profile Update" width="300"/>
</p>

</details>

---

<details>
<summary><strong>📋 Coordinator — Dashboard & Tournament Booking</strong></summary>
<br/>

Coordinators manage the full tournament lifecycle: creation (multi-step form with field selection, fee configuration, team capacity), bracket generation, match scheduling, and real-time coordination. The Growth system also applies here — coordinators level up based on average tournament ratings.

<p align="center">
  <img src="[INSERT_LINK_TO_COORDINATOR_GIF_HERE]" alt="Coordinator Dashboard" width="300"/>
</p>

</details>

<details>
<summary><strong>🏟️ Organization — Real-Time Booking Management</strong></summary>
<br/>

Organizations manage their sports facilities: field availability slots, incoming booking requests (private & lobby), and real-time booking confirmations. Dedicated bottom navigation and booking management widgets surface all pending and confirmed reservations.

<p align="center">
  <img src="[INSERT_LINK_TO_ORGANIZATION_GIF_HERE]" alt="Organization Bookings" width="300"/>
</p>

</details>

---

<details>
<summary><strong>🟨 Referee — License Management & Match Flow</strong></summary>
<br/>

Referees register sport-specific licenses, browse available matches for assignment, manage in-game events (goals, cards, substitutions via `FootballMatchEvent`), and review their assignment history. The Growth ladder tracks referee progression based on minimum rating thresholds over recent matches.

<p align="center">
  <img src="[INSERT_LINK_TO_REFEREE_GIF_HERE]" alt="Referee Match Flow" width="300"/>
</p>

</details>

---

## 🏗️ Architecture & State Management

### Directory Structure

```
lib/
├── main.dart                        # App entry point — initializes DB singleton & Provider tree
├── atl_controller.dart              # MaterialApp root — theme, localization delegates, routing
│
├── config/
│   ├── app_config.dart              # Environment config (API base URL, timeouts, debug flag)
│   └── api_json_keys.dart           # Centralized JSON key constants for API contract safety
│
├── models/                          # 39 domain models with fromJson/toJson serialization
│   ├── account.dart                 # Abstract Account + AccountRole enum (RBAC core)
│   ├── player.dart / coordinator.dart / referee.dart / organization.dart
│   ├── tournament.dart              # Full tournament lifecycle model
│   ├── checkout_session.dart        # Stripe session state machine
│   ├── football_match.dart          # Match model with live event tracking
│   ├── wallet.dart                  # Multi-balance wallet (personal, prize, invite)
│   ├── growth_step.dart             # Gamified progression tiers
│   └── ...                          # booking, team, field, review, callup, etc.
│
├── providers/
│   └── account_provider.dart        # Global ChangeNotifier — auth state, active role, team context
│
├── controllers/
│   └── sport_theme_controller.dart  # Dynamic Material 3 theming based on active sport
│
├── database/
│   ├── api_client.dart              # Dio singleton — interceptors for auth (Bearer), logging, error handling
│   ├── db_controller.dart           # DB singleton facade — 30+ repository instances
│   ├── db_read.dart                 # Centralized read operations (mock-capable)
│   ├── db_write.dart                # Centralized write operations (mock-capable)
│   └── repositories/               # 39 typed repositories extending BaseRepository<T>
│       ├── base_repository.dart     # Generic abstract — endpoint, fromJson/toJson, error handling
│       ├── account_repository.dart
│       ├── tournament_repository.dart
│       ├── football_match_repository.dart
│       └── ...
│
├── screens/                         # Feature screens organized by RBAC role
│   ├── login_screen.dart / register_screen.dart / forgot_password_screen.dart
│   ├── player/                      # Home, field booking, team creation, lobby, callups
│   ├── coordinator/                 # Home, tournament creation (multi-step)
│   ├── referee/                     # Home, available matches, license mgmt, history
│   ├── organization/                # Home — booking management dashboard
│   ├── guest/                       # Read-only browsing experience
│   ├── tournaments/                 # Tournament details, match screens, standings
│   ├── teams/                       # Team management, roster, stats
│   ├── shop/                        # Stripe checkout flow
│   ├── profile_screens/             # Wallet, stats, reviews, growth, settings
│   └── registration/               # 3-step onboarding wizard
│
├── widgets/                         # 54 reusable UI components
│   ├── abstract_bottom_bar.dart     # Role-aware bottom navigation
│   ├── tournament_card.dart         # Rich tournament preview cards
│   ├── football_match_bracket.dart  # Visual bracket rendering
│   ├── growth_timeline_item.dart    # Gamified progression UI
│   ├── booking_widget.dart          # Complex booking management
│   └── ...
│
├── utils/
│   ├── home_router.dart             # RBAC-based home screen routing (switch on AccountRole)
│   ├── navigation_helper.dart       # Role-conditioned bottom bar navigation
│   ├── atl_colors.dart              # Sport-specific color palettes
│   └── text_formatters.dart / time_of_day_parser.dart
│
└── l10n/                            # Full internationalization (EN / IT)
    ├── app_localizations.dart
    ├── app_en.dart / app_it.dart
    └── app_localizations_delegate.dart
```

### State Management — Provider + ChangeNotifier

The app uses **Provider** (`provider: ^6.1.5`) as its state management solution, following a pragmatic `ChangeNotifier`-based approach:

| Layer | Responsibility |
|---|---|
| **`AccountProvider`** | Global auth state — manages the active `Account`, current `roleId`, selected `teamId`, and `SportCategory`. All role-checks (`isPlayer`, `isCoordinator`, `isReferee`, `isOrganization`, `isGuest`) are computed getters. |
| **`SportThemeController`** | Dynamic `ChangeNotifier` that generates Material 3 `ThemeData` based on the currently selected sport, enabling sport-specific color branding at runtime. |
| **`MultiProvider`** (root) | Injected at the `main.dart` level, wrapping the entire widget tree. The `AccountProvider` serves as the single source of truth for all RBAC-gated UI decisions. |

### Backend Communication

```
Flutter App  →  Dio (Singleton)  →  BaseRepository<T>  →  REST API (Spring Boot)
                   ↓
          Bearer Token Interceptor
          Timeout Configuration (30s)
          Debug LogInterceptor
```

- **HTTP Client:** `Dio` ^5.4.0 — configured as a singleton (`ApiClient`) with interceptors for auth token injection, request/response logging, and centralized error handling.
- **Repository Pattern:** 39 typed repositories extending `BaseRepository<T>`, each defining its own endpoint, JSON serialization, and mock data fallback. The `DB` singleton provides static access to all repositories (e.g., `DB.Tournaments.getTournaments()`).
- **Mock/Production Toggle:** A single `AppConfig.isDebug` flag switches the entire data layer between mock data and live API calls — no code changes required.

---

## ✨ Key Technical Features

| Area | Feature |
|---|---|
| 🔐 **RBAC System** | 5 distinct roles (**Player**, **Coordinator**, **Referee**, **Organization**, **Guest**) with role-specific home screens, navigation bars, and feature gating |
| 💳 **Stripe Integration** | End-to-end checkout flow with session state machine (`pending → completed → expired → failed`) supporting 4 checkout types: tournament fees, lobby booking, private booking, lobby participation |
| 🏆 **Tournament Engine** | Full lifecycle — creation, team registration, bracket generation, match scheduling, live standings, and palmares |
| ⚽ **Live Match Management** | Real-time match event tracking (goals, cards, substitutions), man-of-the-match voting, live minute display, and bracket visualization |
| 📈 **Growth & Gamification** | Tiered progression system for Referees and Coordinators based on performance ratings, games officiated, and tournaments coordinated |
| 💰 **Wallet System** | Multi-balance architecture (personal, prize, invite) with withdrawal tracking and transaction history |
| 📅 **Booking Engine** | Three booking types: **Private** (single team), **Lobby** (open matchmaking with participation tracking), and **Match** (tournament-bound) — all with field/category/time-slot selection |
| 🏟️ **Field Management** | Sports field catalog with category classification, size metadata, and availability scheduling |
| 👥 **Team Management** | Team creation, join requests, roster management, callup system, and inter-team transfers (`PlaysAt` tracking) |
| 🌍 **Internationalization** | Full EN/IT localization via custom `AppLocalizationsDelegate` with 600+ translation keys |
| 🎨 **Dynamic Theming** | Sport-specific Material 3 color schemes that adapt the entire UI palette at runtime |
| 📷 **Media Upload** | Native camera/gallery integration via `image_picker` for profile avatars and team logos |
| ⭐ **Reviews & Ratings** | Post-match and post-tournament review system for referees and coordinators |
| 🤝 **Social Features** | Friend invite system with referral balance rewards, favorite tournaments, and in-app contact flow |

---

## 🗺️ Known Limitations & Future Roadmap

| Status | Improvement | Details |
|---|---|---|
| 🔜 | **Offline-First with Local Persistence** | Implement local caching using `Hive` or `sqflite` to enable offline browsing of tournament brackets, team rosters, and match history. Sync writes when connectivity is restored. |
| 🔜 | **Aggressive Image Caching** | Integrate `cached_network_image` for team logos, player avatars, and field photos. Current implementation re-fetches images on every navigation, increasing data usage and perceived latency. |
| 🔜 | **Push Notifications & Real-Time Events** | Add Firebase Cloud Messaging (FCM) for match callups, booking confirmations, and live score alerts. Complement with WebSocket channels for in-match event streaming to referees and coordinators. |

---

## 🚀 Local Setup

### Prerequisites

| Tool | Version |
|---|---|
| Flutter SDK | ≥ 3.x (Dart ≥ 3.9.2) |
| Android Studio / Xcode | Latest stable |
| Backend API | Running instance of the [Spring Boot backend](#) |

### Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/your-username/atl-app.git
cd atl-app

# 2. Install dependencies
flutter pub get

# 3. Configure the API endpoint
#    Edit lib/config/app_config.dart and set your backend URL:
#    static const String apiBaseUrl = 'http://your-api-host:8080/api/v1';

# 4. Run the app (debug mode uses mock data — no backend required)
flutter run
```

> **💡 Tip:** The app runs in **debug mode by default** (`AppConfig.isDebug = true`), which uses mock data from the repository layer. No backend instance is needed for UI exploration and development.

---

<p align="center">
  <sub>Built with ❤️ using Flutter & Dart</sub>
</p>
