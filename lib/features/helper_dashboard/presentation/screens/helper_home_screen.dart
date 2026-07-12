import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_state.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/presentation/cubit/my_bookings_cubit.dart';
import 'package:sanad/features/booking/presentation/cubit/my_bookings_state.dart';
import 'package:sanad/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:sanad/features/notifications/presentation/cubit/notifications_state.dart';

class HelperHomeScreen extends StatefulWidget {
  const HelperHomeScreen({super.key});

  @override
  State<HelperHomeScreen> createState() => _HelperHomeScreenState();
}

class _HelperHomeScreenState extends State<HelperHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Retrieve helper user from AuthCubit and start watching their bookings
    final authState = context.read<AuthCubit>().state;
    final helperId = authState.user?.id;
    if (helperId != null) {
      context.read<MyBookingsCubit>().watchMyBookings(helperId, 'helper');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'لوحة تحكم المساعد',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, notifState) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                      onPressed: () {
                        context.push(AppRoutes.notifications);
                      },
                    ),
                    if (notifState.unreadCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.sos,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${notifState.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () {
                context.read<AuthCubit>().logout();
              },
            ),
          ],
        ),
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, authState) {
            if (authState.status == AuthStatus.unauthenticated) {
              context.go(AppRoutes.onboarding);
            }
          },
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final helperName = authState.user?.name ?? 'المساعد الموثوق';

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome & status header
                    _buildWelcomeHeader(helperName),
                    const SizedBox(height: 24),

                    Text(
                      'طلبات المساعدة الواردة',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Bookings list builder
                    Expanded(
                      child: BlocBuilder<MyBookingsCubit, MyBookingsState>(
                        builder: (context, state) {
                          if (state.status == MyBookingsStatus.loading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }

                          if (state.status == MyBookingsStatus.error) {
                            return Center(
                              child: Text(
                                state.errorMessage ?? 'حدث خطأ ما أثناء تحميل الطلبات',
                                style: AppTextStyles.body1.copyWith(color: AppColors.error),
                              ),
                            );
                          }

                          final bookings = state.bookings;

                          if (bookings.isEmpty) {
                            return _buildEmptyState();
                          }

                          return ListView.separated(
                            itemCount: bookings.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final booking = bookings[index];
                              return _buildBookingCard(booking);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
    );
  }

  // ── Welcome Header Component ─────────────────────────────────────────────
  Widget _buildWelcomeHeader(String helperName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF2C5E9E)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أهلاً بك، $helperName 👋',
            style: AppTextStyles.heading1.copyWith(color: AppColors.surface),
          ),
          const SizedBox(height: 6),
          Text(
            'أنت الآن متصل ومستعد لتقديم الدعم والمساندة لطلب المحتاجين.',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.surface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State Component ────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد طلبات مساعدة حالياً.',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'سيتم إعلامك فور إرسال أي طلب جديد في منطقتك.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Booking Card Component ───────────────────────────────────────────────
  Widget _buildBookingCard(BookingEntity booking) {
    final dateFormat = intl.DateFormat('yyyy/MM/dd');
    final timeFormat = intl.DateFormat('hh:mm a');

    final statusLabel = _getStatusLabel(booking.status);
    final statusColor = _getStatusColor(booking.status);

    return InkWell(
      onTap: () {
        context.go('${AppRoutes.bookingTracking}/${booking.id}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textHint.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status marker indicator line
            Container(
              width: 4,
              height: 72,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (booking.totalAmount != null)
                        Text(
                          '${booking.totalAmount!.toInt()} جنيه',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Task Description
                  Text(
                    booking.taskDescription,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Date Time & Location Summary
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(booking.startTime)} - ${timeFormat.format(booking.startTime)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.timer_outlined,
                        color: AppColors.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${booking.durationHours} ساعات',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ── Status Mappings helpers ──────────────────────────────────────────────
  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'بانتظار موافقتك';
      case BookingStatus.negotiating:
        return 'قيد التفاوض';
      case BookingStatus.confirmed:
        return 'مؤكد وبانتظار الدفع';
      case BookingStatus.inProgress:
        return 'قيد التنفيذ';
      case BookingStatus.confirmingCompletion:
        return 'بانتظار تأكيد الاكتمال';
      case BookingStatus.completed:
        return 'مكتمل';
      case BookingStatus.cancelled:
        return 'ملغي';
      case BookingStatus.expired:
        return 'منتهي';
      case BookingStatus.disputed:
        return 'نزاع نشط';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
      case BookingStatus.negotiating:
        return AppColors.warning;
      case BookingStatus.confirmed:
        return AppColors.primary;
      case BookingStatus.inProgress:
        return AppColors.secondary;
      case BookingStatus.confirmingCompletion:
        return Colors.purple;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
      case BookingStatus.expired:
        return AppColors.textSecondary;
      case BookingStatus.disputed:
        return AppColors.error;
    }
  }
}
