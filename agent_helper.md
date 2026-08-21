# Mandi Intelligence - Long-Term Architectural Memory

This document serves as the single authoritative persistent memory and comprehensive architectural blueprint of the Mandi Intelligence project. It provides complete context for future development, ensuring subsequent agent sessions do not need to rediscover the architecture, database schema, state management, predictive engine, alert pipeline, or business logic.

---

# 1. Project Overview

- **What this project does**: Mandi Intelligence is an agricultural marketplace analysis and intelligence platform. It aggregates live agricultural commodity prices from across India, normalizes them, generates 7-day machine learning price predictions, processes actionable price alerts, and delivers them via a localized mobile app (with a desktop viewport frame wrapper).
- **Primary purpose**: To empower farmers, traders, and agricultural stakeholders with real-time commodity price data, historical trends, 7-day machine learning forecasts, best selling day recommendations, and customized crop price alerts.
- **Main user flow**:
  1. **Authentication & Recovery**: User registers or logs in via OTP (Email via Resend or SMS via Fast2SMS). Registered users can also recover passwords via a 3-phase Forgot Password OTP flow.
  2. **Onboarding & Profile Setup**: New users select their State, District, preferred UI Language (English, Hindi, Malayalam), and trackable crops (crop preferences).
  3. **Real-Time Price Tracking (Home Tab)**: Displays current daily mandi prices filtered by location and preferred crops, formatted with Variety and Grade tags.
  4. **Detailed Analysis & Market Directory (Markets Tab)**: Users can inspect 7-day historical price movement charts (`fl_chart`) or browse a paginated directory of active markets in a state/district.
  5. **Predictions & Advisory (Advisory Tab)**: Displays 7-day LightGBM price predictions in a production-grade 3-section layout (Prediction Section, AI Advisory Section with transport cost, market fee & expected profit breakdown, and Forecast Section with daily timeline). Features a "Compare Nearby Mandis" portal (`MarketComparisonScreen` placeholder) and an "Explore More Commodities" portal to search predictions across non-preferred crops.
  6. **Actionable Alerts & History (Alerts Bell Header)**: Displays real-time actionable price alerts (`PRICE_INCREASE`, `PRICE_DROP`, `BETTER_MARKET`, `AI_RECOMMENDATION`) and searchable historical alert archives.
  7. **Profile & Notification Management (Profile Tab)**: Allows editing location, language, tracked crops, and notification delivery options (In-App, SMS, Push) and frequencies (Instant vs Daily Summary).
- **Current implementation status**:
  - **Backend**: Fully functional FastAPI service deployed on Railway. Features database migration schemas, dual-source price fetcher, fuzzy-matching normalizers, LightGBM prediction engine, template-based alert localization engine, Resend mailer, Fast2SMS gateway, and RESTful APIs.
  - **Frontend**: Production-grade Flutter app with multi-language localizations (EN, HI, ML), Riverpod state management, custom Material 3 cards, desktop frame wrapper (`MobileFrameWrapper`), and dual-mode fallback repositories for offline/resilient demo operation.
- **Completed Core Modules**:
  - Authentication (OTP send/verify with transient verification tokens, login, register, me).
  - Forgot Password recovery pipeline.
  - Notification Preferences management.
  - Dual price ingestion pipeline (Agmarknet V2 Daily API + Data.gov.in V1 Fallback API).
  - Advanced fuzzy matching normalization for Markets, Commodities, and Varieties.
  - Multi-language localization (EN, HI, ML) for App UI and database-driven translations.
  - 7-day historical price timeline visualization.
  - LightGBM Machine Learning 7-day price forecasting engine.
  - Actionable & Historical Alerts System (`PRICE_INCREASE`, `PRICE_DROP`, `BETTER_MARKET`, `AI_RECOMMENDATION`).

---

# 2. Tech Stack

### Frontend
- **Framework**: Flutter (Dart ^3.5.0)
- **State Management**: `flutter_riverpod` (^2.5.1)
- **Local Storage / Session**: `flutter_secure_storage` (^9.2.2) (stores JWT Bearer token)
- **Charts**: `fl_chart` (^1.2.0) (price history & 7-day prediction trajectory)
- **Networking**: `http` (^1.2.1)
- **Localization**: `flutter_localizations` (SDK), `intl` (^0.20.2), `flutter gen-l10n`
- **Animations & UI**: `shimmer` (^3.0.0), `MobileFrameWrapper` (390x884 desktop viewport constraint)

### Backend
- **Framework**: FastAPI (Python)
- **Server**: Uvicorn
- **ORM / DB Access**: SQLAlchemy (PostgreSQL engine)
- **Machine Learning**: LightGBM, Pandas, NumPy, Scikit-learn (`app/ml/lightgbm_weights.txt`, `app/ml/model_features.json`)
- **Data Fetcher**: `httpx`, `requests`
- **Config & Validation**: Pydantic / `pydantic-settings`
- **Security & Token**: Passlib (`bcrypt`), `python-jose[cryptography]` (JWT)
- **Email Delivery**: `resend` (SDK)
- **SMS Delivery**: `Fast2SMS` API (`SMSService`)

### Database & Deployment
- **Database**: PostgreSQL (hosted on Railway)
- **Deployment**: Railway (`mandi-intelligence-app-production`)

---

# 3. Repository Structure

