<p align="center">
  <img src="images/logo_horizontal.png" alt="ATL Logo" width="320"/>
</p>

<h1 align="center">ATL — Mobile App</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.29+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.9+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/State_Mgmt-Provider-6C63FF?style=for-the-badge" alt="Provider"/>
  <img src="https://img.shields.io/badge/HTTP-Dio-EE3A43?style=for-the-badge" alt="Dio"/>
  <img src="https://img.shields.io/badge/Payments-Stripe-635BFF?style=for-the-badge&logo=stripe&logoColor=white" alt="Stripe"/>
  <img src="https://img.shields.io/badge/i18n-EN_|_IT-43A047?style=for-the-badge" alt="i18n"/>
  <img src="https://img.shields.io/badge/Platform-Android-34A853?style=for-the-badge&logo=android&logoColor=white" alt="Android"/>
</p>

<p align="center">
  <strong>A multi-role sports tournament management app with end-to-end Stripe payments, real-time booking, and a complete Role-Based Access Control system — built as a full-stack portfolio piece.</strong><br/>
  <em>From player sign-up to match-day operations, ATL digitizes the entire grassroots tournament lifecycle.</em>
</p>

---

> ⚙️ **Backend Architecture:** This app consumes a custom **Java Spring Boot REST API** with JWT authentication, Stripe webhook integration, and domain-driven service design. &nbsp;[**View the backend repository here →**](https://github.com/lorisdj02/atl-backend)

---

## 📱 Visual Showcase & Core Flows

> Each section below contains an animated demo GIF. Accordions are used to **lazy-load media on demand** and keep this page performant.

<details>
<summary><strong>💳 Hero Flow — End-to-End Stripe Checkout</strong></summary>
<br/>
<p align="center">
  <img src="[INSERT_LINK_TO_STRIPE_GIF_HERE]" alt="Stripe Checkout Flow" width="300"/>
</p>

**What you're seeing:**
- User selects a tournament participation or premium item
- App requests a `PaymentIntent` from the Spring Boot backend
- Stripe's native Payment Sheet is presented via `flutter_stripe`
- On success, the backend confirms the webhook and updates the user's wallet and purchase history in real time

</details>

---

### 🏅 Player Flows

<details>
<summary><strong>🏠 Player Home & Promotion System</strong></summary>
<br/>
<p align="center">
  <img src="[INSERT_LINK_TO_PLAYER_HOME_GIF_HERE]" alt="Player Home & Promotion" width="300"/>
</p>

**What you're seeing:**
- Dynamic home dashboard with live tournament cards, team status, and upcoming matches
- "My Growth" promotion timeline — a gamified step-by-step progression system
- Quick-access navigation to booking, tournaments, and team management

</details>

<details>
<summary><strong>✏️ Player Profile Update</strong></summary>
<br/>
<p align="center">
  <img src="[INSERT_LINK_TO_PLAYER_PROFILE_GIF_HERE]" alt="Player Profile Update" width="300"/>
</p>

**What you're seeing:**
- Full profile editor with image upload via `image_picker`
- Multi-step info editing (personal data, preferred city, sport preferences)
- Wallet overview, purchase history, reviews, and personal stats — all accessible from a single profile hub

</details>

---

### 🛡️ Coordinator & Organization Flows

<details>
<summary><strong>📋 Coordinator Dashboard & Booking</strong></summary>
<br/>
<p align="center">
  <img src="[INSERT_LINK_TO_COORDINATOR_GIF_HERE]" alt="Coordinator Dashboard" width="300"/>
</p>

**What you're seeing:**
- Coordinator-specific home screen with tournament creation and management tools
- Full tournament lifecycle: creation → field booking → match scheduling → prize assignment
- Callups management: confirm player rosters before kickoff

</details>

<details>
<summary><strong>🏢 Organization Real-time Bookings</strong></summary>
<br/>
<p align="center">
  <img src="[INSERT_LINK_TO_ORGANIZATION_GIF_HERE]" alt="Organization Bookings" width="300"/>
</p>

**What you're seeing:**
- Organization dashboard displaying facility fields and time-slot availability
- Real-time booking panel: private bookings, match bookings, and lobby bookings
- Booking status management with live state transitions (pending → confirmed → completed)

</details>

---

### ⚖️ Referee Flow

<details>
<summary><strong>🪪 Referee License & Match Assignment</strong></summary>
<br/>
<p align="center">
  <img src="[INSERT_LINK_TO_REFEREE_GIF_HERE]" alt="Referee License & Match Flow" width="300"/>
</p>

**What you're seeing:**
- Referee license creation and management by sport category
- Available matches screen — referees browse and accept open match assignments
- Past assigned matches history with match detail drill-down

</details>

---

## 🏗️ Architecture & State Management

### Directory Structure

The project follows a **feature-grouped, layered architecture** that cleanly separates UI, business logic, data access, and shared domain models:

```
lib/
├── main.dart                      # App entry point & Provider bootstrap
├── atl_controller.dart            # Root MaterialApp with i18n & theme config
│
├── config/                        # 🔧 Global configuration
│   ├── app_config.dart            #    API base URL, timeouts, debug flags
│   └── api_json_keys.dart         #    Centralized JSON key constants
│
├── providers/                     # 🧠 State Management (ChangeNotifier)
│   └── account_provider.dart      #    Global auth state, role, team, token
│
├── controllers/                   # 🎨 UI Controllers
│   └── sport_theme_controller.dart#    Dynamic theming per sport category
│
├── models/                        # 📦 Domain Models (31 models + 24 enums)
│   ├── account.dart               #    User account with role & VIP status
│   ├── tournament.dart            #    Tournament entity with full lifecycle
│   ├── booking.dart               #    Booking with status transitions
│   ├── checkout_session.dart      #    Stripe checkout session model
│   ├── enums/                     #    Rich enum types with API serialization
│   │   ├── account_role.dart      #       Player | Coordinator | Referee | Organization | Guest | Admin
│   │   ├── booking_status.dart
│   │   ├── tournament_status.dart
│   │   └── ... (24 enum files)
│   └── ... (31 model files)
│
├── database/                      # 🌐 Data Layer (API Communication)
│   ├── api_client.dart            #    Singleton Dio client with JWT interceptor
│   ├── services/                  #    Service classes per domain
│   │   ├── read/                  #       GET operations (7 read services)
│   │   └── write/                 #       POST/PUT/DELETE operations (7 write services)
│   ├── requests/                  #    Typed request DTOs
│   └── responses/                 #    Typed response DTOs (38 response models)
│
├── screens/                       # 📱 UI Layer — Role-segmented screens
│   ├── player/                    #    🏃 Player: home, booking, teams, lobbies
│   ├── coordinator/               #    📋 Coordinator: home, tournament creation
│   ├── organization/              #    🏢 Organization: facility & booking mgmt
│   ├── referee/                   #    ⚖️ Referee: licenses, matches, history
│   ├── guest/                     #    👤 Guest: limited read-only access
│   ├── tournaments/               #    🏆 Shared tournament views
│   ├── teams/                     #    👥 Shared team views
│   ├── shop/                      #    💳 Stripe checkout screen
│   ├── profile_screens/           #    ⚙️ Settings, wallet, stats, reviews
│   └── registration/              #    📝 Multi-step registration wizard
│
├── widgets/                       # 🧩 Reusable UI Components (56 widgets)
│   ├── abstract_bottom_bar.dart   #    Role-adaptive bottom navigation
│   ├── booking_widget.dart        #    Complex booking calendar widget
│   ├── tournament_card.dart       #    Rich tournament display cards
│   └── ... (56 widget files)
│
├── utils/                         # 🛠️ Utilities
│   ├── home_router.dart           #    Role → HomeScreen routing
│   ├── navigation_helper.dart     #    Bottom bar navigation logic
│   └── atl_colors.dart            #    Sport-specific color palettes
│
└── l10n/                          # 🌍 Localization (EN + IT)
    ├── app_en.dart                #    English translations
    ├── app_it.dart                #    Italian translations
    └── app_localizations.dart     #    Localization delegate & lookup
```

### State Management: Provider + ChangeNotifier

ATL uses **Provider** (`provider: ^6.1.5`) as its state management solution — a pragmatic choice for this app's complexity level:

| Concern | Implementation |
|---|---|
| **Global Auth State** | `AccountProvider` extends `ChangeNotifier` — holds the active `Account`, JWT token, selected team, sport category, and exposes role-checking getters (`isPlayer`, `isCoordinator`, `isReferee`, `isOrganization`, `isGuest`) |
| **Provider Bootstrap** | `MultiProvider` at the root of the widget tree in `main.dart` ensures auth state is accessible app-wide |
| **Token Binding** | `AccountProvider.bindApiClientToken()` injects a token provider callback into the singleton `ApiClient`, so every Dio request automatically attaches the `Bearer` header |
| **UI Theming** | `SportThemeController` dynamically switches `ColorScheme` based on the selected sport category |

### API Communication Layer

The data layer is built around a **Singleton Dio client** with centralized interceptor logic:

- 🔐 **JWT Interceptor** — Automatically attaches `Authorization: Bearer <token>` to every outbound request
- 📡 **Typed Service Layer** — Domain services are split into `read/` (GET) and `write/` (POST/PUT/DELETE) subdirectories for clear intent separation
- 📋 **Request/Response DTOs** — 5 typed request models and 38 typed response models ensure compile-time safety and clean JSON deserialization
- ⚠️ **Centralized Error Handling** — The Dio error interceptor maps HTTP status codes to semantic error labels (`AUTHENTICATION`, `NOT_FOUND`, `CONFLICT`, `VALIDATION`, `SERVER_ERROR`)

---

## ✨ Key Technical Features

| Feature | Details |
|---|---|
| 🔐 **Role-Based Access Control** | 6 distinct roles (`Player`, `Coordinator`, `Referee`, `Organization`, `Guest`, `Admin`) with role-specific home screens, navigation bars, and feature gating |
| 💳 **Stripe Payment Integration** | Full `flutter_stripe` integration — PaymentIntent creation, native Payment Sheet, and server-side webhook confirmation |
| 🏆 **Tournament Lifecycle** | End-to-end flow: creation → team registration → lobby → field booking → match scheduling → live scoring → prize assignment |
| 📅 **Smart Booking System** | Multi-type booking engine (private, match, lobby) with field-size validation, time-slot selection, and real-time status transitions |
| ⚽ **Live Match Operations** | Match event tracking (goals, cards, substitutions), live minute widget, MOTM (Man of the Match) voting, and bracket visualization |
| 👥 **Team Management** | Team creation, player callups with confirmation workflow, roster management, and team search/discovery |
| 📊 **Player Progression** | "My Growth" gamification system with milestone timeline, VIP status, personal stats tracking, and palmarès |
| 🪪 **Referee Licensing** | License creation per sport category, available match browsing, assignment acceptance, and past match history |
| 💰 **Digital Wallet** | In-app wallet with transaction history, top-up via Stripe, and purchase tracking |
| 🌍 **Full Internationalization** | Complete EN/IT localization with `flutter_localizations` and custom delegate — production-ready for multi-market launch |
| 🎨 **Dynamic Sport Theming** | `SportThemeController` swaps the entire app color scheme based on the active sport category |
| 📝 **Multi-step Registration** | 3-step registration wizard with role selection and progressive profile completion |

---

## 🚧 Known Limitations & Future Roadmap

> This is a **portfolio-grade project** demonstrating full-stack architecture and complex mobile flows. The following improvements are planned:

| Area | Current State | Planned Improvement |
|---|---|---|
| 🖼️ **Image Caching** | Team logos and profile images are fetched on every screen load | Implement aggressive image caching with `cached_network_image` and disk-level LRU eviction to eliminate redundant downloads and improve scroll performance |
| 📶 **Offline Support** | The app requires a constant network connection; no local persistence beyond `shared_preferences` for token storage | Introduce offline-first architecture using `Hive` or `sqflite` for local data caching, with a sync queue for deferred write operations when connectivity is restored |
| 🧪 **Test Coverage** | No unit or widget tests currently in place | Add comprehensive test suite: unit tests for service/model layers with `mockito`, widget tests for critical UI flows, and integration tests for end-to-end RBAC scenarios |

---

## 🚀 Local Setup

### Prerequisites

| Tool | Version |
|---|---|
| Flutter SDK | `>= 3.29` (Dart `>= 3.9.2`) |
| Android Studio / VS Code | Latest stable |
| Android Emulator or Device | API 21+ |

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/lorisdj02/atl_app.git
cd atl_app

# 2. Install dependencies
flutter pub get

# 3. Configure the backend URL
#    Edit lib/config/app_config.dart and set your API base URL:
#    - Android Emulator:  http://10.0.2.2:8081/api/v1
#    - Physical Device:   http://<YOUR_LOCAL_IP>:8081/api/v1

# 4. Configure Stripe
#    Set your Stripe publishable key in the checkout screen configuration.
#    Ensure the backend has the matching Stripe secret key.

# 5. Run the app
flutter run
```

> **Note:** The backend must be running locally for the app to function. See the [backend repository](https://github.com/lorisdj02/atl-backend) for setup instructions.

---

<p align="center">
  <sub>Built with ❤️ as a full-stack portfolio project — <strong>ATL</strong> &copy; 2025</sub>
</p>
