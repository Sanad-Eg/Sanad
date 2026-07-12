import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:sanad/core/widgets/placeholder_screen.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_state.dart';
import 'package:sanad/features/auth/presentation/screens/client_register_screen.dart';
import 'package:sanad/features/auth/presentation/screens/helper_register_screen.dart';
import 'package:sanad/features/auth/presentation/screens/login_screen.dart';
import 'package:sanad/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:sanad/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:sanad/features/auth/presentation/screens/verification_pending_screen.dart';
import 'package:sanad/features/auth/presentation/screens/change_password_screen.dart';
import 'package:sanad/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:sanad/core/utils/cache_helper.dart';
import 'package:sanad/injection_container.dart';

// Helper Discovery imports
import 'package:sanad/features/helper_discovery/domain/entities/helper_entity.dart';
import 'package:sanad/features/helper_discovery/presentation/cubit/helper_discovery_cubit.dart';
import 'package:sanad/features/helper_discovery/presentation/screens/client_home_screen.dart';
import 'package:sanad/features/helper_discovery/presentation/screens/helper_profile_screen.dart';
import 'package:sanad/features/helper_discovery/presentation/screens/search_results_screen.dart';

// Booking Flow imports
import 'package:sanad/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:sanad/features/booking/presentation/screens/booking_details_screen.dart';
import 'package:sanad/features/booking/presentation/screens/send_booking_request_screen.dart';
import 'package:sanad/features/booking/presentation/screens/rating_screen.dart';

// Helper Dashboard imports
import 'package:sanad/features/booking/presentation/cubit/my_bookings_cubit.dart';
import 'package:sanad/features/booking/presentation/cubit/client_bookings_cubit.dart';
import 'package:sanad/features/booking/presentation/cubit/helper_bookings_cubit.dart';
import 'package:sanad/features/booking/presentation/screens/client_bookings_screen.dart';
import 'package:sanad/features/booking/presentation/screens/helper_bookings_screen.dart';
import 'package:sanad/features/helper_dashboard/presentation/screens/helper_home_screen.dart';

// Main Layout imports
import 'package:sanad/features/main_layout/presentation/screens/profile_screen.dart';

// Chat Feature imports
import 'package:sanad/features/chat/presentation/cubit/chat_room_cubit.dart';
import 'package:sanad/features/chat/presentation/screens/chat_room_screen.dart';

// Emergency Contacts imports
import 'package:sanad/features/emergency/presentation/cubit/emergency_cubit.dart';
import 'package:sanad/features/emergency/presentation/screens/emergency_contacts_screen.dart';

// Notifications imports
import 'package:sanad/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:sanad/features/notifications/presentation/screens/notifications_screen.dart';

// Admin imports
import 'package:sanad/features/auth/domain/entities/user_entity.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_users_cubit.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_bookings_cubit.dart';
import 'package:sanad/features/admin/presentation/screens/admin_shell_screen.dart';
import 'package:sanad/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:sanad/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:sanad/features/admin/presentation/screens/admin_bookings_screen.dart';
import 'package:sanad/features/admin/presentation/screens/admin_helper_details_screen.dart';

class AppRouter {
  static GoRouter? router;
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> clientShellKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> helperShellKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> adminShellKey =
      GlobalKey<NavigatorState>();

