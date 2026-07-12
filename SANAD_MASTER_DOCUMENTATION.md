# 📘 SANAD (سند) — Master Project Documentation

> **Version:** 1.0.0 | **Last Updated:** 2026-07-12 | **Status:** 🟢 Complete (Final Submission)
>
> ⚠️ **AI TOOL INSTRUCTION:** Read this entire file before generating any code, suggestion, or review.
> This is the single source of truth for the Sanad project. Never contradict or bypass these rules.
>
> 📌 **SYNC NOTE:** This document was fully audited and rewritten on 2026-07-12 to strictly reflect
> the implemented codebase, as verified against CHANGELOG.md. All unimplemented or removed
> features have been eliminated from this document.

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
9. [Booking State Machine](#9-booking-state-machine)
10. [Firebase Schema](#10-firebase-schema)
11. [Navigation Map](#11-navigation-map)
12. [Design System](#12-design-system)
13. [Coding Standards](#13-coding-standards)
14. [Implementation Summary](#14-implementation-summary)
15. [Known Decisions & Rationale](#15-known-decisions--rationale)

---

## 1. Project Overview

| Field | Value |
|---|---|
| **App Name** | سند (Sanad) |
| **Category** | Gig Economy / Social Assistance |
| **Concept** | Connects people needing daily help (elderly, mobility/visual impairment) with verified ordinary helpers for an agreed hourly rate |
| **Type** | Strictly NON-Medical. Helpers are NOT doctors or nurses |
| **Platforms** | Android (Flutter) — primary target |
| **Language** | Arabic (RTL — Right to Left) |
| **Monetization** | 15% flat commission per completed transaction |

### What Sanad is NOT:
- ❌ NOT a medical app
- ❌ NOT a telemedicine platform
- ❌ NOT a delivery app
- ❌ NOT using live GPS map tracking
- ❌ NOT using Firebase Cloud Functions for state transitions (not implemented)
- ❌ NOT using Firebase Storage for image uploads (migrated to ImgBB API)
- ❌ NOT a wallet/payment gateway integration (payment flow is status-based within the app)

### What Sanad IS:
- ✅ A task-helper marketplace (like TaskRabbit but for social assistance)
- ✅ A time-based booking platform with a negotiation workflow
- ✅ A verified helper network for vulnerable individuals
- ✅ A status-driven progress tracker (automated status transitions managed in-app)
- ✅ A session-based real-time chat (only active during an ongoing booking)

---

## 2. User Roles

### 2.1 Client (العميل / محتاج المساعدة)
A person who needs daily assistance.

**Can:**
- Browse and search helpers by specialty category
- View detailed helper profiles with ratings and reviews
- Send booking requests with date, time, duration, and task description
- Negotiate price via counter-offers
- Trigger payment to start service (confirmed → inProgress)
- Track booking status in real time from the Bookings screen
- Chat with a helper during an active booking (accessed from Booking Details)
- Confirm service completion
- Rate and review the helper after completion
- Manage emergency contacts
- View in-app notifications history

**Not Implemented (removed):**
- ❌ Medical Vault (الخزانة الطبية) — removed in Task 102
- ❌ Viewing a live map/GPS location of the helper

### 2.2 Helper (المساعد / مقدم المساعدة)
A verified ordinary person who provides assistance for an hourly rate.

**Can:**
- Register with full profile (bio, specialties, hourly rate) and upload verification documents
- Await admin approval after registration (verification pending screen with real-time redirect)
- View incoming booking requests on the Helper Home screen
- Accept / Reject / Counter-offer booking requests
- View all assigned bookings (new, active, history) in the Helper Bookings screen
- Access Booking Details and confirm completion
- Chat with a client during an active booking
- View their profile with completed tasks count and rating

**Not Implemented:**
- ❌ Schedule/availability management screen
- ❌ Earnings/withdrawal screen

### 2.3 Admin (الأدمن)
Internal Sanad team member.

**Can:**
- Access the Admin Dashboard via a role-based button on the Profile Screen
- View all pending helper verification requests
- View helper details including uploaded identity documents via CachedNetworkImage
- Approve or Reject helper applications
- Monitor all platform bookings (active, pending, history tabs)
- View all registered users split by role (Clients / Helpers tabs)

---

## 3. Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Frontend** | Flutter (latest stable) | Android UI |
| **Auth** | Firebase Authentication | Email/password login, password reset |
| **Database** | Cloud Firestore | Real-time data, user profiles, bookings, chats, notifications |
| **Image Upload** | ImgBB API (HTTP) | Profile pictures and helper verification documents |
| **Notifications (Push)** | Firebase Cloud Messaging (FCM) | Push notifications for booking events and chat |
| **Notification Backend** | Custom Node.js server (Vercel) | FCM dispatch without Firebase Blaze plan |
| **Local Notifications** | flutter_local_notifications | On-device notification display |
| **State Management** | Flutter Bloc / Cubit | UI state management |
| **DI** | GetIt | Dependency injection |
| **Navigation** | GoRouter | Declarative routing with auth-gated redirects |

> **Note on Firebase Storage:** Originally planned but migrated to ImgBB API (Task 97) to avoid Firebase Storage billing requirements.

> **Note on Cloud Functions:** Not implemented. State transitions are triggered by explicit user actions in the app, not automated CRON jobs.

> **Note on Maps:** Google Maps is NOT used. No live GPS tracking exists. Location is captured as a text description entered by the client during booking.

### 3.1 Key Packages (pubspec.yaml)
```yaml
dependencies:
  flutter_bloc: ^8.x
  get_it: ^7.x
  go_router: ^13.x
  firebase_core: ^3.x
  firebase_auth: ^5.x
  cloud_firestore: ^5.x
  firebase_messaging: ^15.x
  flutter_local_notifications: ^18.x
  dartz: ^0.10.x          # Functional programming (Either type)
  equatable: ^2.x          # Value equality
  intl: ^0.19.x            # Arabic date/number formatting
  cached_network_image: ^3.x
  image_picker: ^1.x
  http: ^1.x               # ImgBB API uploads
  flutter_localizations:    # Arabic RTL support
```

---

## 4. Architecture Rules

### CRITICAL — These rules MUST NEVER be violated

```
PRESENTATION LAYER
  (Screens, Widgets, Cubits)
  - Flutter UI + Cubits
  - NO Firebase imports
  - NO direct data calls
       |
       | calls UseCases only
       v
DOMAIN LAYER
  (Entities, Abstract Repos, UseCases)
  - Pure Dart ONLY
  - NO Firebase, NO Flutter UI, NO http, NO external packages
       |
       | implemented by
       v
DATA LAYER
  (Firebase Repos, Models, DataSources)
  - Firebase + API calls (ImgBB, FCM)
  - fromJson / toJson / fromFirestore
```

### 4.1 Layer Responsibilities

**Domain Layer (lib/features/X/domain/)**
- `entities/` — Pure Dart classes. No fromJson. No Firebase.
- `repositories/` — Abstract interfaces (contracts). Never implemented here.
- `usecases/` — Single-responsibility business operations.

**Data Layer (lib/features/X/data/)**
- `models/` — Extend entities. Add fromJson/toJson/fromFirestore.
- `repositories/` — Implement domain abstract repos.
- `datasources/` — Firebase/API calls (remote).

**Presentation Layer (lib/features/X/presentation/)**
- `screens/` — Full page widgets.
- `widgets/` — Reusable UI components for this feature.
- `cubit/` — State + business presentation logic.

### 4.2 UseCase Pattern
Every use case takes one input, returns `Either<Failure, T>`.

```dart
class SendBookingRequestUseCase {
  final BookingRepository repository;
  SendBookingRequestUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call(BookingRequestParams params) {
    return repository.sendBookingRequest(params);
  }
}
```

### 4.3 Dependency Injection
All dependencies are registered in `injection_container.dart` using GetIt.
Firebase implementations are injected directly — no dummy repositories remain in production.

---

## 5. Folder Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_strings.dart          # All Arabic strings (centralized — Task 112)
│   │   ├── app_assets.dart
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── usecases/
│   │   └── usecase.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   └── validators.dart
│   ├── widgets/
│   │   └── (shared UI components)
│   └── router/
│       ├── app_router.dart           # GoRouter config with auth-gated redirects
│       └── app_routes.dart           # Route name constants
│
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/user_entity.dart
│   │   │   ├── repositories/auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_client_usecase.dart
│   │   │       ├── register_helper_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── upload_profile_image_usecase.dart
│   │   ├── data/
│   │   │   ├── models/user_model.dart
│   │   │   ├── datasources/auth_remote_datasource.dart
│   │   │   └── repositories/firebase_auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── onboarding_screen.dart
│   │       │   ├── role_selection_screen.dart
│   │       │   ├── login_screen.dart
│   │       │   ├── client_register_screen.dart
│   │       │   ├── helper_register_screen.dart     # 3 steps in one screen
│   │       │   ├── verification_pending_screen.dart
│   │       │   ├── forgot_password_screen.dart
│   │       │   └── change_password_screen.dart
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
│   │   │       ├── get_helper_profile_usecase.dart
│   │   │       └── submit_review_usecase.dart
│   │   ├── data/
│   │   │   ├── models/helper_model.dart
│   │   │   ├── datasources/helper_remote_datasource.dart
│   │   │   └── repositories/firebase_helper_repository_impl.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── client_home_screen.dart
│   │       │   ├── search_results_screen.dart
│   │       │   └── helper_profile_screen.dart
│   │       └── cubit/
│   │           ├── helper_discovery_cubit.dart
│   │           └── helper_discovery_state.dart
│   │
│   ├── booking/
│   │   ├── domain/
│   │   │   ├── entities/booking_entity.dart
│   │   │   ├── repositories/booking_repository.dart
│   │   │   └── usecases/
│   │   │       ├── send_booking_request_usecase.dart
│   │   │       ├── accept_booking_usecase.dart
│   │   │       ├── reject_booking_usecase.dart
│   │   │       ├── counter_offer_usecase.dart
│   │   │       ├── pay_booking_usecase.dart
│   │   │       ├── confirm_completion_usecase.dart
│   │   │       ├── get_booking_stream_usecase.dart
│   │   │       ├── get_client_bookings_usecase.dart
│   │   │       ├── get_helper_bookings_usecase.dart
│   │   │       └── track_booking_usecase.dart
│   │   ├── data/
│   │   │   ├── models/booking_model.dart
│   │   │   ├── datasources/booking_remote_datasource.dart
│   │   │   └── repositories/firebase_booking_repository_impl.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── send_booking_request_screen.dart  # Date/time/task/price form
│   │       │   ├── booking_details_screen.dart       # Central screen for all status actions
│   │       │   ├── client_bookings_screen.dart       # Client: Active & History tabs
│   │       │   ├── helper_bookings_screen.dart       # Helper: New, Active, History tabs
│   │       │   └── rating_screen.dart                # 5-star + written review
│   │       └── cubit/
│   │           ├── booking_cubit.dart
│   │           ├── booking_state.dart
│   │           ├── client_bookings_cubit.dart
│   │           ├── client_bookings_state.dart
│   │           ├── helper_bookings_cubit.dart
│   │           └── helper_bookings_state.dart
│   │
│   ├── helper_dashboard/
│   │   └── presentation/
│   │       └── screens/
│   │           └── helper_home_screen.dart           # Incoming requests list
│   │
│   ├── chat/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── message_entity.dart
│   │   │   │   └── chat_entity.dart
│   │   │   ├── repositories/chat_repository.dart
│   │   │   └── usecases/
│   │   │       ├── send_message_usecase.dart
│   │   │       ├── get_chat_messages_usecase.dart
│   │   │       ├── get_chat_stream_usecase.dart
│   │   │       ├── get_my_chats_usecase.dart
│   │   │       └── mark_messages_as_read_usecase.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── message_model.dart
│   │   │   │   └── chat_model.dart
│   │   │   ├── datasources/chat_remote_datasource.dart
│   │   │   └── repositories/firebase_chat_repository_impl.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── chat_room_screen.dart             # Real-time messaging UI
│   │       │   └── chat_list_screen.dart             # Exists but NOT in nav (removed Task 110)
│   │       └── cubit/
│   │           ├── chat_room_cubit.dart
│   │           └── chat_list_cubit.dart
│   │
│   ├── notifications/
│   │   └── presentation/
│   │       └── screens/
│   │           └── notifications_screen.dart
│   │
│   ├── emergency/
│   │   └── presentation/
│   │       └── screens/
│   │           └── emergency_contacts_screen.dart
│   │
│   └── admin/
│       ├── domain/
│       │   ├── repositories/admin_repository.dart
│       │   └── usecases/
│       │       ├── get_users_usecase.dart
│       │       ├── get_all_bookings_usecase.dart
│       │       ├── approve_helper_usecase.dart
│       │       └── reject_helper_usecase.dart
│       ├── data/
│       │   ├── datasources/admin_remote_datasource.dart
│       │   └── repositories/firebase_admin_repository_impl.dart
│       └── presentation/
│           ├── screens/
│           │   ├── admin_shell_screen.dart
│           │   ├── admin_dashboard_screen.dart
│           │   ├── admin_users_screen.dart
│           │   ├── admin_bookings_screen.dart
│           │   └── admin_helper_details_screen.dart
│           └── cubit/
│               ├── admin_cubit.dart
│               ├── admin_users_cubit.dart
│               └── admin_bookings_cubit.dart
│
├── injection_container.dart
└── main.dart
```

> **Removed (not in codebase):**
> - `medical_vault/` — completely removed (Task 102)
> - Schedule/Earnings domain+data layers — not built
> - Dummy repository files — replaced by Firebase implementations

---

## 6. Features & Screens

### 6.1 Auth Screens

| # | Screen | Route | Description |
|---|---|---|---|
| 1 | Onboarding | `/onboarding` | Intro slides carousel |
| 2 | Role Selection | `/role-select` | I need help / I want to help |
| 3 | Client Register | `/register-client` | Name, phone, email, password, need type |
| 4 | Helper Register | `/register-helper` | 3-step: personal info → specialties/rate → ID upload |
| 5 | Login | `/login` | Email + password |
| 6 | Forgot Password | `/forgot-password` | Firebase password reset email |
| 7 | Verification Pending | `/verification-pending` | Awaiting admin approval (real-time redirect on approval) |
| 8 | Change Password | `/change-password` | Re-auth + new password |

### 6.2 Client Screens

| # | Screen | Route | Description |
|---|---|---|---|
| 9 | Client Home | `/client-home` | Service categories + helper cards |
| 10 | Search Results | `/search` | Filtered helper list with rating/specialty |
| 11 | Helper Profile | `/helper-detail` | Full helper details, rating, reviews, book button |
| 12 | Send Booking Request | `/book-datetime` | Date, time, duration, task description, proposed price |
| 13 | Client Bookings | `/client-bookings` | Active & History tabs (real-time stream) |
| 14 | Booking Details | `/booking-track` | Central status-action screen (all booking states) |
| 15 | Rate Helper | `/booking-rate` | 5-star + optional written review |
| 16 | Notifications | `/notifications` | In-app notification history |
| 17 | Emergency Contacts | `/emergency-contacts` | Manage SOS contacts |
| 18 | Client Profile | `/client-profile` | Profile info, name edit, navigation hub |

### 6.3 Helper Screens

| # | Screen | Route | Description |
|---|---|---|---|
| 19 | Helper Home | `/helper-home` | Incoming booking requests list |
| 20 | Helper Bookings | `/helper-bookings` | New / Active / History tabs (real-time stream) |
| 21 | Booking Details | `/booking-track` | Shared with client — role-based action buttons |
| 22 | Helper Profile | `/helper-profile` | Stats, rating, completed tasks count |

### 6.4 Chat Screen (Session-Based)

| # | Screen | Route | Description |
|---|---|---|---|
| 23 | Chat Room | `/chat` | Real-time messaging; accessed from Booking Details |

> **IMPORTANT — Session-Based Chat:** Chat is accessible via a button on `BookingDetailsScreen`,
> visible only when booking status is `confirmed`, `inProgress`, or `confirmingCompletion`.
> There is **no global Chat tab** in the bottom navigation bar (removed Task 110).

### 6.5 Admin Screens

| # | Screen | Route | Description |
|---|---|---|---|
| 24 | Admin Dashboard | `/admin/dashboard` | Welcome banner + quick-access cards |
| 25 | Admin Users | `/admin/users` | Clients & Helpers tabs; approve pending helpers |
| 26 | Admin Helper Details | (pushed from Users) | Documents viewer + Approve/Reject buttons |
| 27 | Admin Bookings | `/admin/bookings` | Active / Pending / History monitoring |

---

## 7. Core Business Logic

### 7.1 Registration Flow

**Client Registration:**
```
Enter name + phone + email + password + need type
→ Firebase Auth: createUserWithEmailAndPassword
→ Firestore: create user document (role: 'client')
→ Redirect to Client Home (GoRouter auth gate)
```

**Helper Registration (3-step, single screen flow):**
```
Step 1: name + email + phone + password
Step 2: profile photo + bio + specialties + hourly rate
Step 3: national ID front + back + selfie with ID
→ Upload documents to ImgBB API → store URLs in memory
→ Firebase Auth: createUserWithEmailAndPassword
→ Firestore: create user document (role: 'helper', verificationStatus: 'pending')
→ GoRouter gate: redirect to /verification-pending
→ Admin reviews and approves/rejects
→ On approval: Firestore verificationStatus → 'approved'
→ Real-time Firestore stream in AuthCubit detects change
→ Router automatically redirects helper to /helper-home
```

### 7.2 Booking & Negotiation Flow

```
CLIENT                                    HELPER
  |                                         |
  |-- Selects date, time, duration          |
  |-- Writes task description               |
  |-- Sets proposed price/hour             |
  |-- Sends request ----------------------->| (FCM push notification)
  |                                         |
  |         HELPER DECISION                 |
  |<-- Accept --> status: 'confirmed'       |
  |<-- Reject --> status: 'cancelled'       |
  |<-- Counter-offer --> status: 'negotiating'
  |         (proposedHourlyRate updated)    |
  |                                         |
  |-- Reviews counter-offer                 |
  |-- Accept --> client triggers 'Pay'      |
  |-- Reject --> status: 'cancelled'        |
  |                                         |
  |   [Pay & Start Service button]          |
  |-- BookingCubit.pay() called             |
  |-- Validation: agreedPrice > 0           |
  |-- status --> 'inProgress' ------------>| (FCM notification)
  |                                         |
  |   [Service in progress — no GPS tracking]
  |                                         |
  |-- Helper: Confirm Completion            |
  |-- status --> 'confirmingCompletion'     |
  |                                         |
  |-- Client: Confirm Completion            |
  |-- Firestore: completedTasksCount++      |
  |-- Firestore: rating recalculated        |
  |-- status --> 'completed' ------------->|
  |                                         |
  |-- Rate Helper screen unlocked           |
```

> **Note on Payment:** There is no external payment gateway. The "Pay & Start Service" button
> is a status transition action — it moves the booking from `confirmed` to `inProgress`.

### 7.3 Status-Triggered Progress Tracking

Progress tracking is **status-based**, not map/GPS based. The `BookingDetailsScreen` listens to a real-time Firestore stream of the booking document and updates the UI for every status change.

```
pending              → Helper: Accept / Reject / Counter-offer
                       Client: Cancel Request

negotiating          → Client: Accept Offer / Reject Offer + proposed price
                       Helper: Waiting for client

confirmed            → Client: Pay & Start Service
                       Helper: Waiting for client to pay

inProgress           → Helper: Confirm Completion
                       Client: Service in progress (informational)

confirmingCompletion → Client: Confirm Completion
                       Helper: Waiting for client

completed            → Both: No action buttons
                       Client: Rate Helper button shown

cancelled/rejected   → Both: No action buttons (terminal state)
```

### 7.4 Session-Based Chat

Chat is only accessible during an active booking. The `Chat` button appears on `BookingDetailsScreen` exclusively when `status ∈ {confirmed, inProgress, confirmingCompletion, disputed}`.

- Chat messages stored in Firestore: `chats/{chatId}/messages/{messageId}`
- Parent `chats/{chatId}` document holds metadata: `clientId`, `helperId`, `bookingId`, `clientName`, `helperName`, `lastMessage`, `updatedAt`, `unreadCount`
- Sending a message auto-upserts the parent chat document (using `SetOptions(merge: true)`)
- Push notification sent to the other party via the Node.js/Vercel FCM backend
- Tapping a chat push notification deep-links directly to the `ChatRoomScreen`
- AppBar title resolved dynamically via `FutureBuilder` (Firestore lookup by UID)

### 7.5 Helper Verification & Admin Approval

```
Helper registers → verificationStatus: 'pending' in Firestore
GoRouter redirect checks verificationStatus on every navigation:
  IF verificationStatus == 'pending' → redirect to /verification-pending
  IF verificationStatus == 'approved' → allow access to /helper-home

Admin:
  → Admin Dashboard → Users → Helpers tab
  → Views pending helpers (yellow badge)
  → Taps helper → views documents (admin_helper_details_screen.dart)
  → Approves: AdminCubit.verifyHelper(uid) → writes verificationStatus: 'approved'
  → Rejects: writes verificationStatus: 'rejected'

Helper app:
  → AuthCubit listens to watchCurrentUser() Firestore stream
  → On verificationStatus change → emits new AuthState
  → Router detects change → redirects to /helper-home automatically
```

### 7.6 Push Notification System

- **Backend:** Custom Node.js server on Vercel (`https://sanad-nine-nu.vercel.app`) using Firebase Admin SDK — avoids Blaze plan requirement
- **Flutter service:** `NotificationSenderService` calls the Vercel endpoint via `http` package
- **FCM token sync:** `AuthCubit` syncs FCM token to Firestore on successful login
- **Triggers:** booking creation, status changes (accept/reject/pay/complete), new chat messages
- **Deep linking:** Tapping a chat notification navigates to the correct `ChatRoomScreen`
- **Android icon:** Custom XML Vector Drawable (`ic_notification` — heart shape)

### 7.7 Ratings & Reviews

- After `completed` status, client can navigate to `RatingScreen` (5-star + optional text)
- On submit, `SubmitReviewUseCase` atomically:
  - Writes the review to Firestore with `clientName` resolved at write time
  - Recalculates helper's aggregate `rating` and increments `reviewCount`
  - Marks booking as rated (`isRated: true`)
- `HelperProfileScreen` displays reviews in a real-time `StreamBuilder` list
- Unrated helpers display "جديد" (New) instead of a rating number

---

## 8. Data Models

### 8.1 UserEntity (Domain)
```dart
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role;                // 'client' | 'helper' | 'admin'
  final String? profileImageUrl;
  final String? fcmToken;
  final DateTime createdAt;

  // Helper-only fields
  final String? verificationStatus; // 'pending' | 'approved' | 'rejected'
  final String? idFrontUrl;
  final String? idBackUrl;
  final String? selfieUrl;
  final double? hourlyRate;
  final List<String>? specialties;
  final double? rating;
  final int? reviewCount;
  final int? completedTasksCount;
}
```

### 8.2 HelperEntity (Domain)
```dart
class HelperEntity extends Equatable {
  final String id;
  final String name;
  final String? profileImageUrl;
  final double rating;
  final int reviewCount;
  final int completedTasksCount;
  final double hourlyRate;
  final String? aboutMe;
  final List<String> specialties;
  final String verificationStatus;  // 'pending' | 'approved' | 'rejected'
}
```

### 8.3 BookingEntity (Domain)
```dart
class BookingEntity extends Equatable {
  final String id;
  final String clientId;
  final String helperId;
  final String clientName;
  final String helperName;
  final DateTime startTime;
  final DateTime endTime;
  final int durationHours;
  final String taskDescription;
  final double proposedHourlyRate;
  final double? agreedPrice;         // validated > 0 before pay transition
  final double? totalAmount;
  final BookingStatus status;
  final int negotiationRound;
  final String? helperNote;
  final DateTime createdAt;
  final bool clientConfirmed;
  final bool helperConfirmed;
  final bool isRated;
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

### 8.4 ChatEntity (Domain)
```dart
class ChatEntity extends Equatable {
  final String id;
  final String bookingId;
  final String clientId;
  final String helperId;
  final String? clientName;
  final String? helperName;
  final String? lastMessage;
  final DateTime? updatedAt;
  final int unreadCount;
}
```

### 8.5 MessageEntity (Domain)
```dart
class MessageEntity extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
}
```

### 8.6 EmergencyContactEntity (Domain)
```dart
class EmergencyContactEntity extends Equatable {
  final String id;
  final String clientId;
  final String name;
  final String relation;
  final String phone;
  final bool isPrimary;
}
```

> **Removed entities:** `MedicalDocumentEntity`, `ScheduleSlotEntity`, `EarningsEntity` — their features were removed or not built.

---

## 9. Booking State Machine

```
                    +---------+
                    | PENDING | <-- Client sends request (FCM -> helper)
                    +----+----+
                         | Helper responds
              +----------+-----------+
              |           |           |
         +----+----+      |      +----+-------+
         |REJECTED |      |      |NEGOTIATING |
         |(cancel) |      |      +-----+------+
         +---------+      |            | Client accepts offer
                          |      +-----+------+
                          |      | Client     |
                          |      | Accepts    |
                          |      +-----+------+
                          +------------+
                                       |
                               +-------+----+
                               | CONFIRMED  | <-- Client taps "Pay & Start Service"
                               +------+-----+     BookingCubit.pay() validates agreedPrice > 0
                                      |
                               +------+-----+
                               |IN_PROGRESS | <-- FCM to both parties
                               +------+-----+
                                      | Helper taps "Confirm Completion"
                          +-----------+-----------+
                          | CONFIRMING_COMPLETION |
                          +-----------+-----------+
                                      | Client taps "Confirm Completion"
                                      | (atomically: completedTasksCount++, rating recalc)
                               +------+-----+
                               | COMPLETED  | <-- Rate Helper button unlocked for client
                               +------------+

Special paths:
PENDING ---> cancelled (manual cancel or reject)
ANY -------> DISPUTED (not fully implemented)
```

> **State transition responsibility:** All transitions triggered by explicit user actions in
> `BookingDetailsScreen` via `BookingCubit`. No Firebase Cloud Functions or CRON jobs.

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
  - profileImageUrl: string?          # ImgBB URL
  - fcmToken: string?
  - createdAt: timestamp

  // Helper-only fields
  - aboutMe: string?
  - hourlyRate: number?
  - specialties: array<string>?
  - rating: number?
  - reviewCount: number?
  - completedTasksCount: number?
  - verificationStatus: 'pending' | 'approved' | 'rejected'?
  - idFrontUrl: string?               # ImgBB URL
  - idBackUrl: string?                # ImgBB URL
  - selfieUrl: string?                # ImgBB URL
```

### Collection: `bookings`
```
bookings/{bookingId}
  - id: string
  - clientId: string
  - helperId: string
  - clientName: string
  - helperName: string
  - startTime: timestamp
  - endTime: timestamp
  - durationHours: number
  - taskDescription: string
  - proposedHourlyRate: number
  - agreedPrice: number?
  - totalAmount: number?
  - status: string (BookingStatus)
  - negotiationRound: number
  - helperNote: string?
  - createdAt: timestamp
  - clientConfirmed: boolean
  - helperConfirmed: boolean
  - isRated: boolean
```

### Collection: `chats`
```
chats/{chatId}
  - id: string
  - bookingId: string
  - clientId: string
  - helperId: string
  - clientName: string?
  - helperName: string?
  - lastMessage: string?
  - updatedAt: timestamp?
  - unreadCount: number

chats/{chatId}/messages/{messageId}
  - id: string
  - chatId: string
  - senderId: string
  - content: string
  - timestamp: timestamp
  - isRead: boolean
```

### Collection: `notifications`
```
notifications/{notificationId}
  - id: string
  - userId: string
  - title: string
  - body: string
  - type: string
  - relatedId: string?
  - isRead: boolean
  - createdAt: timestamp
```

### Collection: `emergency_contacts`
```
emergency_contacts/{contactId}
  - id: string
  - clientId: string
  - name: string
  - relation: string
  - phone: string
  - isPrimary: boolean
```

> **Removed collections:** `medical_documents`, `schedule_slots` — not implemented.
> Helper verification documents are stored as fields directly on the `users` document.

---

## 11. Navigation Map

```
AppRouter (GoRouter) — Auth-Gated with redirect logic

/                              --> SplashScreen (auth check)
/onboarding                    --> OnboardingScreen
/role-select                   --> RoleSelectionScreen
/login                         --> LoginScreen
/forgot-password               --> ForgotPasswordScreen
/register-client               --> ClientRegisterScreen
/register-helper               --> HelperRegisterScreen (3-step)
/verification-pending          --> VerificationPendingScreen

/client [Client Shell — 3 tabs: Home | Bookings | Profile]
  /client-home                 --> ClientHomeScreen
  /client-bookings             --> ClientBookingsScreen
  /client-profile              --> ClientProfileScreen

/helper [Helper Shell — 3 tabs: Home | Bookings | Profile]
  /helper-home                 --> HelperHomeScreen
  /helper-bookings             --> HelperBookingsScreen
  /helper-profile              --> HelperProfileScreen

/admin [Admin Shell — 3 tabs: Dashboard | Users | Bookings]
  /admin/dashboard             --> AdminDashboardScreen
  /admin/users                 --> AdminUsersScreen
    /admin/helper-details      --> AdminHelperDetailsScreen (pushed)
  /admin/bookings              --> AdminBookingsScreen

/search                        --> SearchResultsScreen
/helper-detail                 --> HelperProfileScreen
/book-datetime                 --> SendBookingRequestScreen
/booking-track/:id             --> BookingDetailsScreen (all states)
/booking-rate/:id              --> RatingScreen
/chat                          --> ChatRoomScreen (deep-linkable)
/notifications                 --> NotificationsScreen
/emergency-contacts            --> EmergencyContactsScreen
/change-password               --> ChangePasswordScreen
```

> **Removed routes:** `/vault`, `/chat-list` (global chat tab removed Task 110),
> `/helper-schedule`, `/helper-earnings`, multi-step `/book/:id/location`, `/book/:id/task`,
> `/book/:id/summary` — consolidated into a single booking request screen or removed.

---

## 12. Design System

### 12.1 Colors
```dart
class AppColors {
  static const Color primary = Color(0xFF1A3A6B);         // Deep navy blue
  static const Color primaryLight = Color(0xFFE8EDF5);
  static const Color secondary = Color(0xFF00B5A3);       // Teal
  static const Color secondaryLight = Color(0xFFE0F7F5);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color pending = Color(0xFFF59E0B);
}
```

### 12.2 Typography
```dart
// Arabic-compatible fonts (Cairo / Tajawal)
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
  static const double button = 50;
  static const double card = 12;
}
```

### 12.4 RTL Rules
- All layouts use Arabic RTL (`textDirection: TextDirection.rtl`)
- All UI strings in Arabic, centralized in `AppStrings` class
- Navigation items follow right-to-left reading order

### 12.5 Branding
- App logo integrated on Splash and Auth screens
- Custom launcher icon set via `flutter_launcher_icons`
- Custom Android notification icon: XML Vector Drawable (`ic_notification` — heart shape)

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
class BookingCubit extends Cubit<BookingState> {
  final AcceptBookingUseCase _acceptBooking;

  BookingCubit({required AcceptBookingUseCase acceptBooking, ...})
      : _acceptBooking = acceptBooking,
        super(const BookingState.initial());

  Future<void> accept(String bookingId, double agreedPrice) async {
    if (agreedPrice <= 0) {
      emit(state.copyWith(errorMessage: 'السعر غير صالح'));
      return;
    }
    emit(state.copyWith(isLoading: true));
    final result = await _acceptBooking(AcceptBookingParams(bookingId, agreedPrice));
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(isSuccess: true)),
    );
  }
}
```

### 13.3 Error Handling
```dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure { const NetworkFailure() : super('لا يوجد اتصال بالإنترنت'); }
class AuthFailure extends Failure { const AuthFailure(super.message); }
class BookingFailure extends Failure { const BookingFailure(super.message); }
class ServerFailure extends Failure { const ServerFailure() : super('حدث خطأ في الخادم، حاول مرة أخرى'); }
```

### 13.4 String Centralization
All Arabic UI text and validation messages are in `AppStrings` class (centralized in Task 112).
No hardcoded strings anywhere in the codebase.

### 13.5 Security
- No sensitive data (FCM tokens) logged to console in production (cleaned in Task 112)
- Firebase public API keys in `firebase_options.dart` are safe to commit (standard Firebase practice)
- `agreedPrice > 0` guard enforced at both Cubit and data-source levels before payment transitions

---

## 14. Implementation Summary

All development phases are complete. The following reflects the final implemented state.

### Auth & User Management — Complete
| Feature | Status | Notes |
|---|---|---|
| Client registration | Done | Firebase Auth + Firestore |
| Helper registration (3-step) | Done | + ImgBB document upload |
| Login | Done | Email + password |
| Forgot password | Done | Firebase password reset email |
| Change password | Done | Firebase re-auth required |
| Profile picture upload | Done | ImgBB API |
| Full name editing | Done | Modal input + Firestore update |
| Logout | Done | Clears session + redirects |

### Helper Verification — Complete
| Feature | Status | Notes |
|---|---|---|
| Verification pending screen | Done | Real-time status listener |
| Real-time redirect on approval | Done | AuthCubit stream → GoRouter |
| Admin verification dashboard | Done | View docs, Approve/Reject |

### Helper Discovery — Complete
| Feature | Status | Notes |
|---|---|---|
| Client home with categories | Done | Filter by specialty |
| Search results | Done | Filtered by verificationStatus == 'approved' |
| Helper profile (ratings, reviews) | Done | Real-time StreamBuilder |
| Rating display | Done | "جديد" fallback for unrated helpers |

### Booking Flow — Complete
| Feature | Status | Notes |
|---|---|---|
| Send booking request | Done | Date, time, duration, task, price |
| Accept / Reject booking | Done | Helper-side, with price validation |
| Counter-offer negotiation | Done | proposedHourlyRate in Firestore |
| Pay & Start Service | Done | confirmed → inProgress |
| Confirm completion (both sides) | Done | Atomic Firestore transaction |
| Real-time booking status stream | Done | BookingDetailsScreen live updates |
| Client bookings dashboard | Done | Active & History tabs |
| Helper bookings dashboard | Done | New, Active, History tabs |
| Rating screen | Done | 5-star + written review |

### Chat — Complete (Session-Based)
| Feature | Status | Notes |
|---|---|---|
| Real-time chat room | Done | Firestore messages sub-collection |
| Message read receipts | Done | isRead field, unreadCount reset |
| Dynamic AppBar title resolution | Done | FutureBuilder Firestore lookup |
| Chat push notifications | Done | FCM via Vercel backend |
| Deep link from notification | Done | Routes to ChatRoomScreen |
| Global chat tab | Removed | Task 110 — session-based only |

### Push Notifications — Complete
| Feature | Status | Notes |
|---|---|---|
| FCM token sync | Done | AuthCubit on login |
| Booking event notifications | Done | All status transitions |
| Chat message notifications | Done | Per message sent |
| Custom notification icon | Done | XML Vector Drawable |
| Notification history screen | Done | ListView from Firestore stream |

### Admin Dashboard — Complete
| Feature | Status | Notes |
|---|---|---|
| Admin shell (3-tab) | Done | Dashboard / Users / Bookings |
| Users management screen | Done | Clients & Helpers tabs |
| Helper approval flow | Done | Approve/Reject with Firestore update |
| Bookings monitoring | Done | Active, Pending, History |
| Role-based admin access button | Done | Visible only in Profile for admins |

### Not Implemented (Intentionally Excluded)
| Feature | Reason |
|---|---|
| Medical Vault | Removed (Task 102) — out of scope |
| Helper Schedule/Earnings screens | Not built — out of scope for graduation project |
| Live GPS / Map tracking | Design decision — status-based tracking only |
| External payment gateway | Not required — status-based "pay" action |
| Firebase Cloud Functions | Not deployed — in-app transitions used instead |
| Firebase Storage | Replaced by ImgBB API (Task 97) |

---

## 15. Known Decisions & Rationale

| Decision | Reason |
|---|---|
| No live GPS tracking | Saves battery/resources. Progress tracked via Firestore status only |
| In-app state transitions instead of Cloud Functions | Avoids Firebase Blaze billing; sufficient for graduation project scope |
| ImgBB API for image uploads | Avoids Firebase Storage billing; free tier sufficient for project needs |
| Custom Node.js + Vercel for FCM | Avoids Firebase Blaze plan requirement for server-side FCM dispatch |
| Session-based chat only (no global chat tab) | Enforces task-specific communication; prevents unrelated messaging |
| Single BookingDetailsScreen for all statuses | Simplifies navigation; role-based + status-based rendering handles all states |
| Single booking request screen (not multi-step) | Consolidated flow; text-based location is sufficient |
| Medical Vault removed | Out of scope for the core social assistance use case |
| verificationStatus over isApproved flag | More semantic; one field covers pending/approved/rejected cleanly |
| Arabic-only UI | Primary target market is Egypt; full RTL support throughout |
| GetIt over Provider for DI | More suitable for large feature-based Clean Architecture |
| GoRouter over Navigator 2.0 | Declarative routing, auth-gated redirects, deep-link support |
| feature-based folders over layer-based | Easier to scale; each feature is independently owned |
| agreedPrice validation at Cubit + DataSource level | Double guard prevents zero/negative price transitions reaching Firestore |

---

> **For Academic Evaluators:** This documentation reflects the exact state of the Sanad
> graduation project codebase as submitted. All features listed as "Done" are fully implemented
> and functional. Features listed as "Not Implemented" were consciously excluded or removed
> during development for technical and scope reasons documented above.
>
> **For AI Tools:** When generating code for this project:
> 1. Always check which feature you are working in (Section 5)
> 2. Respect layer boundaries (Section 4)
> 3. Use the exact entity fields from Section 8
> 4. Follow the booking state machine from Section 9
> 5. Use Arabic strings from AppStrings — never hardcode UI text
> 6. Use AppColors, AppTextStyles, AppSpacing — never hardcode values
> 7. Always return Either<Failure, T> from repositories and use cases
> 8. Chat is session-based — do NOT add a global chat tab to the shell
> 9. State transitions are triggered by user actions — do NOT add Cloud Function logic