```
.
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   ├── routes/             # Entity & feature routers
│   │   │   │   ├── alerts.py             # Actionable & historical alerts
│   │   │   │   ├── commodities.py        # Commodities endpoints
│   │   │   │   ├── districts.py          # Districts by state
│   │   │   │   ├── mandi_prices.py       # Daily price search & pagination
│   │   │   │   ├── market_directory.py   # Market directory index
│   │   │   │   ├── markets.py            # Markets by district
│   │   │   │   ├── predictions.py        # ML price predictions (Forecasts)
│   │   │   │   ├── price_history.py      # 7-day historical prices
│   │   │   │   └── states.py             # Active states
│   │   │   ├── auth.py                   # OTP, Register, Login, Forgot Password
│   │   │   ├── crop_preferences.py       # User tracked crops
│   │   │   ├── notification_preferences.py # Notification settings
│   │   │   └── profile.py                # Profile retrieval & updates
│   │   ├── core/                         # Config, Database, Dependencies, Security
│   │   ├── ml/                           # LightGBM weights & model feature JSON
│   │   │   ├── lightgbm_weights.txt
│   │   │   └── model_features.json
│   │   ├── models/                       # 22 SQLAlchemy DB models
│   │   ├── repositories/                 # SQL queries (mandi prices, predictions, alerts)
│   │   ├── schemas/                      # Pydantic schemas (alerts, predictions, auth, etc.)
│   │   ├── services/                     # Business logic & processors
│   │   │   ├── alert_processors/         # Price shift & AI alert processors
│   │   │   ├── alert_generation_service.py # Alert generator dispatcher
│   │   │   ├── alert_localization.py     # Template-based alert translation
│   │   │   ├── alert_service.py          # Alert persistence & mapping
│   │   │   ├── auth_service.py           # Verification & user creation
│   │   │   ├── email_service.py          # Resend email wrapper
│   │   │   ├── otp_service.py            # OTP generator & validator
│   │   │   ├── prediction_runner.py      # ML execution interface
│   │   │   ├── prediction_service.py     # Prediction grouping & metrics
│   │   │   ├── sms_service.py            # Fast2SMS wrapper
│   │   │   └── verification_token_service.py # Hashed transient tokens
│   │   ├── static/                       # Static files server
│   │   │   └── commodity-images/         # Static images (1.jpeg, default.webp, etc.)
│   │   ├── utils/                        # Auth identifier helpers
│   │   └── main.py                       # FastAPI entrypoint & router registry
│   ├── price_fetcher.py                  # Scraper coordinator (V2 Agmarknet -> V1 Gov)
│   ├── price_fetcher_v1.py               # Gov V1 public API client
│   ├── price_fetcher_v2.py               # Agmarknet V2 JSON API client
│   ├── run_predictions.py                # Standalone LightGBM inference & batch saver
│   ├── commodity_normalizer.py           # Fuzzy matching for commodities
│   ├── market_normalizer.py              # Fuzzy matching for markets
│   ├── variety_normalizer.py             # Fuzzy matching for varieties
│   ├── commodity_aliases.py              # Alias dictionary mappings
│   ├── Data_mapping.py                   # Pre-compiled Agmarknet IDs mapping
│   ├── generate_mapping.py               # Agmarknet mapping generator
│   ├── insert_data.py                    # Mapping DB seeder
│   └── test_alerts_api.py                # Automated pytest suite for Alerts API
│
├── lib/
│   ├── core/
│   │   ├── constants/                    # ApiConstants (baseUrl, endpoints)
│   │   ├── providers/                    # localeProvider, storageProvider, authApiProvider
│   │   ├── theme/                        # AppTheme (Material 3 palettes)
│   │   └── widgets/                      # Global widgets (MobileFrameWrapper, CommodityImageWidget)
│   ├── data/
│   │   ├── datasources/                  # AlertFallbackDataSource (Offline mock engine)
│   │   ├── models/                       # Dart data models (Alert, Forecast, MandiPrice, UserProfile)
│   │   ├── repositories/                 # Repositories (AlertRepo, AuthRepo, ForecastRepo, MandiRepo)
│   │   └── services/                     # HTTP API clients (AlertApiService, AuthApiService, etc.)
│   ├── features/
│   │   ├── alerts/                       # AlertsScreen, AlertHistoryScreen, AlertCard, FilterChips
│   │   ├── auth/                         # Login, Signup, ForgotPassword, Onboarding, Profile, Settings
│   │   ├── forecasts/                    # ForecastsScreen, ForecastDetailScreen, Explore Screens
│   │   └── mandi_prices/                 # HomeScreen, FilterResultsScreen, MarketDetailScreen, MarketsScreen
│   ├── l10n/                             # ARB localizations (app_en.arb, app_hi.arb, app_ml.arb)
│   ├── main.dart                         # Flutter entrypoint & AuthWrapper
│   └── main_screen.dart                  # BottomNavBar tab navigator frame
└── test/
    └── alerts_feature_test.dart          # Automated Flutter widget & repository tests
```

---

# 4. High-Level Architecture

