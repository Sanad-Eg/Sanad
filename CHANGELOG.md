# Changelog

All notable changes to this project will be documented in this file.

## [2026-07-12] - Sync Master Documentation with Codebase (Task 115)

### Changed
- Synced `SANAD_MASTER_DOCUMENTATION.md` with the actual codebase using the changelog history as the source of truth.
- Removed all references to unimplemented or removed features: Medical Vault, Live GPS Map Tracking, Global Chat Tab, Firebase Cloud Functions, Firebase Storage, multi-step booking location/task/summary screens, Helper Schedule/Earnings screens, and external payment gateways.
- Updated Tech Stack section to reflect ImgBB API (instead of Firebase Storage) and the custom Node.js/Vercel FCM backend.
- Corrected Folder Structure to match actual `lib/features/` directory contents.
- Rewrote Features & Screens tables to list only implemented screens with their actual routes.
- Clarified session-based chat behavior: accessible only from `BookingDetailsScreen` during active statuses; no global Chat tab in bottom navigation.
- Clarified status-triggered progress tracking: all transitions driven by explicit user actions in `BookingDetailsScreen` — no CRON jobs or Cloud Functions.
- Replaced the "Progress Tracker" section (all 🔴 Not Started) with an "Implementation Summary" reflecting the actual completed state.
- Updated Data Models to remove `MedicalDocumentEntity`, `ScheduleSlotEntity`, `EarningsEntity`, and obsolete entity fields (distanceInKm, isOnline, location GeoPoint).
- Updated Firebase Schema to remove `medical_documents` and `schedule_slots` collections and add `agreedPrice`, `isRated`, `clientName`, `helperName` to the bookings schema.
- Updated Navigation Map to reflect the 3-tab shells (Home/Bookings/Profile) and removed all removed routes.
- Updated Known Decisions & Rationale to document ImgBB, Vercel/Node.js, and session-based chat decisions.

---

## [2026-07-12] - Final Repository Cleanup and README Generation (Task 114)

### Changed
- Removed obsolete development/crash log files (`flutter_01.log`, `flutter_02.log`) from the repository root directory.
- Secured `.gitignore` to explicitly ignore log outputs and Firebase production service credentials (`*.log`, `google-services.json`, `GoogleService-Info.plist`).
- Replaced the template README with a professional, comprehensive project documentation tailored for final submission.

## [2026-07-12] - Comprehensive Pre-Release Code Audit (Task 112)

### Changed
- Centralized all remaining hardcoded Arabic and English UI text and validation message strings into the `AppStrings` class.
- Cleared out development debug logging and `debugPrint` logs across presentation, business logic (Cubits), and data layers.
- Removed verbose terminal/console logging that printed sensitive fields (such as client/helper FCM tokens) to the device logger.
- Documented key security model regarding Firebase public API keys in `firebase_options.dart`.

## [2026-07-12] - Remove Global Chat Tab from Main Layout (Task 110)

### Removed
- Removed the "المحادثات" (Chats) `BottomNavigationBarItem` from both the **Client Shell** and **Helper Shell** bottom navigation bars to enforce task-specific, session-based communication only.
- Removed the `GoRoute` entries for `AppRoutes.chatList` and `AppRoutes.helperChatList` from each shell's route list.
- Removed unused `chat_list_cubit.dart` and `chat_list_screen.dart` imports from `app_router.dart`.

### Fixed
- Updated `_getClientIndex` and `_getHelperIndex` helper methods to correctly reflect the new 3-tab indices (Home → 0, Bookings → 1, Profile → 2).

---

## [2026-07-12] - Fix Silent Navigation Failure for Forgot Password (Task 109)

### Fixed
- Whitelisted `AppRoutes.forgotPassword` in `isLoggingIn` check inside the `AppRouter`'s redirect configuration, resolving the bug where unauthenticated users were silently redirected back to the Login screen.

---

## [2026-07-12] - Aggressive Debugging for Forgot Password Flow (Task 108)

### Added
- Added verbose debug logs to identify flow breakages or silent validation failures during the Forgot Password execution chain.
- Added tap detection logs on the login screen button (`FORGOT_PASS_TAP: Login screen button tapped`).
- Instrumented the submit and validation checks on `ForgotPasswordScreen` with validation pass (`Form validated successfully`) and failure (`Form validation failed!`) logging.
- Added call-site entry logging in `AuthCubit.resetPassword` (`FORGOT_PASS_CUBIT: resetPassword called with email: ...`).

---

## [2026-07-12] - Debug and Fix "Forgot Password" Flow (Task 107)

### Fixed
- Added `listenWhen` to `BlocConsumer` in `ForgotPasswordScreen` so the listener only fires after a loading state, preventing false-positive triggers on initial screen load.
- Updated success SnackBar message to "تم إرسال الرابط بنجاح" as required.
- Added `debugPrint('Reset Password Error: ...')` inside the `resetPassword` error handler in `AuthCubit` for improved diagnostics.
- Verified `sendPasswordResetEmail` in `FirebaseAuthRepositoryImpl` is correctly implemented.
- Confirmed "هل نسيت كلمة المرور؟" button on LoginScreen properly navigates to `/forgot-password` route.

---