  static GoRouter buildRouter(AuthCubit authCubit) {
    router = GoRouter(
    initialLocation: AppRoutes.splash,
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterNotifier(authCubit),
    redirect: (context, state) {
      final authState = authCubit.state;
      final loc = state.matchedLocation;
      final isSplash = loc == AppRoutes.splash;
      final isLoggingIn = loc == AppRoutes.login ||
          loc == AppRoutes.onboarding ||
          loc == AppRoutes.roleSelect ||
          loc == AppRoutes.registerClient ||
          loc == AppRoutes.registerHelper ||
          loc == AppRoutes.verificationPending ||
          loc == AppRoutes.forgotPassword;

      // 1. If still checking, force splash screen
      if (authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.checking) {
        return isSplash ? null : AppRoutes.splash;
      }

      // 2. If unauthenticated — send to onboarding/login
      if (authState.status == AuthStatus.unauthenticated) {
        if (isSplash || !isLoggingIn) {
          final hasSeenOnboarding =
              CacheHelper.getData(key: 'has_seen_onboarding') as bool? ?? false;
          return hasSeenOnboarding ? AppRoutes.login : AppRoutes.onboarding;
        }
        return null;
      }

      // 3. If authenticated
      if (authState.status == AuthStatus.authenticated) {
        final role = authState.user?.role ?? 'client';
        final verificationStatus = authState.user?.verificationStatus;

        // 3a. Helper gating: unapproved / pending verification
        if (role == 'helper' &&
            verificationStatus != 'approved' &&
            verificationStatus != 'verified') {
          return loc == AppRoutes.verificationPending
              ? null
              : AppRoutes.verificationPending;
        }

        // 3c. Route from splash/auth screens to home
        if (isSplash || isLoggingIn) {
          if (role == 'admin') return AppRoutes.adminDashboard;
          if (role == 'helper') return AppRoutes.helperHome;
          return AppRoutes.clientHome;
        }
      }

      return null; // No redirect needed
    },
    routes: [
      // ── Splash Screen (initial auth check) ──────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashScreen(),
      ),

      // ── Auth Routes (wrapped with AuthCubit BlocProvider) ────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelect,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => BlocProvider.value(
          value: sl<AuthCubit>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.registerClient,
        builder: (context, state) => BlocProvider.value(
          value: sl<AuthCubit>(),
          child: const ClientRegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.registerHelper,
        builder: (context, state) => BlocProvider.value(
          value: sl<AuthCubit>(),
          child: const HelperRegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.verificationPending,
        builder: (context, state) => const VerificationPendingScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => BlocProvider.value(
          value: sl<AuthCubit>(),
          child: const ForgotPasswordScreen(),
        ),
      ),

      // ── Client Shell ──────────────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: clientShellKey,
        builder: (context, state, child) {
          final user = context.read<AuthCubit>().state.user;
          return BlocProvider(
            create: (_) => sl<NotificationsCubit>()..watchNotifications(user?.id ?? ''),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _getClientIndex(state.uri.toString()),
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go(AppRoutes.clientHome);
                    break;
                  case 1:
                    context.go(AppRoutes.clientBookings);
                    break;
                  case 2:
                    context.go(AppRoutes.clientProfile);
                    break;
                }
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF1A3A6B),
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark_border_rounded),
                    label: 'حجوزاتي'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded), label: 'حسابي'),
              ],
            ),
          ),
        ),
        );
      },
        routes: [
          GoRoute(
            path: AppRoutes.clientHome,
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<HelperDiscoveryCubit>()..fetchHelpers()),
                BlocProvider.value(value: sl<AuthCubit>()),
              ],
              child: const ClientHomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.clientBookings,
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<ClientBookingsCubit>()),
                BlocProvider.value(value: sl<AuthCubit>()),
              ],
              child: const ClientBookingsScreen(),
            ),
          ),

          GoRoute(
            path: AppRoutes.clientProfile,
            builder: (context, state) => BlocProvider.value(
              value: sl<AuthCubit>(),
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),

      // ── Helper Shell ──────────────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: helperShellKey,
        builder: (context, state, child) {
          final user = context.read<AuthCubit>().state.user;
          return BlocProvider(
            create: (_) => sl<NotificationsCubit>()..watchNotifications(user?.id ?? ''),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: child,
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _getHelperIndex(state.uri.toString()),
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        context.go(AppRoutes.helperHome);
                        break;
                      case 1:
                        context.go(AppRoutes.helperBookings);
                        break;
                      case 2:
                        context.go(AppRoutes.helperProfile);
                        break;
                    }
                  },
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: const Color(0xFF00B5A3),
                  unselectedItemColor: Colors.grey,
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.assignment_outlined), label: 'طلباتي'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.person_rounded), label: 'حسابي'),
                  ],
                ),
              ),
            ),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.helperHome,
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<MyBookingsCubit>()),
                BlocProvider.value(value: sl<AuthCubit>()),
              ],
              child: const HelperHomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.helperBookings,
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<HelperBookingsCubit>()),
                BlocProvider.value(value: sl<AuthCubit>()),
              ],
              child: const HelperBookingsScreen(),
            ),
          ),

          GoRoute(
            path: AppRoutes.helperProfile,
            builder: (context, state) => BlocProvider.value(
              value: sl<AuthCubit>(),
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),

      // ── Admin ────────────────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: adminShellKey,
        builder: (context, state, child) {
          return BlocProvider(
            create: (_) => sl<AdminCubit>(),
            child: AdminShellScreen(child: child),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.adminPanel,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminDashboard,
            redirect: (context, state) => AppRoutes.adminPanel,
          ),
          GoRoute(
            path: AppRoutes.adminUsers,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<AdminUsersCubit>()..watchUsers(),
              child: const AdminUsersScreen(),
            ),
          ),
           GoRoute(
            path: AppRoutes.adminBookings,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<AdminBookingsCubit>()..watchAllBookings(),
              child: const AdminBookingsScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/helper-details',
            builder: (context, state) {
              final helper = state.extra as UserEntity;
              return AdminHelperDetailsScreen(helper: helper);
            },
          ),
        ],
      ),

      // ── Search & Helper Detail ────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          final specialty = state.uri.queryParameters['s'];
          return BlocProvider(
            create: (_) => sl<HelperDiscoveryCubit>()
              ..fetchHelpers(specialty: specialty, query: query),
            child: SearchResultsScreen(
              initialSearchQuery: query,
              initialSpecialty: specialty,
            ),
          );
        },
        routes: [
          GoRoute(
            path: ':helperId',
            builder: (context, state) {
              final helperId = state.pathParameters['helperId']!;
              return BlocProvider(
                create: (_) => sl<HelperDiscoveryCubit>()..watchHelperProfile(helperId),
                child: HelperProfileScreen(helperId: helperId),
              );
            },
          ),
        ],
      ),

      // ── Booking Steps ─────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.bookDateTime,
        builder: (context, state) {
          final HelperEntity helper;
          if (state.extra is HelperEntity) {
            helper = state.extra as HelperEntity;
          } else {
            // Fallback for deep linking or hot restart where extra is missing
            final uriParams = state.uri.queryParameters;
            helper = HelperEntity(
              id: uriParams['helperId'] ?? '',
              name: uriParams['helperName'] ?? '',
              hourlyRate: double.tryParse(uriParams['hourlyRate'] ?? '') ?? 0.0,
              profileImageUrl: '',
              rating: 0.0,
              reviewCount: 0,
              completedTasksCount: 0,
              distanceInKm: 0.0,
              isOnline: false,
              aboutMe: '',
              specialties: const [],
              serviceAreas: const [],
              verificationStatus: 'verified',
            );
          }

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<BookingCubit>()),
              BlocProvider.value(value: sl<AuthCubit>()),
            ],
            child: SendBookingRequestScreen(
              helper: helper,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookLocation,
        builder: (context, state) =>
            const PlaceholderScreen(screenName: 'حجز - خطوة 2: الموقع'),
      ),
      GoRoute(
        path: AppRoutes.bookTask,
        builder: (context, state) =>
            const PlaceholderScreen(screenName: 'حجز - خطوة 3: وصف المهمة'),
      ),
      GoRoute(
        path: AppRoutes.bookSummary,
        builder: (context, state) =>
            const PlaceholderScreen(screenName: 'حجز - خطوة 4: ملخص الطلب'),
      ),

      // ── Booking Status ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.bookingWaiting,
        builder: (context, state) =>
            const PlaceholderScreen(screenName: 'بانتظار رد المساعد (30 دقيقة)'),
      ),
      GoRoute(
        path: AppRoutes.bookingNegotiate,
        builder: (context, state) =>
            const PlaceholderScreen(screenName: 'التفاوض على السعر'),
      ),
      GoRoute(
        path: AppRoutes.bookingPayment,
        builder: (context, state) =>
            const PlaceholderScreen(screenName: 'الدفع وحجز المبلغ (Escrow)'),
      ),
      GoRoute(
        path: AppRoutes.bookingSuccess,
        builder: (context, state) =>
            const PlaceholderScreen(screenName: 'تم الحجز بنجاح'),
      ),
      GoRoute(
        path: '${AppRoutes.bookingTracking}/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BlocProvider(
            create: (_) => sl<BookingCubit>(),
            child: BookingDetailsScreen(bookingId: bookingId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookingActive,
        builder: (context, state) =>
            const PlaceholderScreen(screenName: 'الخدمة قائمة الآن'),
      ),
      GoRoute(
        path: AppRoutes.bookingConfirm,
        builder: (context, state) =>
            const PlaceholderScreen(screenName: 'تأكيد اكتمال الخدمة'),
      ),
      GoRoute(
        path: '${AppRoutes.bookingRate}/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? '';
          return BlocProvider(
            create: (_) => sl<BookingCubit>()..watchBooking(bookingId),
            child: RatingScreen(bookingId: bookingId),
          );
        },
      ),

      // ── Misc ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '${AppRoutes.chat}/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final extra = state.extra as Map<String, dynamic>?;
          final bookingId = extra?['bookingId'] as String? ?? chatId;
          final otherPartyId = extra?['otherPartyId'] as String? ?? '';
          final otherPartyName = extra?['otherPartyName'] as String? ?? '';
          final clientName = extra?['clientName'] as String? ?? 'العميل';
          final helperName = extra?['helperName'] as String? ?? 'المساعد';

          return BlocProvider(
            create: (_) => sl<ChatRoomCubit>(),
            child: ChatRoomScreen(
              chatId: chatId,
              bookingId: bookingId,
              otherPartyId: otherPartyId,
              otherPartyName: otherPartyName,
              clientName: clientName,
              helperName: helperName,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) {
          final user = context.read<AuthCubit>().state.user;
          return BlocProvider(
            create: (_) => sl<NotificationsCubit>()..watchNotifications(user?.id ?? ''),
            child: const NotificationsScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.emergencyContacts,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<EmergencyCubit>()),
            BlocProvider.value(value: sl<AuthCubit>()),
          ],
          child: const EmergencyContactsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.helperIncomingRequest,
        builder: (context, state) =>
            const PlaceholderScreen(screenName: 'الطلب الوارد وتفاصيل العرض'),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],
    );
    return router!;
  }

  static int _getClientIndex(String location) {
    if (location.startsWith(AppRoutes.clientBookings)) return 1;
    if (location.startsWith(AppRoutes.clientProfile)) return 2;
    return 0;
  }

  static int _getHelperIndex(String location) {
    if (location.startsWith(AppRoutes.helperBookings)) return 1;
    if (location.startsWith(AppRoutes.helperProfile)) return 2;
    return 0;
  }
}

// ── Splash Screen Widget ─────────────────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3A6B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 150,
            ),
            const SizedBox(height: 16),
            Text(
              'مساعدك الموثوق',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── GoRouter refreshListenable adapter ───────────────────────────────────────
class GoRouterNotifier extends ChangeNotifier {
  final AuthCubit authCubit;
  late final StreamSubscription<AuthState> _subscription;

  GoRouterNotifier(this.authCubit) {
    _subscription = authCubit.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