```mermaid
flowchart TD
    subgraph Client ["Flutter Mobile and Desktop App"]
        UI["Flutter UI Screens and Widgets"] -->|Watches| RP["Riverpod Providers"]
        RP -->|Calls| Repo["Repository Layer"]
        Repo -->|Online HTTP| AS["API Services"]
        Repo -.->|Network Fallback| FBDS["AlertFallbackDataSource"]
    end

    subgraph Server ["FastAPI Backend Service"]
        AS -->|Bearer JWT JSON| RT["FastAPI Routers"]
        RT -->|Injects| Deps["Auth and Database Dependencies"]
        RT -->|Invokes| Serv["Services Layer"]
        Serv -->|Queries| DBRepo["Repository Layer"]
        DBRepo -->|SQLAlchemy| DB[("PostgreSQL Database")]
        Static["StaticFiles Engine"] -->|Serves Images| UI
    end

    subgraph Predictions ["ML Forecast Engine"]
        CronP["Cron / Admin Trigger"] --> PR["run_predictions.py"]
        PR -->|Loads Weights| LGB["LightGBM Model"]
        PR -->|Reads History| DB
        LGB -->|Writes Batches| DB
    end

    subgraph AlertsEngine ["Alert Processor System"]
        CronA["Cron / Service Trigger"] --> AGS["AlertGenerationService"]
        AGS -->|Evaluates Shifts| Processors["PriceShiftProcessor"]
        Processors -->|Localizes via Templates| ALS["AlertLocalizationService"]
        ALS -->|Persists Alerts| DB
    end

    subgraph DataPipeline ["Price Scraper Pipeline"]
        CronS["External Cron"] --> PF["price_fetcher.py"]
        PF -->|Attempts V2| V2["Agmarknet API"]
        PF -->|Fallback V1| V1["Data.gov.in API"]
        PF -->|Fuzzy Matches| Norm["Normalizers"]
        Norm -->|Bulk Upsert| DB
    end
```

---

# 5. Backend Endpoints List

| Endpoint | Method | Auth | Purpose | Request Payload | Response Schema |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `/auth/send-otp` | `POST` | None | Generate & dispatch signup OTP | `SendOTPRequest` | `{"message", "identifier", "registration_method"}` |
| `/auth/verify-otp` | `POST` | None | Validate OTP; issue transient token | `VerifyOTPRequest` | `{"verification_token", "token_type", "expires_in_seconds"}` |
| `/auth/forgot-password/send-otp` | `POST` | None | Send reset password OTP | `SendOTPRequest` | `{"message", "identifier", "registration_method"}` |
| `/auth/forgot-password/verify-otp` | `POST` | None | Verify reset OTP; issue reset token | `VerifyOTPRequest` | `{"verification_token", "token_type", "expires_in_seconds"}` |
| `/auth/forgot-password/reset-password` | `POST` | None | Reset password using reset token | `ResetPasswordRequest` | `{"message"}` |
| `/auth/register` | `POST` | None | Register account using token | `UserRegister` | `UserResponse` |
| `/auth/login` | `POST` | None | Authenticate credentials & return JWT | `UserLogin` | `{"access_token", "token_type", "user"}` |
| `/auth/me` | `GET` | Bearer | Get current session user profile | None | `UserResponse` |
| `/profile` | `GET` | Bearer | Get profile with state & district | None | `UserResponse` |
| `/profile` | `PUT` | Bearer | Update profile details | `UserProfileUpdate` | `UserResponse` |
| `/profile/preferences` | `GET` | Bearer | Fetch user tracked crop preferences | None | `List[CropPreferenceResponse]` |
| `/profile/preferences` | `PUT` | Bearer | Bulk update user crop preferences | `CropPreferenceUpdate` | `List[CropPreferenceResponse]` |
| `/profile/notification-preferences` | `GET` | Bearer | Retrieve notification settings | None | `NotificationPreferenceResponse` |
| `/profile/notification-preferences` | `PUT` | Bearer | Update notification settings | `NotificationPreferenceUpdate` | `NotificationPreferenceResponse` |
| `/states/` | `GET` | None | List states with active markets | Query: `language` | `List[StateSchema]` |
| `/districts/` | `GET` | None | List districts in a state | Query: `state_id`, `language` | `List[DistrictSchema]` |
| `/markets/` | `GET` | None | List markets in a district | Query: `district_id`, `language` | `List[MarketSchema]` |
| `/markets/{id}/commodities` | `GET` | None | Active commodities in market today | Path: `market_id` | `{"market_id", "commodity_count", "commodities"}` |
| `/commodities/` | `GET` | None | List commodities with prices today | None | `List[CommoditySchema]` |
| `/commodities/active` | `GET` | None | List active trackable commodities | None | `List[CommoditySchema]` |
| `/commodities/all` | `GET` | None | List all mapped commodities | None | `List[CommoditySchema]` |
| `/mandi-prices/` | `GET` | None | Paginated search of mandi prices | Query: `state`, `district`, `market`, `commodity`, `variety`, `language`, `page`, `page_size` | `PaginatedMandiResponse` |
| `/price-history/` | `GET` | None | Get 7 latest price records | Query: `commodity`, `market`, `variety` | `List[PriceHistoryResponse]` |
| `/market-directory/` | `GET` | None | Paginated directory of active markets | Query: `state_id`, `district_id`, `commodity_id`, `search`, `language`, `page`, `page_size` | `PaginatedMarketResponse` |
| `/predictions/` | `GET` | Bearer | Get 7-day ML price predictions | Query: `commodity_id`, `market_id`, `commodity_ids`, `market_ids`, `language`, `page`, `page_size` | `PaginatedForecastResponse` |
| `/alerts` | `GET` | Bearer | Active actionable alerts for user | Query: `type`, `page`, `page_size` | `PaginatedAlertsResponse` |
| `/alerts/history` | `GET` | Bearer | Historical alerts archive | Query: `type`, `search`, `date_from`, `date_to`, `page`, `page_size` | `PaginatedAlertsResponse` |
| `/static/*` | `GET` | None | Serves static assets & images | Static asset path | Image file stream |

---

# 6. Database Schema

All primary database entities exist as SQLAlchemy models in `backend/app/models/`.