## [2026-07-11] - Implement "Forgot Password" Flow (Task 106)

### Added
- Implemented `sendPasswordResetEmail` in `AuthRepository` and `FirebaseAuthRepositoryImpl` using Firebase Auth integration.
- Added `resetPassword(String email)` in `AuthCubit` to coordinate forgot password email dispatch states.
- Created `ForgotPasswordScreen` containing email input validators, status observers, and back-to-login redirect logic.
- Wired the "هل نسيت كلمة المرور؟" (Forgot Password) button on `LoginScreen` to push to the forgot password page route.
- Registered `/forgot-password` route in GoRouter config.

---

## [2026-07-11] - Implement Change Password and Notifications History UI (Task 105)

### Added
- Implemented secure Change Password functionality in `AuthRepository` and `AuthCubit` incorporating required Firebase re-authentication with `EmailAuthProvider.credential`.
- Replaced the Change Password placeholder screen with a full-fledged `ChangePasswordScreen` containing current, new, and confirm password fields, form validation, and save trigger callbacks.
- Audited the `NotificationsScreen` layout and confirmed its ListView.builder and empty state list rendering pointing to real-time user notification documents stream collections in Firestore.

---

## [2026-07-11] - Profile Screen Updates (Task 104)

### Added
- Added full name editing functionality with a modal input dialog and update execution via Firestore & AuthCubit.
- Linked "تغيير كلمة المرور" (Change Password) route to placeholder screen navigation.
- Removed the deprecated "الدعم والمساعدة" (Support & Help) option.

---

## [2026-07-11] - Audit and Fix Inactive Functions in Profile Screen (Task 103)

### Fixed
- Audited Profile Screen and wired up missing navigation and logic for "أرقام الطوارئ" (Emergency contacts) and "الإشعارات" (Notifications) to point to their respective routes.
- Added temporary SnackBar displays for "تغيير كلمة المرور" (Change Password) and "الدعم والمساعدة" (Support & Help) stating "سيتم إضافة هذه الميزة قريباً".
- Updated the logout button's `BlocListener` in the Profile Screen to correctly redirect unauthenticated users to the Login screen.

---

## [2026-07-11] - Remove Medical Cabinet Feature (Task 102)

### Removed
- Removed the Medical Cabinet (الخزانة الطبية) feature completely, including all UI entry points (such as the list tile in the profile screen), GoRouter routing paths, and all associated business logic (Cubits, State, UseCases, Repositories, DataSources, Models, and Entities).

---

## [2026-07-11] - Fix Real-Time Redirection Bug (Task 101)

### Fixed
- Fixed bug where `AdminCubit.verifyHelper` wrote `'verified'` to Firestore but the router gate, `BlocListener`, and `UserEntity.isVerifiedHelper` all expected `'approved'`, causing helpers to remain stuck on the pending screen.
- Fixed `UserModel.fromJson` incorrectly defaulting `verificationStatus` to `'approved'` for all users (including clients/admins).
- Updated `AuthCubit._resolveUser` to emit a fresh `AuthState` object on every stream update (not via `copyWith`), ensuring `BlocListener` always fires even when only nested fields like `verificationStatus` change.
- Updated router helper gate to allow both `'approved'` and `'verified'` statuses.
- Updated `BlocListener` in `verification_pending_screen.dart` to accept both statuses and added `debugPrint` for easier stream tracing.
- Added `debugPrint` to `AuthCubit` stream listener to verify data flow.

---

## [2026-07-11] - Real-Time Helper Redirection (Task 100)

### Added
- Implemented real-time Firestore stream for the current user's profile to automatically redirect helpers from the pending screen to the helper home dashboard upon administrator approval.
- Exposed `watchCurrentUser` stream in `AuthRemoteDataSource`, `AuthRemoteDataSourceImpl`, `AuthRepository`, and `FirebaseAuthRepositoryImpl`.
- Configured `AuthCubit` to listen to `watchCurrentUser` stream reactively, update user profile state, and correctly dispose of the subscription on logout and cubit close.
- Refactored `verification_pending_screen.dart` to use a `BlocListener` listening to the user's real-time verification status change instead of manually subscribing to Firestore streams directly in the UI.

---

## [2026-07-11] - Profile Screen Admin Access Button (Task 99)

### Added
- Added role-based visibility button ("لوحة تحكم الإدارة") in the Profile Screen options list to grant administrators access to the Admin Dashboard route.

---

## [2026-07-11] - Build Admin Dashboard for Helper Verification (Task 98)

### Added
- Built Admin Dashboard interface (`admin_dashboard_screen.dart`) that displays the list of pending helper verification applications.
- Created `admin_helper_details_screen.dart` displaying helper details, verification documents (ID front, ID back, selfie with ID) using `CachedNetworkImage`, and prominent Approve (قبول) and Reject (رفض) action buttons.
- Updated GoRouter routing configuration under the admin shell to support `/admin/helper-details` and nested shell navigation.

---

## [2026-07-11] - Migrate Image Uploads to ImgBB API (Task 97)

