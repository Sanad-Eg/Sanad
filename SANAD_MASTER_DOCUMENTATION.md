# 📘 SANAD (سند) — Master Project Documentation
> **Version:** 1.0.0 | **Last Updated:** 2026 | **Status:** 🟡 In Development
> 
> ⚠️ **AI TOOL INSTRUCTION:** Read this entire file before generating any code, suggestion, or review.
> This is the single source of truth for the Sanad project. Never contradict or bypass these rules.

---

## 📋 Table of Contents
1. [Project Overview](#1-project-overview)
2. [User Roles](#2-user-roles)
3. [Tech Stack](#3-tech-stack)
4. [Architecture Rules](#4-architecture-rules)
5. [Folder Structure](#5-folder-structure)
6. [Features & Screens](#6-features--screens)
7. [Core Business Logic](#7-core-business-logic)
8. [Data Models](#8-data-models)
9. [State Machine](#9-state-machine)
10. [Firebase Schema](#10-firebase-schema)
11. [Navigation Map](#11-navigation-map)
12. [Design System](#12-design-system)
13. [Coding Standards](#13-coding-standards)
14. [Progress Tracker](#14-progress-tracker)
15. [Known Decisions & Rationale](#15-known-decisions--rationale)

---

## 1. Project Overview

| Field | Value |
|---|---|
| **App Name** | سند (Sanad) |
| **Category** | Gig Economy / Social Assistance |
| **Concept** | Connects people needing daily help (elderly, mobility/visual impairment) with verified ordinary helpers for an agreed hourly rate |
| **Type** | Strictly NON-Medical. Helpers are NOT doctors or nurses |
| **Platforms** | iOS & Android (Flutter) |
| **Language** | Arabic (RTL — Right to Left) |
| **Monetization** | 15% flat commission per completed transaction |

### What Sanad is NOT:
- ❌ NOT a medical app
- ❌ NOT a telemedicine platform
- ❌ NOT a delivery app
- ❌ NOT using live continuous GPS tracking

### What Sanad IS:
- ✅ A task-helper marketplace (like TaskRabbit but for social assistance)
- ✅ A time-based booking platform with escrow payment
- ✅ A verified helper network for vulnerable individuals

---

## 2. User Roles

### 2.1 Client (العميل / محتاج المساعدة)
A person who needs daily assistance. Types of needs:
- `visual_impairment` — إعاقة بصرية
- `mobility_assistance` — مساعدة حركية
- `elderly_care` — رعاية كبار السن
- `home_tasks` — أعمال منزلية
- `companionship` — مرافقة خارج المنزل

**Can:**
- Browse and search helpers
- Send booking requests
- Negotiate price (max 2 rounds)
- Pay via Escrow
- Track booking status
- Store medical documents in Medical Vault
- Add emergency contacts
- Rate helpers after completion

### 2.2 Helper (المساعد / مقدم المساعدة)
A verified ordinary person who provides assistance for an hourly rate.

**Can:**
- Register and get verified (ID + selfie with ID)
- Manage availability schedule
- Accept / Reject / Counter-offer booking requests (30-min window)
- View upcoming appointments
- Confirm service completion
- Withdraw earnings

**Cannot:**
- Provide any medical advice or diagnosis
- Start/End sessions manually (auto-managed by Cloud Functions)

### 2.3 Admin (الأدمن)
Internal Sanad team member.

**Can:**
- View pending helper verification requests
- Approve or reject helper documents
- View platform statistics

---

## 3. Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Frontend** | Flutter (latest stable) | iOS & Android UI |
| **Auth** | Firebase Authentication | Email/Phone login |
| **Database** | Cloud Firestore | Real-time data |
| **File Storage** | Firebase Storage | Profile photos, documents, medical vault |
| **Backend Logic** | Firebase Cloud Functions (Node.js) | CRON jobs, auto state transitions, escrow logic |
| **Notifications** | Firebase Cloud Messaging (FCM) | Push notifications |
| **Maps** | Google Maps API | Location pin selection ONLY — no live tracking |
| **State Management** | Flutter Bloc / Cubit | UI state management |
| **DI** | GetIt | Dependency injection |
| **Navigation** | GoRouter | Declarative routing |

### 3.1 Key Packages (pubspec.yaml)
```yaml
dependencies:
  flutter_bloc: ^8.x
  get_it: ^7.x
  go_router: ^13.x
  firebase_core: ^3.x
  firebase_auth: ^5.x
  cloud_firestore: ^5.x
  firebase_storage: ^12.x
  firebase_messaging: ^15.x
  google_maps_flutter: ^2.x
  dartz: ^0.10.x          # Functional programming (Either type)
  equatable: ^2.x          # Value equality
  freezed: ^2.x            # Immutable data classes
  json_annotation: ^4.x
  intl: ^0.19.x            # Arabic date/number formatting
  cached_network_image: ^3.x
  image_picker: ^1.x
  flutter_localizations: # Arabic RTL support
```

---

## 4. Architecture Rules

### ⚠️ CRITICAL — These rules MUST NEVER be violated

```
┌─────────────────────────────────────────────┐
│           PRESENTATION LAYER                 │
│   (Screens, Widgets, Cubits)                 │
│   ✅ Flutter UI   ✅ Cubits                   │
│   ❌ NO Firebase imports                     │
│   ❌ NO direct data calls                    │
└──────────────────┬──────────────────────────┘
                   │ calls UseCases only
┌──────────────────▼──────────────────────────┐
│              DOMAIN LAYER                    │
│   (Entities, Abstract Repos, UseCases)       │
│   ✅ Pure Dart ONLY                          │
│   ❌ NO Firebase   ❌ NO Flutter UI          │
│   ❌ NO http   ❌ NO external packages       │
└──────────────────┬──────────────────────────┘
                   │ implemented by
┌──────────────────▼──────────────────────────┐
│               DATA LAYER                     │
│   (Firebase Repos, Models, DataSources)      │
│   ✅ Firebase   ✅ API calls                 │
│   ✅ fromJson / toJson                       │
└─────────────────────────────────────────────┘
```

### 4.1 Layer Responsibilities

**Domain Layer (lib/features/X/domain/)**
- `entities/` — Pure Dart classes. No fromJson. No Firebase.
- `repositories/` — Abstract interfaces (contracts). Never implemented here.
- `usecases/` — Single-responsibility business operations.

**Data Layer (lib/features/X/data/)**
- `models/` — Extend entities. Add fromJson/toJson/fromFirestore.
- `repositories/` — Implement domain abstract repos.
- `datasources/` — Firebase/API calls (remote) or local cache.

**Presentation Layer (lib/features/X/presentation/)**
- `screens/` — Full page widgets.
- `widgets/` — Reusable UI components for this feature.
- `cubit/` — State + business presentation logic.

### 4.2 Dependency Inversion Strategy
During UI development, use `DummyRepository` implementations.
Switch to `FirebaseRepository` implementations via GetIt for production.

```dart
// ✅ CORRECT — switch in injection_container.dart
// Development:
sl.registerLazySingleton<BookingRepository>(() => DummyBookingRepository());

// Production:
sl.registerLazySingleton<BookingRepository>(() => FirebaseBookingRepository(sl()));
```

### 4.3 UseCase Pattern
Every use case takes one input, returns `Either<Failure, T>`.

```dart
// Domain layer
class SendBookingRequestUseCase {
  final BookingRepository repository;
  SendBookingRequestUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call(BookingRequestParams params) {
    return repository.sendBookingRequest(params);
  }
}
```

---

## 5. Folder Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           # Design system colors
│   │   ├── app_text_styles.dart      # Typography
│   │   ├── app_strings.dart          # All Arabic strings
│   │   ├── app_assets.dart           # Asset paths
│   │   └── app_constants.dart        # Business constants (15% fee, 30min timeout, etc.)
│   ├── errors/
│   │   ├── failures.dart             # Failure sealed classes
│   │   └── exceptions.dart           # Custom exceptions
│   ├── network/
│   │   └── network_info.dart         # Connectivity check
│   ├── usecases/
│   │   └── usecase.dart              # Abstract UseCase<Type, Params>
│   ├── utils/
│   │   ├── date_utils.dart           # Arabic date formatting
│   │   ├── price_utils.dart          # SAR formatting
│   │   └── validators.dart           # Form validators (Arabic)
│   ├── widgets/
│   │   ├── sanad_button.dart         # Primary/Secondary/Danger buttons
│   │   ├── sanad_text_field.dart     # RTL input field
│   │   ├── sanad_app_bar.dart        # Consistent app bar
│   │   ├── loading_widget.dart       # Skeleton loaders
│   │   ├── error_widget.dart         # Error state widget
│   │   ├── empty_state_widget.dart   # Empty state widget
│   │   └── sos_button.dart           # Floating SOS button
│   └── router/
│       ├── app_router.dart           # GoRouter config
│       └── app_routes.dart           # Route name constants
│
├── features/
│   │
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/user_entity.dart
│   │   │   ├── repositories/auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_client_usecase.dart
│   │   │       ├── register_helper_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   ├── data/
│   │   │   ├── models/user_model.dart
│   │   │   ├── datasources/auth_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       ├── dummy_auth_repository.dart
│   │   │       └── firebase_auth_repository.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── onboarding_screen.dart
│   │       │   ├── role_selection_screen.dart
│   │       │   ├── login_screen.dart
│   │       │   ├── client_register_screen.dart
│   │       │   └── helper_register_screen.dart   # 3 steps
│   │       ├── widgets/
│   │       │   ├── onboarding_slide.dart
│   │       │   └── role_card.dart
│   │       └── cubit/
│   │           ├── auth_cubit.dart
│   │           └── auth_state.dart
│   │
│   ├── helper_discovery/
│   │   ├── domain/
│   │   │   ├── entities/helper_entity.dart
│   │   │   ├── repositories/helper_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_helpers_usecase.dart
│   │   │       └── get_helper_profile_usecase.dart
│   │   ├── data/
│   │   │   ├── models/helper_model.dart
│   │   │   ├── datasources/helper_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       ├── dummy_helper_repository.dart
│   │   │       └── firebase_helper_repository.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── client_home_screen.dart
│   │       │   ├── search_results_screen.dart
│   │       │   └── helper_profile_screen.dart
│   │       ├── widgets/
│   │       │   ├── helper_card.dart
│   │       │   ├── service_category_card.dart
│   │       │   ├── filter_chips_bar.dart
│   │       │   └── helper_review_card.dart
│   │       └── cubit/
│   │           ├── helper_discovery_cubit.dart
│   │           └── helper_discovery_state.dart
│   │
│   ├── booking/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── booking_entity.dart
│   │   │   │   └── negotiation_entity.dart
│   │   │   ├── repositories/booking_repository.dart
│   │   │   └── usecases/
│   │   │       ├── send_booking_request_usecase.dart
│   │   │       ├── accept_booking_usecase.dart
│   │   │       ├── reject_booking_usecase.dart
│   │   │       ├── counter_offer_usecase.dart
│   │   │       ├── pay_booking_usecase.dart
│   │   │       ├── confirm_completion_usecase.dart
│   │   │       └── get_booking_stream_usecase.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── booking_model.dart
│   │   │   │   └── negotiation_model.dart
│   │   │   ├── datasources/booking_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       ├── dummy_booking_repository.dart
│   │   │       └── firebase_booking_repository.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── booking_step1_datetime_screen.dart
│   │       │   ├── booking_step2_location_screen.dart
│   │       │   ├── booking_step3_task_screen.dart
│   │       │   ├── booking_step4_summary_screen.dart
│   │       │   ├── awaiting_response_screen.dart
│   │       │   ├── negotiation_screen.dart
│   │       │   ├── payment_screen.dart
│   │       │   ├── booking_success_screen.dart
│   │       │   ├── booking_tracking_screen.dart
│   │       │   ├── active_service_screen.dart
│   │       │   └── confirm_completion_screen.dart
│   │       ├── widgets/
│   │       │   ├── booking_progress_bar.dart
│   │       │   ├── time_slot_grid.dart
│   │       │   ├── arabic_calendar.dart
│   │       │   ├── booking_status_timeline.dart
│   │       │   ├── countdown_timer_widget.dart
│   │       │   └── price_breakdown_card.dart
│   │       └── cubit/
│   │           ├── booking_flow_cubit.dart
│   │           ├── booking_flow_state.dart
│   │           ├── booking_tracking_cubit.dart
│   │           └── booking_tracking_state.dart
│   │
│   ├── helper_dashboard/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── schedule_slot_entity.dart
│   │   │   │   └── earnings_entity.dart
│   │   │   ├── repositories/helper_dashboard_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_schedule_usecase.dart
│   │   │       ├── update_availability_usecase.dart
│   │   │       ├── get_earnings_usecase.dart
│   │   │       └── withdraw_earnings_usecase.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── schedule_slot_model.dart
│   │   │   │   └── earnings_model.dart
│   │   │   ├── datasources/helper_dashboard_datasource.dart
│   │   │   └── repositories/
│   │   │       ├── dummy_helper_dashboard_repository.dart
│   │   │       └── firebase_helper_dashboard_repository.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── helper_home_screen.dart
│   │       │   ├── incoming_request_screen.dart
│   │       │   ├── counter_offer_screen.dart
│   │       │   ├── helper_schedule_screen.dart
│   │       │   ├── helper_earnings_screen.dart
│   │       │   └── helper_active_session_screen.dart
│   │       ├── widgets/
│   │       │   ├── incoming_request_card.dart
│   │       │   ├── schedule_week_view.dart
│   │       │   ├── earnings_chart.dart
│   │       │   └── transaction_list_item.dart
│   │       └── cubit/
│   │           ├── helper_home_cubit.dart
│   │           ├── helper_home_state.dart
│   │           ├── schedule_cubit.dart
│   │           ├── schedule_state.dart
│   │           ├── earnings_cubit.dart
│   │           └── earnings_state.dart
│   │
│   ├── verification/
│   │   ├── domain/
│   │   │   ├── entities/verification_entity.dart
│   │   │   ├── repositories/verification_repository.dart
│   │   │   └── usecases/
│   │   │       ├── submit_verification_usecase.dart
│   │   │       └── get_verification_status_usecase.dart
│   │   ├── data/
│   │   │   ├── models/verification_model.dart
│   │   │   ├── datasources/verification_datasource.dart
│   │   │   └── repositories/
│   │   │       ├── dummy_verification_repository.dart
│   │   │       └── firebase_verification_repository.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── verification_screen.dart
│   │       │   └── verification_pending_screen.dart
│   │       └── cubit/
│   │           ├── verification_cubit.dart
│   │           └── verification_state.dart
│   │
│   ├── medical_vault/
│   │   ├── domain/
│   │   │   ├── entities/medical_document_entity.dart
│   │   │   ├── repositories/vault_repository.dart
│   │   │   └── usecases/
│   │   │       ├── upload_document_usecase.dart
│   │   │       ├── get_documents_usecase.dart
│   │   │       └── toggle_share_with_helper_usecase.dart
│   │   ├── data/
│   │   │   ├── models/medical_document_model.dart
│   │   │   ├── datasources/vault_datasource.dart
│   │   │   └── repositories/
│   │   │       ├── dummy_vault_repository.dart
│   │   │       └── firebase_vault_repository.dart
│   │   └── presentation/
│   │       ├── screens/medical_vault_screen.dart
│   │       ├── widgets/document_list_item.dart
│   │       └── cubit/
│   │           ├── vault_cubit.dart
│   │           └── vault_state.dart
│   │
│   ├── profile/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── client_profile_entity.dart
│   │   │   │   ├── helper_profile_entity.dart
│   │   │   │   └── emergency_contact_entity.dart
│   │   │   ├── repositories/profile_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_client_profile_usecase.dart
│   │   │       ├── get_helper_profile_usecase.dart
│   │   │       ├── update_profile_usecase.dart
│   │   │       └── manage_emergency_contacts_usecase.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── client_profile_model.dart
│   │   │   │   ├── helper_profile_model.dart
│   │   │   │   └── emergency_contact_model.dart
│   │   │   ├── datasources/profile_datasource.dart
│   │   │   └── repositories/
│   │   │       ├── dummy_profile_repository.dart
│   │   │       └── firebase_profile_repository.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── client_profile_screen.dart
│   │       │   ├── helper_professional_profile_screen.dart
│   │       │   └── emergency_contacts_screen.dart
│   │       ├── widgets/emergency_contact_card.dart
│   │       └── cubit/
│   │           ├── profile_cubit.dart
│   │           └── profile_state.dart
│   │
│   ├── chat/
│   │   ├── domain/
│   │   │   ├── entities/message_entity.dart
│   │   │   ├── repositories/chat_repository.dart
│   │   │   └── usecases/
│   │   │       ├── send_message_usecase.dart
│   │   │       └── get_messages_stream_usecase.dart
│   │   ├── data/
│   │   │   ├── models/message_model.dart
│   │   │   ├── datasources/chat_datasource.dart
│   │   │   └── repositories/
│   │   │       ├── dummy_chat_repository.dart
│   │   │       └── firebase_chat_repository.dart
│   │   └── presentation/
│   │       ├── screens/chat_screen.dart
│   │       ├── widgets/
│   │       │   ├── message_bubble.dart
│   │       │   └── chat_input_bar.dart
│   │       └── cubit/
│   │           ├── chat_cubit.dart
│   │           └── chat_state.dart
│   │
│   ├── notifications/
│   │   ├── domain/
│   │   │   ├── entities/notification_entity.dart
│   │   │   ├── repositories/notification_repository.dart
│   │   │   └── usecases/get_notifications_usecase.dart
│   │   ├── data/
│   │   │   ├── models/notification_model.dart
│   │   │   └── repositories/
│   │   │       ├── dummy_notification_repository.dart
│   │   │       └── firebase_notification_repository.dart
│   │   └── presentation/
│   │       ├── screens/notifications_screen.dart
│   │       ├── widgets/notification_list_item.dart
│   │       └── cubit/
│   │           ├── notifications_cubit.dart
│   │           └── notifications_state.dart
│   │
│   └── admin/
│       ├── domain/
│       │   ├── entities/pending_verification_entity.dart
│       │   ├── repositories/admin_repository.dart
│       │   └── usecases/
│       │       ├── get_pending_verifications_usecase.dart
│       │       ├── approve_helper_usecase.dart
│       │       └── reject_helper_usecase.dart
│       ├── data/
│       │   ├── models/pending_verification_model.dart
│       │   ├── datasources/admin_datasource.dart
│       │   └── repositories/
│       │       ├── dummy_admin_repository.dart
│       │       └── firebase_admin_repository.dart
│       └── presentation/
│           ├── screens/admin_verification_screen.dart
│           ├── widgets/verification_request_card.dart
│           └── cubit/
│               ├── admin_cubit.dart
│               └── admin_state.dart
│
├── injection_container.dart         # GetIt DI setup
└── main.dart
```

---

## 6. Features & Screens

### 6.1 Client-Side Screens

| # | Screen | Route | Description |
|---|---|---|---|
| 1 | Onboarding | `/onboarding` | 3-slide intro carousel |
| 2 | Role Selection | `/role-select` | I need help / I want to help |
| 3 | Client Register | `/register/client` | Name, phone, email, password, need type |
| 4 | Login | `/login` | Email/phone + password |
| 5 | Client Home | `/client/home` | Service categories + top helpers |
| 6 | Search Results | `/search` | Filtered helper list |
| 7 | Search Loading | `/search` (loading state) | Skeleton UI |
| 8 | No Results | `/search` (empty state) | No helpers found |
| 9 | Helper Profile | `/helper/:id` | Full helper details + book button |
| 10 | Book Step 1 | `/book/:helperId/datetime` | Date + time + duration |
| 11 | Book Step 2 | `/book/:helperId/location` | Map pin + address |
| 12 | Book Step 3 | `/book/:helperId/task` | Task description + proposed price |
| 13 | Book Step 4 | `/book/:helperId/summary` | Review + send request |
| 14 | Awaiting Response | `/booking/:id/waiting` | 30-min countdown |
| 15 | Negotiation | `/booking/:id/negotiate` | Counter-offer review |
| 16 | Payment | `/booking/:id/payment` | Payment method + confirm |
| 17 | Booking Success | `/booking/:id/success` | Confirmation screen |
| 18 | Booking Tracking | `/booking/:id/track` | Status timeline view |
| 19 | Active Service | `/booking/:id/active` | Service in progress |
| 20 | Confirm Completion | `/booking/:id/confirm` | Did it go well? |
| 21 | Rate Helper | `/booking/:id/rate` | Stars + tags + comment |
| 22 | Chat | `/chat/:bookingId` | In-app messaging |
| 23 | Notifications | `/notifications` | Grouped notification list |
| 24 | Client Profile | `/client/profile` | Profile + menu |
| 25 | Medical Vault | `/vault` | Documents by category |
| 26 | Emergency Contacts | `/emergency-contacts` | Manage SOS contacts |
| 27 | No Internet | (overlay) | Retry connection |

### 6.2 Helper-Side Screens

| # | Screen | Route | Description |
|---|---|---|---|
| 28 | Helper Register Step 1 | `/register/helper/1` | Personal info |
| 29 | Helper Register Step 2 | `/register/helper/2` | Professional profile + specialties |
| 30 | Helper Register Step 3 | `/register/helper/3` | ID + selfie upload |
| 31 | Verification Pending | `/verification/pending` | Awaiting admin review |
| 32 | Helper Home | `/helper/home` | Incoming request + today's schedule |
| 33 | Incoming Request Detail | `/request/:id` | Request details + 30-min timer |
| 34 | Counter Offer | `/request/:id/counter` | Edit price + note |
| 35 | Helper Schedule | `/helper/schedule` | Weekly availability grid |
| 36 | Helper Earnings | `/helper/earnings` | Balance + chart + transactions |
| 37 | Helper Professional Profile | `/helper/profile` | Stats + settings |
| 38 | Helper Active Session | `/helper/active/:bookingId` | Active service view |

### 6.3 Admin Screens

| # | Screen | Route | Description |
|---|---|---|---|
| 39 | Admin Panel | `/admin` | Stats + pending verifications |

---

## 7. Core Business Logic

### 7.1 Registration Flow

**Client Registration:**
```
Enter name + phone + email + password
→ Select primary need type
→ Agree to terms
→ Create account (Firebase Auth)
→ Create Firestore user document (role: 'client')
→ Redirect to Client Home
```

**Helper Registration (3 steps):**
```
Step 1: name + email + phone + password
→ Step 2: photo + job title + about + specialties + service areas + hourly rate
→ Step 3: national ID front + back + selfie with ID
→ Submit for review
→ Account created but status = 'pending_verification'
→ Admin reviews and approves/rejects
→ On approval: FCM notification sent → status = 'verified'
```

### 7.2 Booking & Negotiation Flow

```
CLIENT                                    HELPER
  │                                         │
  ├── Selects date, time, duration          │
  ├── Pins location on map                  │
  ├── Writes task description               │
  ├── Sets proposed price/hour             │
  ├── Sends request ─────────────────────► │
  │                                         ├── Gets FCM notification
  │                                         ├── 30-min countdown starts
  │                                         │
  │              ┌──────────────────────────┤
  │              │    HELPER DECISION       │
  │              ├──────────────────────────┤
  │              │                          │
  │   ◄── Accept (instant confirm)          │
  │   ◄── Reject (request cancelled)        │
  │   ◄── Counter-offer (new price + note)  │
  │              │                          │
  ├── Reviews counter-offer                 │
  ├── Accept / Reject / Counter (round 2)   │
  │                                         │
  │   [MAX 2 ROUNDS — then auto-cancel]     │
  │                                         │
  ├── If agreement reached:                 │
  ├── Payment screen shown                  │
  ├── Client pays → funds go to Escrow      │
  ├── Booking status → 'confirmed' ────────►│
  │                                         ├── Gets FCM: "Booking confirmed!"
```

### 7.3 Auto State Transitions (Cloud Functions)

```javascript
// Cloud Function 1: Auto-start service (CRON — runs every minute)
// Trigger: booking.startTime <= now AND booking.status == 'confirmed'
// Action: booking.status = 'in_progress'
// FCM: both parties notified

// Cloud Function 2: Auto-end service (CRON — runs every minute)  
// Trigger: booking.endTime <= now AND booking.status == 'in_progress'
// Action: booking.status = 'confirming_completion'
// FCM: both parties notified — "Please confirm completion"

// Cloud Function 3: Auto-payout (runs 24h after confirming_completion)
// Trigger: booking.status == 'confirming_completion' AND now >= completionRequestedAt + 24h
// Action: 
//   - Calculate net = totalAmount * 0.85 (deduct 15% fee)
//   - Add net to helper's withdrawable balance
//   - booking.status = 'completed'
//   - FCM to both parties
```

### 7.4 Escrow & Payout Rules

| Scenario | Action |
|---|---|
| Both confirm ✅✅ | Instant payout to helper (85%) |
| Client confirms only ✅❌ | Instant payout to helper (85%) |
| Helper confirms only ❌✅ | Wait 24h → auto-payout if no dispute |
| Neither confirms ❌❌ | Freeze 24h → auto-payout if no dispute |
| Dispute opened | Freeze funds → Admin reviews manually |

**Fee Calculation:**
```
totalAmount = hourlyRate × durationHours
platformFee = totalAmount × 0.15
helperEarnings = totalAmount × 0.85
```

### 7.5 Schedule & Availability

- Helper sets available time slots per day
- Slots have 3 states: `available` | `booked` | `blocked`
- Booked slots auto-block when a booking is confirmed
- Client can only see available slots when booking

### 7.6 Negotiation Rounds Counter

```
round_1: Client sends offer → Helper counter-offers  [round = 1]
round_2: Client responds → Helper counter-offers     [round = 2]
round_3: Would be round 3 → AUTO CANCEL             ❌
```

### 7.7 Request Timeout (30 Minutes)

```
Client sends request → createdAt timestamp stored
Cloud Function checks every minute:
  IF (now - createdAt > 30min) AND status == 'pending'
  THEN status = 'expired'
       FCM to client: "لم يرد المساعد، ابحث عن شخص آخر"
```

---

## 8. Data Models

### 8.1 UserEntity (Domain)
```dart
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role;           // 'client' | 'helper' | 'admin'
  final String? profileImageUrl;
  final DateTime createdAt;
}
```

### 8.2 HelperEntity (Domain)
```dart
class HelperEntity extends Equatable {
  final String id;
  final String name;
  final String profileImageUrl;
  final double rating;
  final int reviewCount;
  final int completedTasksCount;
  final double distanceInKm;      // calculated at query time
  final bool isOnline;
  final double hourlyRate;
  final String aboutMe;
  final List<String> specialties; // e.g. ['mobility_assistance', 'elderly_care']
  final List<String> serviceAreas;
  final String verificationStatus; // 'pending' | 'verified' | 'rejected'
}
```

### 8.3 BookingEntity (Domain)
```dart
class BookingEntity extends Equatable {
  final String id;
  final String clientId;
  final String helperId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationHours;
  final GeoPoint location;
  final String locationAddress;
  final String taskDescription;
  final double proposedHourlyRate;
  final double? agreedHourlyRate;   // set after negotiation
  final double? totalAmount;
  final BookingStatus status;
  final int negotiationRound;       // 0, 1, or 2
  final String? helperNote;         // counter-offer note
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? completionRequestedAt;
  final bool clientConfirmed;
  final bool helperConfirmed;
}

enum BookingStatus {
  pending,
  negotiating,
  confirmed,
  inProgress,
  confirmingCompletion,
  completed,
  cancelled,
  expired,
  disputed,
}
```

### 8.4 ScheduleSlotEntity (Domain)
```dart
class ScheduleSlotEntity extends Equatable {
  final String id;
  final String helperId;
  final DateTime date;
  final String timeSlot;     // e.g. "09:00"
  final SlotStatus status;   // available | booked | blocked
  final String? bookingId;   // set if status is booked
}

enum SlotStatus { available, booked, blocked }
```

### 8.5 MedicalDocumentEntity (Domain)
```dart
class MedicalDocumentEntity extends Equatable {
  final String id;
  final String clientId;
  final String name;
  final String fileUrl;
  final String fileType;      // 'pdf' | 'image'
  final DocumentCategory category;
  final DateTime uploadedAt;
}

enum DocumentCategory { prescription, labResult, xray, other }
```

### 8.6 EmergencyContactEntity (Domain)
```dart
class EmergencyContactEntity extends Equatable {
  final String id;
  final String clientId;
  final String name;
  final String relation;     // e.g. 'ابن', 'ابنة'
  final String phone;
  final String? profileImageUrl;
  final bool isPrimary;
}
```

### 8.7 EarningsEntity (Domain)
```dart
class EarningsEntity extends Equatable {
  final double availableBalance;
  final double pendingBalance;
  final List<TransactionEntity> recentTransactions;
  final Map<String, double> weeklyData; // day → amount
}

class TransactionEntity extends Equatable {
  final String id;
  final String clientName;
  final double amount;
  final DateTime date;
  final TransactionStatus status; // cleared | processing
}
```

---

## 9. State Machine

```
                    ┌─────────┐
                    │ PENDING │ ◄── Client sends request
                    └────┬────┘
                         │ Helper responds within 30min
              ┌──────────┼──────────┐
              │          │          │
         ┌────▼───┐  ┌───▼──┐  ┌───▼──────┐
         │REJECTED│  │ACCEPT│  │NEGOTIATING│
         └────────┘  └───┬──┘  └─────┬────┘
                         │           │ Agreement reached
                         │      ┌────▼─────┐
                         │      │ Client   │
                         │      │  Pays    │
                         │      └────┬─────┘
                         └──────────▼
                            ┌──────────┐
                            │CONFIRMED │ ◄── Escrow holds funds
                            └────┬─────┘
                                 │ AUTO at startTime (Cloud Function)
                            ┌────▼──────┐
                            │IN_PROGRESS│
                            └────┬──────┘
                                 │ AUTO at endTime (Cloud Function)
                      ┌──────────▼──────────┐
                      │CONFIRMING_COMPLETION │
                      └──────────┬──────────┘
                                 │ Both confirm OR 24h timeout
                            ┌────▼──────┐
                            │ COMPLETED │ ◄── Helper receives 85%
                            └───────────┘

Special paths:
PENDING ──── expired (30min timeout, no helper response) ──►EXPIRED
ANY ──────── dispute opened ──────────────────────────────►DISPUTED
```

---

## 10. Firebase Schema

### Collection: `users`
```
users/{userId}
  - id: string
  - name: string
  - phone: string
  - email: string
  - role: 'client' | 'helper' | 'admin'
  - profileImageUrl: string?
  - createdAt: timestamp
  - fcmToken: string?
  
  // Client-only fields
  - primaryNeedType: string?
  - shareVaultWithHelper: boolean?
  
  // Helper-only fields
  - aboutMe: string?
  - hourlyRate: number?
  - specialties: array<string>?
  - serviceAreas: array<string>?
  - rating: number?
  - reviewCount: number?
  - completedTasksCount: number?
  - isOnline: boolean?
  - verificationStatus: 'pending' | 'verified' | 'rejected'?
  - idFrontUrl: string?
  - idBackUrl: string?
  - selfieWithIdUrl: string?
  - withdrawableBalance: number?
  - pendingBalance: number?
  - geoPoint: GeoPoint?     // last known location (set on app open)
```

### Collection: `bookings`
```
bookings/{bookingId}
  - id: string
  - clientId: string
  - helperId: string
  - startTime: timestamp
  - endTime: timestamp
  - durationHours: number
  - location: GeoPoint
  - locationAddress: string
  - taskDescription: string
  - proposedHourlyRate: number
  - agreedHourlyRate: number?
  - totalAmount: number?
  - status: BookingStatus (string)
  - negotiationRound: number (0-2)
  - helperNote: string?
  - createdAt: timestamp
  - confirmedAt: timestamp?
  - paidAt: timestamp?
  - completionRequestedAt: timestamp?
  - clientConfirmed: boolean
  - helperConfirmed: boolean
  - platformFee: number?
  - helperEarnings: number?
```

### Collection: `schedule_slots`
```
schedule_slots/{slotId}
  - id: string
  - helperId: string
  - date: string (YYYY-MM-DD)
  - timeSlot: string (HH:mm)
  - status: 'available' | 'booked' | 'blocked'
  - bookingId: string?
```

### Collection: `messages`
```
messages/{bookingId}/chats/{messageId}
  - id: string
  - senderId: string
  - content: string
  - type: 'text' | 'file'
  - fileUrl: string?
  - timestamp: timestamp
  - isRead: boolean
```

### Collection: `medical_documents`
```
medical_documents/{docId}
  - id: string
  - clientId: string
  - name: string
  - fileUrl: string
  - fileType: 'pdf' | 'image'
  - category: 'prescription' | 'lab_result' | 'xray' | 'other'
  - uploadedAt: timestamp
```

### Collection: `emergency_contacts`
```
emergency_contacts/{contactId}
  - id: string
  - clientId: string
  - name: string
  - relation: string
  - phone: string
  - profileImageUrl: string?
  - isPrimary: boolean
```

### Collection: `notifications`
```
notifications/{notificationId}
  - id: string
  - userId: string
  - title: string
  - body: string
  - type: 'booking_request' | 'booking_accepted' | 'payment_due' | 'service_started' | 'confirm_completion' | 'payment_received' | 'new_message' | 'verification_approved'
  - relatedId: string?   // bookingId or userId
  - isRead: boolean
  - createdAt: timestamp
```

### Collection: `verifications` (Admin use)
```
verifications/{verificationId}
  - id: string
  - helperId: string
  - helperName: string
  - helperPhone: string
  - specialties: array<string>
  - idFrontUrl: string
  - idBackUrl: string
  - selfieWithIdUrl: string
  - status: 'pending' | 'approved' | 'rejected'
  - submittedAt: timestamp
  - reviewedAt: timestamp?
  - reviewedBy: string?
  - rejectionReason: string?
```

---

## 11. Navigation Map

```
AppRouter (GoRouter)
│
├── /onboarding                    → OnboardingScreen
├── /role-select                   → RoleSelectionScreen
├── /login                         → LoginScreen
├── /register/client               → ClientRegisterScreen
├── /register/helper/:step         → HelperRegisterScreen (step 1,2,3)
├── /verification/pending          → VerificationPendingScreen
│
├── /client                        [Client Shell - bottom nav]
│   ├── /client/home               → ClientHomeScreen
│   ├── /client/profile            → ClientProfileScreen
│   ├── /vault                     → MedicalVaultScreen
│   └── /chat-list                 → ChatListScreen
│
├── /helper                        [Helper Shell - bottom nav]
│   ├── /helper/home               → HelperHomeScreen
│   ├── /helper/schedule           → HelperScheduleScreen
│   ├── /helper/earnings           → HelperEarningsScreen
│   └── /helper/profile            → HelperProfessionalProfileScreen
│
├── /admin                         → AdminVerificationScreen
│
├── /search                        → SearchResultsScreen
├── /helper/:id                    → HelperProfileScreen
│
├── /book/:helperId/datetime       → BookingStep1Screen
├── /book/:helperId/location       → BookingStep2Screen
├── /book/:helperId/task           → BookingStep3Screen
├── /book/:helperId/summary        → BookingStep4Screen
│
├── /booking/:id/waiting           → AwaitingResponseScreen
├── /booking/:id/negotiate         → NegotiationScreen
├── /booking/:id/payment           → PaymentScreen
├── /booking/:id/success           → BookingSuccessScreen
├── /booking/:id/track             → BookingTrackingScreen
├── /booking/:id/active            → ActiveServiceScreen
├── /booking/:id/confirm           → ConfirmCompletionScreen
├── /booking/:id/rate              → RateHelperScreen
│
├── /chat/:bookingId               → ChatScreen
├── /notifications                 → NotificationsScreen
├── /emergency-contacts            → EmergencyContactsScreen
└── /request/:id                   → IncomingRequestScreen (helper)
```

---

## 12. Design System

### 12.1 Colors
```dart
// app_colors.dart
class AppColors {
  // Primary
  static const Color primary = Color(0xFF1A3A6B);         // Deep navy blue
  static const Color primaryLight = Color(0xFFE8EDF5);    // Light navy bg
  
  // Secondary
  static const Color secondary = Color(0xFF00B5A3);       // Teal
  static const Color secondaryLight = Color(0xFFE0F7F5);  // Light teal bg
  
  // Background & Surface
  static const Color background = Color(0xFFF5F7FA);      // Screen bg
  static const Color surface = Color(0xFFFFFFFF);         // Card bg
  
  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  
  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color pending = Color(0xFFF59E0B);
  
  // SOS
  static const Color sos = Color(0xFFDC2626);
}
```

### 12.2 Typography
```dart
// Uses Arabic-compatible font (Cairo or Tajawal)
// Text sizes follow accessibility guidelines for elderly users
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const TextStyle heading2 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle heading3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const TextStyle body1   = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
  static const TextStyle body2   = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  static const TextStyle caption  = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);
  static const TextStyle button   = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
}
```

### 12.3 Spacing & Radius
```dart
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double button = 50;   // pill-shaped buttons
  static const double card = 12;
}
```

### 12.4 RTL Rules
- All layouts use `Directionality(textDirection: TextDirection.rtl)`
- Back arrows point RIGHT (→) not left
- Icons aligned to LEFT side of inputs (which visually appears on right in RTL)
- Navigation items: right-to-left order
- All strings in `app_strings.dart` in Arabic

### 12.5 Accessibility (Elderly-Focused)
- Minimum touch target: 48×48px (enforced via `SizedBox` wrapping)
- Font size: never below 14sp
- High contrast: text on buttons meets WCAG AA
- SOS button: always 64×64, floating, red, high visibility

---

## 13. Coding Standards

### 13.1 Naming Conventions
```
Files:       snake_case.dart
Classes:     PascalCase
Variables:   camelCase
Constants:   camelCase (in class) or UPPER_SNAKE (global)
Enums:       PascalCase (enum) + camelCase (values)
Routes:      /kebab-case
```

### 13.2 Cubit Pattern
```dart
// Every Cubit follows this exact pattern
class BookingFlowCubit extends Cubit<BookingFlowState> {
  final SendBookingRequestUseCase _sendBookingRequest;
  // Constructor receives use cases via injection — NO direct repo access

  BookingFlowCubit({required SendBookingRequestUseCase sendBookingRequest})
      : _sendBookingRequest = sendBookingRequest,
        super(const BookingFlowState.initial());

  Future<void> sendRequest(BookingRequestParams params) async {
    emit(state.copyWith(status: BookingFlowStatus.loading));
    final result = await _sendBookingRequest(params);
    result.fold(
      (failure) => emit(state.copyWith(
        status: BookingFlowStatus.error,
        errorMessage: failure.message,
      )),
      (booking) => emit(state.copyWith(
        status: BookingFlowStatus.success,
        booking: booking,
      )),
    );
  }
}
```

### 13.3 Error Handling
```dart
// Always use Either<Failure, T> in use cases and repositories
// Never throw raw exceptions from Domain layer

sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure { const NetworkFailure() : super('لا يوجد اتصال بالإنترنت'); }
class AuthFailure extends Failure { const AuthFailure(super.message); }
class BookingFailure extends Failure { const BookingFailure(super.message); }
class ServerFailure extends Failure { const ServerFailure() : super('حدث خطأ في الخادم، حاول مرة أخرى'); }
```

### 13.4 Constants File
```dart
// app_constants.dart — ALL magic numbers live here
class AppConstants {
  static const double platformFeePercentage = 0.15;    // 15%
  static const double helperEarningsPercentage = 0.85; // 85%
  static const int requestTimeoutMinutes = 30;
  static const int autoConfirmHours = 24;
  static const int maxNegotiationRounds = 2;
  static const int requestReminderMinutes = 20;        // Remind at 20min remaining
}
```

---

## 14. Progress Tracker

> Update this section as features are completed.
> 
> **Status Legend:** 🔴 Not Started | 🟡 In Progress | 🟢 Done | ⏸ Blocked

### Phase 1 — Project Setup
| Task | Status | Notes |
|---|---|---|
| Flutter project initialized | 🔴 | |
| Folder structure created | 🔴 | Follow Section 5 exactly |
| Firebase project connected | 🔴 | |
| GetIt DI setup | 🔴 | |
| GoRouter setup | 🔴 | |
| Design system (colors, text, spacing) | 🔴 | |
| Arabic RTL config | 🔴 | |
| Core widgets (button, text field, app bar) | 🔴 | |

### Phase 2 — Auth Feature
| Task | Status | Notes |
|---|---|---|
| Domain: UserEntity + AuthRepository | 🔴 | |
| Domain: Login / Register use cases | 🔴 | |
| Data: DummyAuthRepository | 🔴 | |
| Data: FirebaseAuthRepository | 🔴 | |
| Presentation: OnboardingScreen | 🔴 | |
| Presentation: RoleSelectionScreen | 🔴 | |
| Presentation: LoginScreen | 🔴 | |
| Presentation: ClientRegisterScreen | 🔴 | |
| Presentation: HelperRegisterScreen (3 steps) | 🔴 | |
| AuthCubit | 🔴 | |

### Phase 3 — Helper Discovery
| Task | Status | Notes |
|---|---|---|
| Domain: HelperEntity + HelperRepository | 🔴 | |
| Domain: GetHelpers / GetHelperProfile use cases | 🔴 | |
| Data: DummyHelperRepository | 🔴 | |
| Presentation: ClientHomeScreen | 🔴 | |
| Presentation: SearchResultsScreen (+ loading + empty) | 🔴 | |
| Presentation: HelperProfileScreen | 🔴 | |
| HelperDiscoveryCubit | 🔴 | |

### Phase 4 — Booking Flow
| Task | Status | Notes |
|---|---|---|
| Domain: BookingEntity + BookingRepository | 🔴 | |
| Domain: All Booking use cases | 🔴 | |
| Data: DummyBookingRepository | 🔴 | |
| Presentation: BookingStep1 (datetime) | 🔴 | |
| Presentation: BookingStep2 (location/map) | 🔴 | |
| Presentation: BookingStep3 (task + price) | 🔴 | |
| Presentation: BookingStep4 (summary) | 🔴 | |
| Presentation: AwaitingResponseScreen | 🔴 | |
| Presentation: NegotiationScreen | 🔴 | |
| Presentation: PaymentScreen | 🔴 | |
| Presentation: BookingSuccessScreen | 🔴 | |
| Presentation: BookingTrackingScreen | 🔴 | |
| Presentation: ActiveServiceScreen | 🔴 | |
| Presentation: ConfirmCompletionScreen | 🔴 | |
| Presentation: RateHelperScreen | 🔴 | |
| BookingFlowCubit | 🔴 | |
| BookingTrackingCubit | 🔴 | |

### Phase 5 — Helper Dashboard
| Task | Status | Notes |
|---|---|---|
| Domain: ScheduleSlot + Earnings entities | 🔴 | |
| Data: DummyHelperDashboardRepository | 🔴 | |
| Presentation: HelperHomeScreen | 🔴 | |
| Presentation: IncomingRequestScreen | 🔴 | |
| Presentation: CounterOfferScreen | 🔴 | |
| Presentation: HelperScheduleScreen | 🔴 | |
| Presentation: HelperEarningsScreen | 🔴 | |
| Presentation: HelperActiveSessionScreen | 🔴 | |
| HelperHomeCubit + ScheduleCubit + EarningsCubit | 🔴 | |

### Phase 6 — Profile, Vault, Emergency
| Task | Status | Notes |
|---|---|---|
| ClientProfileScreen | 🔴 | |
| HelperProfessionalProfileScreen | 🔴 | |
| MedicalVaultScreen | 🔴 | |
| EmergencyContactsScreen | 🔴 | |

### Phase 7 — Chat & Notifications
| Task | Status | Notes |
|---|---|---|
| ChatScreen | 🔴 | |
| NotificationsScreen | 🔴 | |
| FCM integration | 🔴 | |

### Phase 8 — Admin Panel
| Task | Status | Notes |
|---|---|---|
| AdminVerificationScreen | 🔴 | |
| Approve/Reject helper flow | 🔴 | |

### Phase 9 — Firebase Integration
| Task | Status | Notes |
|---|---|---|
| Switch all Dummy → Firebase repositories | 🔴 | |
| Firestore security rules | 🔴 | |
| Storage security rules | 🔴 | |
| Cloud Functions: auto-start (CRON) | 🔴 | |
| Cloud Functions: auto-end (CRON) | 🔴 | |
| Cloud Functions: auto-payout (24h) | 🔴 | |
| Cloud Functions: request-timeout (30min) | 🔴 | |
| Cloud Functions: FCM notifications | 🔴 | |

### Phase 10 — Testing & Launch
| Task | Status | Notes |
|---|---|---|
| Unit tests: use cases | 🔴 | |
| Widget tests: key screens | 🔴 | |
| Integration tests: booking flow | 🔴 | |
| Performance testing | 🔴 | |
| iOS TestFlight build | 🔴 | |
| Android Play Store build | 🔴 | |

---

## 15. Known Decisions & Rationale

| Decision | Reason |
|---|---|
| No live GPS tracking | Saves battery + resources. Google Maps used for pin only |
| Cloud Functions for state transitions | Guarantees timing accuracy. No client-side manipulation possible |
| 30-minute request timeout | Balances helper flexibility with client urgency |
| Max 2 negotiation rounds | Prevents endless back-and-forth. Encourages decisive pricing |
| 15% flat platform fee | Competitive with TaskRabbit (15%) while simpler than variable fees |
| 24h auto-payout window | Protects helper's earnings. Long enough for client dispute, short enough to not block helper |
| Escrow model | Protects both parties. Client's money is secured; helper knows payment is guaranteed |
| Dummy repositories first | Enables parallel UI/Backend development. Fast iteration |
| Arabic-only UI | Primary target market is Saudi Arabia (seen from Riyadh references in screens) |
| GetIt over Provider for DI | More suitable for large feature-based architectures |
| GoRouter over Navigator 2.0 | Declarative routing, better deep-link support, cleaner code |
| Freezed for state classes | Immutability + copyWith + equality out of the box |
| feature-based folders over layer-based | Easier to scale. Each feature is independently owned |

---

> 📌 **For AI Tools:** When generating code for this project:
> 1. Always check which feature you're working in (Section 5)
> 2. Respect layer boundaries (Section 4)
> 3. Use the exact entity fields from Section 8
> 4. Follow the booking state machine from Section 9
> 5. Use Arabic strings — never English in UI
> 6. Use `AppColors`, `AppTextStyles`, `AppSpacing` — never hardcode values
> 7. Always return `Either<Failure, T>` from repositories and use cases
> 8. Update Section 14 progress tracker when completing tasks