```mermaid
erDiagram
    states ||--o{ state_translations : "translated_by"
    states ||--o{ districts : "contains"
    districts ||--o{ district_translations : "translated_by"
    districts ||--o{ markets : "contains"
    markets ||--o{ market_translations : "translated_by"
    markets ||--o{ mandi_prices : "reports"
    markets ||--o{ commodity_predictions : "targets"
    markets ||--o{ alerts : "context_market"

    commodities_group ||--o{ commodities : "groups"
    commodities ||--o{ commodity_translations : "translated_by"
    commodities ||--o{ varieties : "includes"
    commodities ||--o{ grade : "categorizes"
    commodities ||--o{ active_commodity : "tracked_in"
    commodities ||--o{ mandi_prices : "records"
    commodities ||--o{ commodity_predictions : "forecasts"
    commodities ||--o{ user_crop_preferences : "tracked_by"
    commodities ||--o{ alerts : "context_commodity"

    varieties ||--o{ mandi_prices : "specifies"
    varieties ||--o{ commodity_predictions : "specifies"
    grade ||--o{ mandi_prices : "specifies"
    grade ||--o{ commodity_predictions : "specifies"

    prediction_batches ||--o{ commodity_predictions : "contains_batch"

    users ||--o{ user_crop_preferences : "prefers"
    users ||--o{ refresh_tokens : "owns"
    users ||--o{ notification_preferences : "configures"
    users ||--o{ alerts : "receives"
```

### Reference & Translation Tables
1. **`states`**: `id` (PK, INT), `name` (VARCHAR).
2. **`state_translations`**: `id` (PK, INT), `state_id` (FK -> `states.id`), `language_code` (VARCHAR(2)), `translated_name` (VARCHAR). Unique(`state_id`, `language_code`).
3. **`districts`**: `id` (PK, INT), `state_id` (FK -> `states.id`), `name` (VARCHAR).
4. **`district_translations`**: `id` (PK, INT), `district_id` (FK -> `districts.id`), `language_code` (VARCHAR(2)), `translated_name` (VARCHAR). Unique(`district_id`, `language_code`).
5. **`markets`**: `id` (PK, INT), `district_id` (FK -> `districts.id`), `name` (VARCHAR).
6. **`market_translations`**: `id` (PK, INT), `market_id` (FK -> `markets.id`), `language_code` (VARCHAR(2)), `translated_name` (VARCHAR). Unique(`market_id`, `language_code`).
7. **`commodities_group`**: `id` (PK, INT), `name` (VARCHAR).
8. **`commodities`**: `id` (PK, INT), `commodity_group_id` (FK -> `commodities_group.id`), `name` (VARCHAR).
9. **`commodity_translations`**: `id` (PK, INT), `commodity_id` (FK -> `commodities.id`), `language_code` (VARCHAR(2)), `translated_name` (VARCHAR). Unique(`commodity_id`, `language_code`).
10. **`varieties`**: `id` (PK, INT), `commodity_id` (FK -> `commodities.id`), `name` (VARCHAR).
11. **`grade`** (Table name: `grade`): `id` (PK, INT), `commodity_id` (FK -> `commodities.id`), `grade_name` (VARCHAR).
12. **`active_commodity`** (Table name: `active_commodity`): `id` (PK, INT), `commodity_id` (FK -> `commodities.id`, Unique, Cascade Delete).

### Transactional & Time-Series Tables
13. **`mandi_prices`**: `id` (PK, INT), `commodity_id` (FK -> `commodities.id`), `variety_id` (FK -> `varieties.id`), `grade_id` (FK -> `grade.id`), `market_id` (FK -> `markets.id`), `modal_price` (NUMERIC), `min_price` (NUMERIC), `max_price` (NUMERIC), `arrival_date` (DATE), `created_at` (TIMESTAMPTZ). Unique(`commodity_id`, `variety_id`, `grade_id`, `market_id`, `arrival_date`).
14. **`prediction_batches`**: `id` (PK, INT), `prediction_date` (DATE), `prediction_time` (VARCHAR), `model_version` (VARCHAR), `created_at` (TIMESTAMPTZ).
15. **`commodity_predictions`**: `id` (PK, INT), `batch_id` (FK -> `prediction_batches.id`), `market_id` (FK -> `markets.id`), `commodity_id` (FK -> `commodities.id`), `variety_id` (FK -> `varieties.id`), `grade_id` (FK -> `grade.id`), `prediction_day` (DATE), `predicted_price` (NUMERIC), `created_at` (TIMESTAMPTZ).

### Users & Session Tables
16. **`users`**: `id` (PK, UUID), `name` (VARCHAR), `email` (VARCHAR, Unique, Nullable), `phone_number` (VARCHAR, Unique, Nullable), `password_hash` (VARCHAR), `state_id` (FK -> `states.id`), `district_id` (FK -> `districts.id`), `preferred_market_id` (FK -> `markets.id`, Nullable), `preferred_language` (VARCHAR(20), Default='en'), `registration_method` (VARCHAR(20)), `is_verified` (BOOL), `created_at` (TIMESTAMPTZ), `updated_at` (TIMESTAMPTZ). Constraint: Exactly one of email or phone set.
17. **`user_crop_preferences`**: `user_id` (PK, FK -> `users.id`), `commodity_id` (PK, FK -> `commodities.id`).
18. **`refresh_tokens`**: `id` (PK, UUID), `user_id` (FK -> `users.id`), `token` (TEXT), `expires_at` (TIMESTAMPTZ).
19. **`otp_verifications`**: `id` (PK, UUID), `identifier` (VARCHAR), `otp_hash` (VARCHAR), `purpose` (VARCHAR), `expires_at` (TIMESTAMPTZ), `used` (BOOL), `created_at` (TIMESTAMPTZ).
20. **`verification_tokens`**: `id` (PK, UUID), `identifier` (VARCHAR), `token_hash` (VARCHAR), `purpose` (VARCHAR), `expires_at` (TIMESTAMPTZ), `used` (BOOL), `created_at` (TIMESTAMPTZ).
21. **`notification_preferences`**: `user_id` (PK, FK -> `users.id`), `price_increase` (BOOL), `price_drop` (BOOL), `better_market` (BOOL), `market_glut` (BOOL), `ai_recommendation` (BOOL), `delivery_in_app` (BOOL), `delivery_sms` (BOOL), `delivery_push` (BOOL), `frequency` (VARCHAR(20), default='instant'), `created_at` (TIMESTAMPTZ), `updated_at` (TIMESTAMPTZ).
22. **`alerts`**: `id` (PK, UUID), `user_id` (FK -> `users.id`), `type` (VARCHAR(50)), `severity` (VARCHAR(20)), `title` (VARCHAR(255)), `message` (TEXT), `commodity_id` (FK -> `commodities.id`), `market_id` (FK -> `markets.id`), `current_price` (FLOAT, Nullable), `previous_price` (FLOAT, Nullable), `change_percent` (FLOAT, Nullable), `created_at` (TIMESTAMPTZ).