### Changed
- Migrated profile and verification image uploads to ImgBB API using HTTP, removing Firebase Storage dependencies.
- Updated `AuthRemoteDataSourceImpl` to upload files using `http.MultipartRequest` to ImgBB.
- Updated `injection_container.dart` to remove the `FirebaseStorage` parameter from the `AuthRemoteDataSourceImpl` constructor call.

---

## [2026-07-11] - Profile Picture Upload (Task 96)

### Added
- Added profile picture upload functionality for both clients and helpers, storing images in Firebase Storage at `profile_pictures/{uid}.jpg` and displaying them in the UI.
- Added `uploadProfileImage` and `updateUserFields` methods to `AuthRemoteDataSource` and its Firebase implementation.
- Created `UploadProfileImageUseCase` and integrated it into `AuthCubit`.
- Updated the Profile screen with a tappable avatar that launches image picker, shows a loading overlay during upload, and displays the profile image using `CachedNetworkImage` with initials fallback.

---

## [2026-07-11] - Helper Verification Documents Upload (Task 95)

### Added
- Implemented Firebase Storage upload for helper identity documents (ID front, ID back, selfie with ID) and linked download URLs to their Firestore profile for admin verification.
- Added `idFrontUrl`, `idBackUrl`, `selfieUrl` fields to `UserEntity` and `UserModel`.
- Added `uploadVerificationDocs` method to `AuthRemoteDataSource` and its Firebase implementation.
- Updated `FirebaseAuthRepositoryImpl.registerHelper` to upload documents before persisting the user document.

---
## [2026-07-11] - Refine Helper Card UI and Fix Text Overflow (Task 94)

### Changed
- **Helper Card UI**: Cleaned up layout spacing and paddings inside both `client_home_screen.dart` and `search_results_screen.dart`. Removed obsolete distance stat ("كم" indicator) and location icon. Removed duplicate/redundant rating widget from the name row to avoid overlapping text with the price indicator on the left. Kept a single rating label at the bottom of the card formatted cleanly as `⭐ 4.8 (12 تقييم)` or `⭐ جديد`.

---

## [2026-07-11] - Revamp Helper Profile Stats and Add Reviews List (Task 93)

### Changed
- **Helper Profile Screen**: Removed the obsolete "المسافة منك" (Distance) stat block and adjusted layout of stats row to center the remaining "مهام منجزة" (Completed Tasks) and "تقييم" (Rating) stats.
- **Reviews Section**: Added "التقييمات والتعليقات" (Ratings & Reviews) section at the bottom of the profile details screen using a real-time StreamBuilder to load client feedback.
- **Backend Sync**: Configured `confirmCompletion` in the remote data source to atomically increment `completedTasksCount` and `completedTasks` inside a Firestore transaction upon successful booking completion. Also configured review submissions to resolve and persist the reviewer's name (`clientName`) at write time.

---

## [2026-07-11] - Display Helper Rating in UI Components (Task 91)

### Changed
- **UI Components**: Updated UI to visually display helper ratings and review counts on the profile and list screens. Added compact star rating display adjacent to helper names on list view cards, and added rating display under subtitle inside helper details header. Handled new/unrated helpers gracefully by showing "جديد" instead of raw zeros.

---

## [2026-07-11] - Fix Helper Rating Live Update on Profile Screen (Task 90)

### Fixed
- **Helper Rating & Profile**: Fixed helper rating synchronization and state management to update the UI dynamically upon receiving new reviews. Introduced `SubmitReviewUseCase` to update helper statistics and mark bookings as rated in Firestore. Implemented `getHelperProfileStream` and `watchHelperProfile` in `HelperDiscoveryCubit` to listen to live profile updates.

---

## [2026-07-11] - Replace Notification PNG with Vector Drawable (Task 87)

### Changed
- **Notification Icon**: Replaced buggy PNG notification icon with a clean XML Vector Drawable (Heart shape) to guarantee Android compatibility. Also updated `AndroidInitializationSettings` in `main.dart` to reference the new `ic_notification` drawable directly.

---

## [2026-07-11] - Apply and Process Custom Notification Silhouette (Task 86)

### Fixed
- **Notification Icon**: Replaced the distorted notification icon with a custom, correctly processed silhouette logo.

---

## [2026-07-11] - Configure Custom Android Notification Icon (Task 85)

### Added
- **Notification Icon**: Generated a custom white notification icon from the app logo and configured AndroidManifest to use it for push notifications.

---

## [2026-07-11] - Brand Integration - Add Logo to Key UI Screens (Task 84)

### Changed
- **Branding**: Integrated logo.png into Splash and Auth screens for consistent branding.

---

## [2026-07-11] - Set App Launcher Icon (Task 83)

### Changed
- **App Launcher Icon**: Updated the app launcher icon using the new logo.png via flutter_launcher_icons.

---

## [2026-07-11] - Implement Rating Screen UI (Task 82)

### Added
- **Rating Screen**: Created `lib/features/booking/presentation/screens/rating_screen.dart` with a 5-star interactive selector, optional written review field, and a submit button (backend wiring deferred to next task).
- **Route Update**: Updated `app_router.dart` to replace the `PlaceholderScreen` at `AppRoutes.bookingRate` with the real `RatingScreen`, passing `bookingId` via path parameter.
- **Completed State UI**: Added a `"تقييم المساعد"` (Rate Helper) button to `booking_details_screen.dart` visible to the client when booking status is `completed`.

---

## [2026-07-08] - Fix Logical Bug in Accept Booking Dialog (Task 80)

### Fixed
- **Accept Booking Dialog**: Fixed logical bug in helper's Accept Booking dialog to prevent unauthorized price changes without customer approval by removing the editable price field and replacing it with a read-only price/total amount summary confirmation screen.

---

## [2026-07-08] - Implement Push Notifications for Booking Requests (Task 79)

### Added
- **Booking Notifications**: Integrated push notifications for booking requests and status updates by adding asynchronous notification triggers on booking creation (`createBooking`) to alert helpers, and status changes (`updateBookingStatus`, `acceptBooking`, `rejectBooking`, `counterOffer`, `payBooking`, `confirmCompletion`) to alert clients.

---

## [2026-07-08] - Update Notification Server Base URL to Vercel (Task 77)

### Changed
- **Notification Server Base URL**: Updated notification server base URL to point to the live Vercel deployment: `https://sanad-nine-nu.vercel.app`.

---

## [2026-07-08] - Fix Missing Profile Name/Data in Chat Screen on Deep Link (Task 76)

### Fixed
- **Chat Profile Resolution**: Resolved missing recipient name issue in `ChatRoomScreen` when navigating via push notification deep links by implementing a dynamic fallback fetch logic in `ChatRoomScreen` (utilizing `FutureBuilder` to fetch from `chats` or `bookings` as well as `/users`), and including `senderId` and `senderName` inside the push notification FCM data payload for instant routing delivery.

---

## [2026-07-08] - Fix Empty Recipient ID in Chat Notifications (Task 75)

### Fixed
- **Chat Notifications**: Fixed bug where push notification `recipientId` was empty in chat remote data source by applying multi-level fallback strategies (splitting combo `chatId` matching `senderId`, client/helper resolution, or querying the bookings document).

---

## [2026-07-08] - Implement Notification Deep Linking (Task 73)

### Added
- **Notification Navigation**: Implemented Notification Deep Linking to automatically navigate to the Chat screen when a chat notification is tapped.

---

## [2026-07-08] - Trigger Push Notification on Chat Message (Task 72)

### Changed
- **Chat Notifications**: Integrated `NotificationSenderService` with Chat feature. Sending real-time push notifications upon successful message delivery.

---

## [2026-07-08] - Create Notification Sender Service in Flutter (Task 71)

### Added
- **Notification Sender**: Created `NotificationSenderService` using the `http` package to communicate with the local Node.js notification server via local IP.

---

## [2026-07-08] - Build Custom Node.js Backend for FCM Notifications (Task 70)

### Added
- **Node.js Notification Backend**: Added local Node.js backend using Firebase Admin SDK to handle Push Notifications without requiring the Firebase Blaze plan.

---

## [2026-07-08] - Fix FCM Token Sync Race Condition (Task 69)

### Fixed
- **FCM Token Sync**: Fixed FCM token race condition by decoupling token sync logic and triggering it explicitly from `AuthCubit` upon successful authentication.

---

## [2026-07-08] - Update desugar_jdk_libs version

### Changed
- **Desugaring**: Updated `desugar_jdk_libs` to version 2.1.4 to satisfy `flutter_local_notifications` constraints.

---

## [2026-07-08] - Enable Core Library Desugaring for Android (Task 67)

### Added
- **Desugaring**: Enabled core library desugaring in `android/app/build.gradle.kts` to support `flutter_local_notifications`.

---

## [2026-07-08] - Initiate Phase 14: FCM & Notification Service (Task 59)

### Added
- **Notification Infrastructure**: Configured FCM and `flutter_local_notifications`, added `AndroidManifest.xml` meta-data, and implemented `PushNotificationService` for token syncing.

---

## [2026-07-08] - Fix Logout Navigation in Verification Pending Screen (Task 65)

### Fixed
- **`verification_pending_screen.dart`**: Fixed the "Log in later" button navigation flow by ensuring the widget awaits `AuthCubit.logout()` and explicitly redirects the user to `AppRoutes.login` via GoRouter.

---

## [2026-07-08] - Restore Stream Logic & Refine Pending Screen UX (Task 64)

### Fixed & Refined
- **`verification_pending_screen.dart`**: Converted to a `StatefulWidget` and initialized a real-time Firestore stream subscription on the current user's document. When `verificationStatus` updates to `'approved'`, the screen automatically triggers `context.read<AuthCubit>().checkAuth()` to trigger routing to the home dashboard.
- **UX Refinement**: Removed the logout action button from the AppBar and added a clean, professional "تسجيل الدخول في وقت لاحق" (Log in later) `TextButton` at the bottom of the screen to clear the session and return to the login screen.

---

## [2026-07-08] - Fix Create Booking Screen Data Binding & Currency (Task 63)