---

# 7. Frontend Architecture & Screen Layout

```mermaid
flowchart TB
    subgraph AuthLayer ["Authentication and Onboarding Layer"]
        AuthWrapper["AuthWrapper \n Navigation Guard and Session Check"]
        LoginScreen["LoginScreen \n Email/Phone + Password"]
        SignupScreen["SignupScreen (3-Phase) \n Identifier -> Send OTP -> Register"]
        ForgotPasswordScreen["ForgotPasswordScreen (3-Phase) \n Identifier -> Reset OTP -> New Password"]
        OnboardingScreen["OnboardingScreen \n State, District, Lang and Tracked Crops"]
    end

    subgraph AppHub ["Main Application Shell"]
        MainScreen["MainScreen \n BottomNavBar (4 Main Tabs)"]
    end

    subgraph HomeTab ["Tab 0: Mandi Prices (Home)"]
        HomeScreen["HomeScreen \n Filters and Price Cards"]
        FilterResultsScreen["FilterResultsScreen \n Custom Query Results"]
    end

    subgraph MarketsTab ["Tab 1: Market Directory"]
        MarketsScreen["MarketsScreen \n State Dropdown and Search Bar"]
        MarketDirectoryDetailScreen["MarketDirectoryDetailScreen \n Market Metadata and Active Crops Grid"]
        MarketDetailScreen["MarketDetailScreen \n 7-Day Price LineChart and Stats Cards"]
    end

    subgraph AdvisoryTab ["Tab 2: Forecasts and Advisory"]
        ForecastsScreen["ForecastsScreen \n Preferred Crop Predictions"]
        CommodityAdvisoryScreen["CommodityAdvisoryScreen \n Commodity Predictions Breakdown"]
        ExploreMoreCommoditiesScreen["ExploreMoreCommoditiesScreen \n Search Portal for Non-Preferred Crops"]
        ExploreAdvisoryResultsScreen["ExploreAdvisoryResultsScreen \n Multi-Crop Prediction Results"]
        ForecastDetailScreen["ForecastDetailScreen \n 3 Sections: Prediction, AI Advisory & Forecast"]
        MarketComparisonScreen["MarketComparisonScreen \n Placeholder for Nearby Mandi Distance & Net Profit Comparison"]
    end

    subgraph AlertsHeader ["Alerts Header Navigation"]
        AlertsScreen["AlertsScreen \n Active Actionable Alerts and Filter Chips"]
        AlertHistoryScreen["AlertHistoryScreen \n Searchable Alert Archive and Date Grouping"]
    end

    subgraph ProfileTab ["Tab 3: Profile Management"]
        ProfileScreen["ProfileScreen \n User Info, Tracked Crops, Settings"]
        NotificationSettingsScreen["NotificationSettingsScreen \n Alert Toggles and Delivery Radios"]
    end

    LoginScreen --> SignupScreen
    LoginScreen --> ForgotPasswordScreen
    LoginScreen --> AuthWrapper
    SignupScreen --> AuthWrapper
    ForgotPasswordScreen --> LoginScreen
    AuthWrapper --> OnboardingScreen
    AuthWrapper --> MainScreen
    OnboardingScreen --> MainScreen
    MainScreen --> HomeScreen
    MainScreen --> MarketsScreen
    MainScreen --> ForecastsScreen
    MainScreen --> ProfileScreen
    HomeScreen --> AlertsScreen
    AlertsScreen --> AlertHistoryScreen
    HomeScreen --> FilterResultsScreen
    HomeScreen --> MarketDetailScreen
    FilterResultsScreen --> MarketDetailScreen
    MarketsScreen --> MarketDirectoryDetailScreen
    MarketDirectoryDetailScreen --> MarketDetailScreen
    ForecastsScreen --> CommodityAdvisoryScreen
    ForecastsScreen --> ExploreMoreCommoditiesScreen
    ForecastsScreen --> ForecastDetailScreen
    ExploreMoreCommoditiesScreen --> ExploreAdvisoryResultsScreen
    ExploreAdvisoryResultsScreen --> ForecastDetailScreen
    ForecastDetailScreen --> MarketComparisonScreen
    ProfileScreen --> OnboardingScreen
    ProfileScreen --> NotificationSettingsScreen
```

---

# 8. State Management

The frontend utilizes **Riverpod** (`flutter_riverpod`) for reactive state management and caching.