### Fixed
- **`send_booking_request_screen.dart`**: Refactored the screen to accept a required `HelperEntity` object instead of primitive parameters. Cleaned up all widget fields and bound the helper name, hourly rate, and reactive cost calculation correctly using EGP/جنيه currency.
- **`helper_profile_screen.dart`**: Updated navigation onPressed handler to pass the helper object directly via the `extra` parameter of GoRouter.
- **`app_router.dart`**: Updated route definition for `/book-datetime` to safely handle extracting the `HelperEntity` from GoRouter extra, with a robust fallback constructor parsing query parameters for hot restart/deep link cases.
- **Currency**: Audited and confirmed EGP/جنيه is used consistently across the UI calculations.

---

## [2026-07-07] - Audit and Fix Booking Flow & Price Validation (Task 62)

### Changed
- **`BookingEntity` & `BookingModel`**: Added `agreedPrice` field, supporting safe parsing from Firestore snapshot and serialization.
- **`BookingCubit`**: Implemented strict validation guards in `accept` and `pay` methods to block transitions to accepted or inProgress if `agreedPrice` (or hourly rate) is missing, zero, or negative.
- **`BookingDetailsScreen`**: Added an acceptance input dialog for Helpers to input and validate `agreedPrice > 0` before accepting. Passed `proposedHourlyRate` when Clients accept negotiated offers.
- **`BookingRemoteDataSourceImpl`**: Added database-level guards on `acceptBooking` and `payBooking` to enforce non-zero price boundaries.

---

## [2026-07-06] - Refactor Helper Approval to verificationStatus (Task 61)

### Changed
- **`UserEntity` & `UserModel`**: Removed the redundant `isApproved` flag entirely.
- **`UserModel.fromJson`**: Deserialization now defaults `verificationStatus` to `'approved'` if null/missing to support legacy user accounts.
- **Helper Discovery**: Changed query in `HelperRemoteDataSourceImpl.getHelpers` to filter by `verificationStatus == 'approved'` instead of using the obsolete `isApproved` flag.
- **Admin approval**: `approveHelper` now updates Firestore with `verificationStatus: 'approved'`.
- **Admin UI & Router**: Checked/refactored `admin_users_screen.dart` and `app_router.dart` to determine approval/review state using `verificationStatus != 'approved'` rather than `isApproved`.

---

## [2026-07-06] - Verification Pending Screen & Router Audit (Task 60)

### Changed
- **`verification_pending_screen.dart`**:
  - Removed the broken "تسجيل الدخول لاحقاً" button (which navigated without signing out, creating a session trap).
  - Added a real **AppBar logout escape hatch** — `TextButton.icon` with `Icons.logout_rounded` that calls `context.read<AuthCubit>().logout()`.
  - Updated title to **"حسابك قيد المراجعة"** and subtitle to explain admin review.
  - Changed icon to `Icons.pending_actions_rounded`.
  - Removed unused `go_router` / `app_routes` imports.
- **`app_router.dart` — redirect logic**:
  - Added **3a gate**: helpers with `verificationStatus == 'pending'` → `verificationPending` (from any route, not just on login).
  - Added **3b gate**: helpers with `isApproved == false` → `verificationPending` (blocks approved-doc-but-not-yet-admin-approved helpers from accessing the dashboard).
  - Refactored redirect into clearly labelled steps (3a / 3b / 3c) for maintainability.

---

## [2026-07-06] - Helper Approval System (Task 58)

### Added
- **`isApproved` field** added to `UserEntity`, `UserModel` (fromJson default `true` for legacy docs; `false` on `newHelper` factory).
- **Helper discovery filter**: `getHelpers` query now includes `.where('isApproved', isEqualTo: true)` so unapproved helpers never appear to clients.
- **`approveHelper(uid)`** added to `AdminRemoteDataSource`, `AdminRemoteDataSourceImpl`, `AdminRepository`, `FirebaseAdminRepositoryImpl`.
- **`ApproveHelperUseCase`**: new domain use case wrapping the repository call.
- **`AdminUsersCubit.approveHelper(uid)`**: exposes the approval action to the UI; the Firestore stream auto-refreshes the list on success.
- **`AdminUsersScreen` — Helpers tab**: unapproved helpers now display a yellow *"قيد المراجعة"* badge and a green *"قبول المساعد"* button that calls the cubit.
- All new registrations added to `injection_container.dart`.

---

## [2026-07-06] - Admin Dashboard UI & Logout (Task 57)

### Added
- **`AdminDashboardScreen`**: Replaced the placeholder with a full Scaffold featuring:
  - A premium gradient welcome banner displaying the admin's name.
  - An AppBar with a logout `IconButton` (`Icons.logout_rounded`).
  - A confirmation `AlertDialog` before triggering `context.read<AuthCubit>().logout()`.
  - Quick-access cards for Users and Bookings sections.
  - An informational hint card at the bottom.

---

## [2026-07-05] - Implement Admin Bookings Monitoring (Task 56)

### Added
- **Admin Bookings Monitoring Data/Domain Layers**:
  - Implemented `Stream<List<BookingModel>> getAllBookingsStream()` in `AdminRemoteDataSource` and `AdminRemoteDataSourceImpl` using `BookingModel.fromFirestore` with local sort by `createdAt` descending.
  - Implemented the repository interface and domain `GetAllBookingsUseCase` to fetch all platform bookings.
- **Admin Bookings Cubit**:
  - Created `AdminBookingsCubit` and `AdminBookingsState` with proper subscription cancellation in `close()`.
  - Registered `AdminBookingsCubit` and `GetAllBookingsUseCase` in `injection_container.dart`.