### Auth & User Providers
- `authProvider` (`auth_provider.dart`): `NotifierProvider<AuthNotifier, AuthState>`. Controls authentication status, active user profile, login, registration, and forgot password steps.
- `localeProvider` (`locale_provider.dart`): `StateNotifierProvider<LocaleNotifier, Locale>`. Manages active language locale (`en`, `hi`, `ml`).
- `profileNotifierProvider` (`profile_notifier.dart`): `AutoDisposeAsyncNotifierProvider<ProfileNotifier, UserProfile?>`. Caches user profile data from `/profile`.
- `preferredCropsNotifierProvider` (`profile_notifier.dart`): `AutoDisposeAsyncNotifierProvider<PreferredCropsNotifier, List<Map<String, dynamic>>>`. Caches tracked crop IDs from `/profile/preferences`.
- `editProfileDataProvider` (`edit_profile_data_provider.dart`): `FutureProvider.autoDispose<EditProfileData>`. Combines profile state, crop preferences, and location dropdowns.

### Mandi Prices Providers
- `mandiPricesProvider` (`mandi_prices_provider.dart`): `StateNotifierProvider.family<MandiPricesNotifier, AsyncValue<MandiPricesState>, Filter>`. Handles paginated daily price searches. Automatically refetches on locale changes to update translated entity names.
- `marketDirectoryProvider` (`mandi_prices_provider.dart`): Manages paginated market directory indexing.
- `statesProvider`, `districtsProvider`, `marketsProvider`, `marketsListProvider`: Location lookup providers reactive to `localeProvider`.

### Forecasts & Predictions Providers
- `forecastRepositoryProvider` (`forecast_provider.dart`): Injects `ForecastRepository`.
- `forecastsNotifierProvider` (`forecast_provider.dart`): `StateNotifierProvider<ForecastsNotifier, AsyncValue<PaginatedForecastResponse>>`. Watches `preferredCropsNotifierProvider` and `forecastsFilterProvider` to fetch 7-day price forecasts.
- `explorePredictionsProvider` (`forecast_provider.dart`): `FutureProvider.family<PaginatedForecastResponse, ExplorePredictionsParams>`. Fetches predictions for explored non-preferred commodities.
- `preferredCommoditiesProvider` (`forecast_provider.dart`): Resolves preferred crop IDs to localized `Commodity` objects.

### Alerts Providers
- `alertRepositoryProvider` (`alert_providers.dart`): Injects `AlertRepository` with transparent HTTP API client and fallback offline data source (`AlertFallbackDataSource`).
- `alertsNotifierProvider` (`alert_providers.dart`): `StateNotifierProvider<AlertsNotifier, AlertsState>`. Manages active alerts list, filter chips (`All`, `Better Market`, `Price Increase`, `Price Drop`, `AI Recommendation`), pagination, and pull-to-refresh.
- `alertHistoryNotifierProvider` (`alert_providers.dart`): `StateNotifierProvider<AlertHistoryNotifier, AlertHistoryState>`. Manages searchable alert archives, date filters, and presentation-layer date grouping ("Today", "Yesterday", "8 August 2026", etc.).

---

# 9. Models & Schemas

### Frontend Data Models (`lib/data/models/`)
- `UserProfile` (`user_profile.dart`): User details model (`hasCompletedProfile` check).
- `MandiPrice` (`mandi_price.dart`): Price record with `grade`, `variety`, `minPrice`, `maxPrice`, `modalPrice`, `arrivalDate`, and `getDisplayCommodity()`.
- `CommodityForecast` (`forecast_model.dart`): 7-day ML prediction containing `commodityId`, `commodityName`, `varietyName`, `gradeName`, `marketName`, `districtName`, `stateName`, `currentPrice`, `forecast` (`List<ForecastDay>`), `trend` (`Rising`/`Falling`/`Stable`), `bestSellDate`, `expectedPeakPrice`, `recommendation` (`Sell Today`/`Wait`/`Hold`), `transportCost`, `marketFee`, `expectedProfit`, `recommendationReason`, `aiRecommendationTitle`.
- `PaginatedForecastResponse` (`forecast_model.dart`): Container for paginated predictions.
- `Alert` (`alert_model.dart`): Actionable alert object containing `id`, `type`, `severity`, `title`, `message`, `commodity`, `market`, `price` (`current`, `previous`, `changePercent`), `createdAt`.
- `PaginatedAlertsResponse` (`alert_model.dart`): Container for paginated alerts. Defensively filters out any `MARKET_GLUT` entries.
- `NotificationPreferences` (`notification_preferences.dart`): Delivery channel toggles and frequency (`instant` vs `daily_summary`).

### Backend Schemas (`backend/app/schemas/`)
- `UserResponse`, `UserRegister`, `UserLogin`, `SendOTPRequest`, `VerifyOTPRequest`, `ResetPasswordRequest` (`user.py`).
- `StateSchema`, `DistrictSchema`, `MarketSchema` (`location.py`).
- `MandiPriceSchema`, `PaginatedMandiResponse` (`mandi_price.py`).
- `ForecastResponse` (includes `transport_cost`, `market_fee`, `expected_profit`, `recommendation_reason`, `ai_recommendation_title`), `PaginatedForecastResponse` (`prediction.py`).
- `AlertSchema`, `PaginatedAlertsResponse`, `AlertCreateSchema`, `AlertType`, `AlertSeverity` (`alert.py`).
- `NotificationPreferenceResponse`, `NotificationPreferenceUpdate` (`notification_preference.py`).

---

# 10. Services & Processing Logic