- **UI Screen - `AdminBookingsScreen`**:
  - Built `AdminBookingsScreen` using `DefaultTabController` with three sections: "النشطة" (Active), "المعلقة" (Pending), and "السجل" (History).
  - Designed cards displaying booking description/title, status (badge format with dynamic colors), date/time, price, and total amount.
  - Enabled card navigation leading directly to `AppRoutes.bookingTracking` for detailed tracking.
- **Router Configuration**:
  - Wrapped `AdminBookingsScreen` with `AdminBookingsCubit` provider and initialized data lookup via `watchAllBookings()` inside `app_router.dart`.

---

## [2026-07-05] - Implement Admin Users Management (Task 55)

### Added
- **Admin Data & Domain Layers (Fetch Users)**:
  - Added `Stream<List<UserModel>> getUsersStream()` to `AdminRemoteDataSource` and implemented it in `AdminRemoteDataSourceImpl` using Firestore collection snapshot updates.
  - Added `getUsersStream` signature to `AdminRepository` and implemented it in `FirebaseAdminRepositoryImpl`.
  - Created `GetUsersUseCase` to return the real-time stream of all users.
- **Admin Users Cubit**:
  - Created `AdminUsersCubit` and `AdminUsersState` with states: Initial, Loading, Loaded(List<UserEntity>), and Error.
  - Added stream subscription management and safe resource cleanup in `close()`.
  - Registered `AdminUsersCubit` and `GetUsersUseCase` in `injection_container.dart`.
- **UI Screen - `AdminUsersScreen`**:
  - Implemented `AdminUsersScreen` layout with `DefaultTabController` splitting "العملاء" (Clients) and "المساعدين" (Helpers).
  - List displays dynamically using `ListView.builder` filtering users by role (`role == 'client'` vs `role == 'helper'`).
  - Added details to user cards: Name, Email, Phone number, and list of Specialties tags for helpers.
- **Router Configuration**:
  - Wrapped `AdminUsersScreen` with `AdminUsersCubit` provider and initialized data lookup via `watchUsers()` inside `app_router.dart`.

---

## [2026-07-05] - Initialize Admin Feature & Shell Routing (Task 54)

### Added
- **Admin Presentation Screens**:
  - `AdminShellScreen`: Configured Scaffold and BottomNavigationBar with items: "الرئيسية" (Dashboard), "المستخدمين" (Users/Helpers), and "الطلبات" (Bookings).
  - `AdminDashboardScreen` [NEW]: Created dashboard placeholder.
  - `AdminUsersScreen` [NEW]: Created users/helpers configuration placeholder.
  - `AdminBookingsScreen` [NEW]: Created bookings administration placeholder.
- **Admin Shell Navigation Configuration**:
  - Integrated `AdminShellScreen` as a `ShellRoute` in `app_router.dart` sharing a common `AdminCubit` instance across sub-routes.
  - Added new routes in `app_routes.dart`: `adminDashboard` (`/admin/dashboard`), `adminUsers` (`/admin/users`), and `adminBookings` (`/admin/bookings`).
  - Added `adminShellKey` navigator key to `AppRouter` for nested navigation isolation.
  - Updated authentication redirection logic to route administrative role users directly to `adminDashboard` upon successful login.

---

## [2026-07-05] - Bulletproof Chat Room Title Resolution (Task 55)

### Fixed
- **Dynamic Name Direct Fetch**: Integrated a robust, direct Firestore document lookup inside `ChatRoomScreen` (`chat_room_screen.dart`) using `FutureBuilder` to fetch the other party's user document from `users` collection by their UID, fallbacking safely to dynamic `otherPartyName` or chat model data.
- **Removed Hardcoded Nav Parameters**: Removed the legacy hardcoded name fallbacks ('المساعد' / 'العميل') from `BookingDetailsScreen` (`booking_details_screen.dart`) when executing navigation to `/chat`, passing empty names to force a clean dynamic fetch on the chat page.

---

## [2026-07-05] - Booking Details Screen Role & State Audit (Task 53)

### Fixed
- **Role Verification Security**: Updated role verification in `BookingDetailsScreen` (`isClient`/`isHelper`) to derive roles by comparing the authenticated user's UID against the booking's `clientId` and `helperId`, preventing generic fallback role issues and role leaks.
- **State Machine Actions Matrix**: Strictly enforced role-based button rendering at the bottom of the screen:
  - **`pending`**: Helper sees `Accept`, `Reject`, and `Negotiate` buttons. Client sees `Cancel Request` button (triggers `reject` transition to cancel/reject).
  - **`negotiating`**: Client sees `Accept Offer` and `Reject Offer` alongside the proposed hourly rate. Helper sees a "Waiting for Client" status message.
  - **`confirmed` (accepted)**: Helper sees a `Start Task` button (calls cubit `pay` to transition to `inProgress`). Client sees `Pay & Start Service` button.
  - **`inProgress` (active)**: Helper sees `Confirm Completion` button. Client sees "Service in progress" message.
  - **`confirmingCompletion`**: Client sees `Confirm Completion` button. Helper sees waiting banner.
  - **Terminal States (`completed`/`cancelled`/`rejected`)**: Hidden all action buttons for both roles.
- **Chat Button Lifecycle**: Rendered the `Chat` button only during active service states (`confirmed`, `inProgress`, `confirmingCompletion`, `disputed`) and only for participant roles (isClient || isHelper).
- **Unused Warning Resolution**: Integrated the handshake checklist (`_buildConfirmationProgress`) into both the active and confirming completion states.

---

## [2026-07-05] - Dynamic Chat Room AppBar Title (Task 52)

### Added
- **`GetChatStreamUseCase`**: Created new domain-layer usecase to listen to a stream of a single chat document.
- **`clientName` & `helperName`**: Added display name metadata to `ChatEntity` and `ChatModel`.

### Changed
- **`ChatRemoteDataSourceImpl.getChatStream`**: Implemented single chat streaming that automatically queries the bookings and users database to retrieve real participant display names if the chat document is not found or is empty in Firestore.
- **`ChatRemoteDataSourceImpl.sendMessage`**: Automatically resolves client and helper names from the users database on first message creation to initialize the parent chat document with complete participant metadata.
- **`ChatRoomCubit`**: Updated to listen to both messages and the chat details stream, maintaining `ChatEntity? chat` in the state.
- **`ChatRoomScreen`**: Wrapped the layout inside `BlocConsumer<ChatRoomCubit, ChatRoomState>` and made the AppBar title dynamic, displaying the other party's actual display name instead of hardcoded strings based on the current user's role.
- **`ChatListScreen`**: Updated the list tiles to use `chat.helperName` and `chat.clientName` instead of hardcoded strings.

---

## [2026-07-05] - Fix Chat Firestore Bugs & Role-based UI (Task 51)