### Authentication & Security Services
1. **`AuthService`** (`auth_service.py`): Handles email/phone normalization, OTP dispatching, verification token generation, password hashing, and user creation.
2. **`OTPService`** (`otp_service.py`): Generates cryptographically secure 6-digit OTP codes, bcrypts them before database storage, and validates 5-minute expiry windows.
3. **`VerificationTokenService`** (`verification_token_service.py`): Generates 32-character URL-safe verification tokens, hashes them in the database, and enforces 10-minute validity.
4. **`EmailService`** (`email_service.py`): Resend SDK wrapper for sending transactional emails containing OTPs.
5. **`SMSService`** (`sms_service.py`): Fast2SMS API wrapper (`https://www.fast2sms.com/dev/bulkV2`) for dispatching SMS OTPs (with console print fallback during dev).

### Machine Learning & Prediction Services
6. **`PredictionRunner`** (`prediction_runner.py`): Programmatic trigger interface that invokes `run_predictions.py`.
7. **`PredictionService`** (`prediction_service.py`): Fetches raw predictions from `prediction_batches` and `commodity_predictions`, groups chronological days by `(commodity_id, market_id, variety_id, grade_id)`, computes peak price, best selling day, trend, and recommendation, and localizes names via translation tables.

### Alert Engine & Localization Services
8. **`AlertGenerationService`** (`alert_generation_service.py`): Dispatches alert processors (`PriceShiftProcessor`, etc.) to evaluate price shifts and persist new alerts into the `alerts` table.
9. **`AlertLocalizationService`** (`alert_localization.py`): Multi-language alert template renderer (EN, HI, ML) with in-memory translation caches for commodities and markets.
10. **`AlertService`** (`alert_service.py`): Manages database queries for active alerts, searchable history, and deterministic sorting (`created_at desc, id desc`).

---

# 11. Machine Learning & Prediction Pipeline

The predictive intelligence module estimates future modal prices for 7 days into the future.

```
[Raw mandi_prices DB records] ──► [Feature Engineering: 7-day Lags, Rolling Averages, Seasonality]
                                                   │
                                                   ▼
                                       [LightGBM Model Weights]
                                                   │
                                                   ▼
                                 [Generated 7-Day Forecast Batch]
                                                   │
                                                   ▼
                                [prediction_batches & commodity_predictions]
```

- **Model Engine**: LightGBM regression model with weights stored in `backend/app/ml/lightgbm_weights.txt` and feature specifications in `model_features.json`.
- **Feature Engineering**: Calculates historical lag features (lag_1, lag_7), rolling mean/std statistics, seasonal day-of-year indicators, and trend direction encodings.
- **Execution Script**: `backend/run_predictions.py` executes full batch predictions across all active commodity-market-variety-grade combinations and writes records to `prediction_batches` and `commodity_predictions`.
- **Business Logic Computation**:
  - **Trend**: `RISING` if end price > start price; `FALLING` if end price < start price; else `STABLE`.
  - **Best Selling Day**: The date within the 7-day trajectory when price reaches its maximum value (`expected_peak_price`).
  - **Recommendation**: `SELL TODAY` if best selling day is today or trend is `FALLING`; `WAIT` if trend is `RISING`; else `HOLD`.

---

# 12. Actionable Alerts & Notification System

Conforms strictly to the **Alerts API — v1 Contract**.

### Alert Types & Scope
- **Supported Types**: `PRICE_INCREASE`, `PRICE_DROP`, `BETTER_MARKET`, `AI_RECOMMENDATION`.
- **Explicit Exclusion**: `MARKET_GLUT` is explicitly **OUT OF SCOPE**. Any request containing `type=MARKET_GLUT` is rejected by the backend with `HTTP 400 Bad Request`.
- **Backend Architecture**:
  - `Alert` SQLAlchemy model mapping to `alerts` table.
  - `AlertService` providing `get_user_alerts` and `get_user_alert_history` with full-text SQL search across titles, messages, commodities, and markets.
  - `AlertGenerationService` coordinating `PriceShiftProcessor` instances.
  - `AlertLocalizationService` applying localized message templates (`en`, `hi`, `ml`).
- **Frontend Architecture**:
  - `AlertRepository` transparently attempts the real `/alerts` HTTP API. On network failures or offline demo scenarios, it seamlessly falls back to `AlertFallbackDataSource` (which provides realistic mock alerts for Tomato in Thrissur, Coconut in Kozhikode, Potato in Palakkad).
  - `AlertsScreen` renders active alerts with filter chips (`All`, `Better Market`, `Price Increase`, `Price Drop`, `AI Recommendation`).
  - `AlertHistoryScreen` renders searchable archives with date range bounds and presentation-layer date grouping ("Today", "Yesterday", "8 August 2026", etc.).

---

# 13. Data Ingestion Engine

`backend/price_fetcher.py` runs scheduled price ingestion:

1. Loads active commodities from `active_commodity`.
2. Resolves commodity parameters using `Data_mapping.py` generated by `generate_mapping.py`.
3. Calls **Agmarknet V2 Daily API** (`https://api.agmarknet.gov.in/v1/daily-price-arrival/report`) via JSON POST.
4. If V2 fails (timeout, 5xx server error, or rate limit), falls back to **Gov V1 Public API** (`https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070`) using API Key authentication.
5. Ingested records pass through `validate_records()`.
6. Fuzzy normalizers map string text to database foreign key IDs (`commodity_id`, `market_id`, `variety_id`, `grade_id`).
7. Performs bulk upserts into `mandi_prices` using PostgreSQL `on_conflict_do_update` on constraint `mandi_prices_unique`.

---

# 14. Authentication, Recovery & Profile Lifecycle