### Fixed
- **Chat `sendMessage` — NOT_FOUND**: Confirmed fix from previous step: `batch.update()` → `batch.set(..., SetOptions(merge: true))` to safely upsert the chat document on first message.
- **Chat `markMessagesAsRead` — FAILED_PRECONDITION composite index**: Confirmed fix from previous step: single-field `isRead == false` query with Dart-side `senderId` filtering.
- **Booking Details — Client sees Helper action buttons**: Rewrote `_buildActionPanel` in [`booking_details_screen.dart`](file:///f:/temp/sanad/lib/features/booking/presentation/screens/booking_details_screen.dart) with strictly separated `if (isClient) {} if (isHelper) {}` branches at every status level:
  - **`pending`** — Client: "إلغاء الطلب" (cancel) only. Helper: Accept / Counter Offer / Reject.
  - **`negotiating`** — Client: "قبول العرض" + "رفض العرض" only. Helper: waiting message only.
  - **`confirmed`** — Client: Pay button. Helper: waiting message.
  - All other statuses (inProgress, confirmingCompletion, completed, cancelled) are role-agnostic and unchanged.
  - Every branch ends with `return const SizedBox.shrink()` as a safety fallback to prevent any role bleed.

---

## [2026-07-05] - Fix Chat Firestore Bugs (Phase 12 - Step 2)


### Fixed
- **`sendMessage` — NOT_FOUND on missing chat document**: Changed `batch.update(chatDocRef, ...)` to `batch.set(chatDocRef, ..., SetOptions(merge: true))`. This upserts the parent chat document (creating it if absent) instead of failing with a `NOT_FOUND` error when the chat document does not exist yet in Firestore.
- **`markMessagesAsRead` — FAILED_PRECONDITION composite index error**: Replaced the compound Firestore query (`isNotEqualTo senderId` + `isEqualTo isRead`) with a single-field query (`isRead == false`) and moved the `senderId != userId` filter to Dart. This eliminates the composite index requirement while preserving correct read-receipt behaviour. Also changed the final `chatDocRef.update({'unreadCount': 0})` to `chatDocRef.set({'unreadCount': 0}, merge: true)` so it doesn't crash when the document doesn't exist.

---

## [2026-07-05] - Real-time Chat System (Phase 12 - Step 1)


### Added (Pre-existing — Verified & Confirmed Complete)
- **`MessageEntity`**: Domain entity with fields `id`, `chatId`, `senderId`, `content`, `timestamp`, `isRead`.
- **`ChatEntity`**: Domain entity with fields `id`, `bookingId`, `clientId`, `helperId`, `lastMessage`, `updatedAt`, `unreadCount`.
- **`MessageModel`**: Data model extending `MessageEntity` with `fromFirestore` / `toJson` serialization.
- **`ChatModel`**: Data model extending `ChatEntity` with Firestore serialization support.
- **`ChatRemoteDataSource`**: Abstract contract exposing `getMyChats`, `getChatMessages`, `sendMessage`, and `markMessagesAsRead`.
- **`ChatRemoteDataSourceImpl`**: Firestore implementation:
  - `getMyChats(userId)`: streams chat documents where `clientId` or `helperId` matches, sorted in-memory by `updatedAt` descending.
  - `getChatMessages(chatId)`: streams `chats/{chatId}/messages` sub-collection, sorted ascending by `timestamp`.
  - `sendMessage(message)`: uses a Firestore batch to atomically write the message and update the parent chat's `lastMessage` and `updatedAt` fields.
  - `markMessagesAsRead(chatId, userId)`: bulk-updates unread messages and resets `unreadCount` to 0.
- **`ChatRepository`** & **`FirebaseChatRepositoryImpl`**: Domain + data repository mapping all operations to `Either<Failure, T>`.
- **`GetMyChatsUseCase`**, **`GetChatMessagesUseCase`**, **`SendMessageUseCase`**, **`MarkMessagesAsReadUseCase`**: Domain usecases.
- **`ChatListCubit`** / **`ChatRoomCubit`**: Presentation cubits with real-time stream subscriptions and proper `close()` cleanup.
- **`ChatListScreen`** / **`ChatRoomScreen`**: Full UI with message bubbles, input bar, read receipts, and a shortcut to the booking details.
- **DI Registration**: All chat data sources, repository, usecases, and cubits registered in `injection_container.dart`.

---

## [2026-07-05] - Helper Bookings Dashboard (Phase 11)


### Added
- **`getHelperBookingsStream`**: Added Firestore-backed real-time snapshot stream in `BookingRemoteDataSourceImpl` querying bookings by `helperId`, with in-memory descending date sort to prevent composite index requirements.
- **`getHelperBookingsStream` (Repository)**: Mapped data source stream into `Stream<Either<Failure, List<BookingEntity>>>` in `FirebaseBookingRepositoryImpl`.
- **`GetHelperBookingsUseCase`**: New domain-layer usecase delegating to `BookingRepository.getHelperBookingsStream`.
- **`HelperBookingsState`**: Sealed state classes (`Initial`, `Loading`, `Loaded`, `Error`) for the helper bookings dashboard cubit.
- **`HelperBookingsCubit`**: New presentation-layer Cubit subscribing to `GetHelperBookingsUseCase` and managing `StreamSubscription` lifecycle (cancelled in `close()`). Registered as `registerFactory` in `injection_container.dart`.
- **`HelperBookingsScreen`**: New screen at `/helper-bookings` route with a `DefaultTabController` showing 3 tabs:
  - **الطلبات الجديدة** (New): `pending` | `negotiating` statuses
  - **المهام الحالية** (Active): `confirmed` | `inProgress` | `confirmingCompletion` | `disputed` statuses
  - **السجل** (History): `completed` | `cancelled` | `expired` statuses
  - Each tab renders a `ListView.builder` of cards navigating to `/booking-track/:id` on tap.
- **`/helper-bookings` Route**: Registered in GoRouter inside the Helper ShellRoute with `HelperBookingsCubit` injected via `BlocProvider`.
- **`AppRoutes.helperBookings`**: Added route constant `/helper-bookings` to `app_routes.dart`.

### Changed
- **Helper Bottom Navigation Bar**: Added a 4th tab ("طلباتي" with `Icons.assignment_outlined`) between the home and chat tabs to surface the new helper bookings dashboard. Updated `_getHelperIndex` in `app_router.dart` to match the new tab indices.

---

## [2026-07-04] - Real-time Booking Tracking, Safe Navigation & Client Dashboard (Phase 10)


### Added
- **trackBooking Stream**: Implemented a real-time Firestore document stream mapping in `BookingRemoteDataSourceImpl` (`trackBooking`) and `FirebaseBookingRepositoryImpl` to listen to live updates for a specific booking.
- **TrackBookingUseCase**: Added a usecase in the domain layer to delegate booking tracking.
- **GetClientBookingsUseCase**: Created a new Clean Architecture domain usecase for streaming client bookings.
- **ClientBookingsCubit**: Created a new presentation-layer Cubit to manage real-time streams of client bookings and expose states (`ClientBookingsInitial`, `ClientBookingsLoading`, `ClientBookingsLoaded`, and `ClientBookingsError`).
- **`/client-bookings` Route**: Configured GoRouter mapping inside `app_router.dart` to instantiate and inject the new `ClientBookingsCubit` for the Client Bookings screen.
- **Real-time Firestore List Stream**: Added `getClientBookingsStream` in `BookingRemoteDataSource` and `BookingRepository` to query Firestore documents for the current client, sorted by creation time with memory-safe in-memory ordering.

### Fixed
- **Negotiation Price Bug**: Updated `counterOffer` method in `BookingRemoteDataSourceImpl` to write the counter offer price into `proposedHourlyRate` in Firestore (instead of updating `agreedHourlyRate` directly), ensuring price is correctly saved and displayed.
- **Safe Back Navigation & Pop Scope**: Wrapped `BookingDetailsScreen` in a `PopScope` (using warning-free `onPopInvokedWithResult`) to safely check `context.canPop()` and fall back to role-based homepage redirection, preventing native Signal 3 engine crashes.
- **Live UI Updates Binding**: Bound `BookingDetailsScreen` elements (status banner, pricing rows, and actions panel) strictly to the `BookingLoaded` state's dynamic booking data from the real-time stream.

### Changed
- **ClientBookingsScreen**: Fully refactored `client_bookings_screen.dart` to use `DefaultTabController` with two tabs ("الطلبات النشطة" and "السجل"), bound elements cleanly using the new cubit state, and added support for counter-offer price estimation.