### 1. User Registration Flow
```
User (Email/Phone) ──► /auth/send-otp ──► [Resend Email / Fast2SMS]
                                                │
User enters OTP ◄───────────────────────────────┘
       │
       ▼
/auth/verify-otp ──► Returns hashed transient verification_token (10 min expiry)
       │
       ▼
/auth/register (Provides Name, Password, verification_token) ──► Account Created & User Logged In
```

### 2. Password Recovery Flow
```
User ──► /auth/forgot-password/send-otp ──► [Dispatches Reset OTP]
                                                   │
User enters OTP ◄──────────────────────────────────┘
       │
       ▼
/auth/forgot-password/verify-otp ──► Returns transient reset token
       │
       ▼
/auth/forgot-password/reset-password (New Password + Token) ──► Password Updated & Navigates to Login
```

### 3. Session Guard
`AuthWrapper` (`main.dart`) checks `authProvider`. If user is unauthenticated -> `LoginScreen`. If profile is incomplete (`state_id == null || district_id == null`) -> `OnboardingScreen`. Otherwise -> `MainScreen`.

---

# 15. Localization Architecture

- **Database Entity Translations**:
  - State names in `state_translations`.
  - District names in `district_translations`.
  - Market names in `market_translations`.
  - Commodity names in `commodity_translations`.
  - API endpoints accept `?language=en`, `?language=hi`, or `?language=ml` query parameters, performing SQL joins on translation tables and falling back to English columns when translation rows are absent.
- **Frontend App UI Translations**:
  - Defined in ARB files: `lib/l10n/app_en.arb`, `app_hi.arb`, `app_ml.arb`.
  - Generated into `AppLocalizations` via `flutter gen-l10n`.
  - Active locale stored in `localeProvider`. Changing locale dynamically re-triggers API providers to fetch localized data.

---

# 16. External APIs & Third-Party Integrations

1. **Agmarknet V2 Daily API**: `https://api.agmarknet.gov.in/v1/daily-price-arrival/report` (Primary price scraper).
2. **Gov V1 Public API**: `https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070` (Fallback price scraper, requires `api-key`).
3. **Resend SMTP Email API**: Dispatches OTP verification emails. Requires `RESEND_API_KEY`.
4. **Fast2SMS Bulk V2 API**: `https://www.fast2sms.com/dev/bulkV2` (SMS OTP dispatcher). Requires `FAST2SMS_API_KEY`.

---

# 17. Important Constants & Configuration

### Environment Variables (`backend/.env`)
- `DATABASE_URL`: Hosted PostgreSQL connection URL.
- `SECRET_KEY`: Used for JWT signing.
- `API_KEY`: Gov data API key.
- `RESEND_API_KEY`: API key for email delivery.
- `FAST2SMS_API_KEY`: API key for Fast2SMS gateway.
- `SMTP_HOST`, `SMTP_PORT`, `SMTP_EMAIL`, `SMTP_PASSWORD`: Fallback SMTP configuration.

### Frontend Base Constants (`lib/core/constants/api_constants.dart`)
- `baseUrl`: `https://mandi-intelligence-app-production.up.railway.app`
- Static images base route: `/static/commodity-images/{commodityId}.jpeg`

---

# 18. Common Development Tasks

### 1. Adding a New API Endpoint
- **Backend**:
  1. Define Pydantic schema in `backend/app/schemas/`.
  2. Implement route logic in relevant file under `backend/app/api/routes/` or new router.
  3. Register router in `backend/app/main.py` using `app.include_router()`.
- **Frontend**:
  1. Define model in `lib/data/models/`.
  2. Implement HTTP call in service under `lib/data/services/`.
  3. Expose method in repository under `lib/data/repositories/`.
  4. Create Riverpod provider in relevant feature `providers/`.

### 2. Adding a Database Entity
- **Backend**:
  1. Create SQLAlchemy model in `backend/app/models/`.
  2. Export model in `backend/app/models/__init__.py`.
  3. Run `python create_tables.py` or execute `Base.metadata.create_all()`.

---

# 19. Technical Debt, Gotchas & Key Design Decisions

1. **Desktop Viewport Wrapper (`MobileFrameWrapper`)**: On web or desktop browsers (screen width > 450px), `MobileFrameWrapper` wraps the app in a realistic 390x884 mobile device mockup frame with dark slate background and subtle glows, ensuring UI visual consistency across all viewports.
2. **Singular Database Table Names**: Note that `grade` and `active_commodity` are named singular in PostgreSQL. All other tables (`states`, `districts`, `markets`, `commodities`, `varieties`, `mandi_prices`, `users`, `alerts`, `prediction_batches`, `commodity_predictions`, `notification_preferences`) are named plural.
3. **`MARKET_GLUT` Exclusion**: `MARKET_GLUT` is explicitly excluded across backend validators, repositories, UI filter chips, and data models. Querying `MARKET_GLUT` returns `HTTP 400 Bad Request`.
4. **Dual-Mode Fallback Repository Pattern**: To guarantee seamless demo execution and offline resilience, `AlertRepository` transparently falls back to `AlertFallbackDataSource` if API network requests fail or time out.
5. **Transient Verification Tokens**: `auth/verify-otp` returns a cryptographically hashed 10-minute token. Registration calls (`/auth/register`) require this token, ensuring account creation originates from verified email/phone numbers.
6. **In-Memory Reference Dictionary Caching**: `price_fetcher.py` loads entities into memory maps to achieve $O(1)$ lookup times during high-volume fuzzy matching normalization.
7. **FastAPI Lifespan Tasks**: Commented out inside `main.py` to prevent startup context blocking. Data fetching (`price_fetcher.py`), prediction execution (`run_predictions.py`), and alert processing (`scripts/run_alert_generation.py`) are triggered via external cron or administrative CLI scripts.
