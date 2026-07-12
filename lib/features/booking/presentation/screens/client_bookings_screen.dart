import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/presentation/cubit/client_bookings_cubit.dart';
import 'package:sanad/features/booking/presentation/cubit/client_bookings_state.dart';

class ClientBookingsScreen extends StatefulWidget {
  const ClientBookingsScreen({super.key});

  @override
  State<ClientBookingsScreen> createState() => _ClientBookingsScreenState();
}

class _ClientBookingsScreenState extends State<ClientBookingsScreen> {
  @override
  void initState() {
    super.initState();
    final clientId = context.read<AuthCubit>().state.user?.id;
    if (clientId != null) {
      context.read<ClientBookingsCubit>().watchClientBookings(clientId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'حجوزاتي',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            bottom: const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'الطلبات النشطة'),
                Tab(text: 'السجل'),
              ],
            ),
          ),
          body: BlocBuilder<ClientBookingsCubit, ClientBookingsState>(
            builder: (context, state) {
              if (state is ClientBookingsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state is ClientBookingsError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.error, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          style: AppTextStyles.body1
                              .copyWith(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is ClientBookingsLoaded) {
                final allBookings = state.bookings;

                // Filter Active Tab: status == pending || negotiating || confirmed || inProgress || confirmingCompletion || disputed
                final activeBookings = allBookings.where((b) =>
                    b.status == BookingStatus.pending ||
                    b.status == BookingStatus.negotiating ||
                    b.status == BookingStatus.confirmed ||
                    b.status == BookingStatus.inProgress ||
                    b.status == BookingStatus.confirmingCompletion ||
                    b.status == BookingStatus.disputed).toList();

                // Filter History Tab: status == completed || rejected || cancelled || expired
                final historyBookings = allBookings.where((b) =>
                    b.status == BookingStatus.completed ||
                    b.status == BookingStatus.cancelled ||
                    b.status == BookingStatus.expired).toList();

                return TabBarView(
                  children: [
                    _buildBookingsList(activeBookings, 'النشطة'),
                    _buildBookingsList(historyBookings, 'السجل'),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<BookingEntity> bookings, String tabLabel) {
    if (bookings.isEmpty) {
      return _buildEmptyState(tabLabel);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) =>
          _BookingCard(booking: bookings[index]),
    );
  }

  Widget _buildEmptyState(String tabLabel) {
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
              Icons.calendar_today_outlined,
              color: AppColors.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد حجوزات في $tabLabel',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ستظهر هنا حجوزاتك بمجرد إنشائها.',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Booking Card ─────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final BookingEntity booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormat = intl.DateFormat('yyyy/MM/dd');
    final timeFormat = intl.DateFormat('hh:mm a');
    final statusLabel = _getStatusLabel(booking.status);
    final statusColor = _getStatusColor(booking.status);

    return InkWell(
      onTap: () => context.push('${AppRoutes.bookingTracking}/${booking.id}'),
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
            // Status colour accent bar
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),

            // Card body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge + amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
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
                        )
                      else if (booking.status == BookingStatus.negotiating)
                        Text(
                          '${(booking.proposedHourlyRate * booking.durationHours).toInt()} جنيه (مقترح)',
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.orange[850],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Task description
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

                  // Helper ID + date row
                  Row(
                    children: [
                      const Icon(Icons.support_agent_rounded,
                          color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'المساعد: ${booking.helperId}',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined,
                          color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(booking.startTime)} - ${timeFormat.format(booking.startTime)}',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'بانتظار رد المساعد';
      case BookingStatus.negotiating:
        return 'عرض سعر جديد';
      case BookingStatus.confirmed:
        return 'مؤكد - بانتظار الدفع';
      case BookingStatus.inProgress:
        return 'قيد التنفيذ';
      case BookingStatus.confirmingCompletion:
        return 'بانتظار تأكيد الاكتمال';
      case BookingStatus.completed:
        return 'مكتمل ✅';
      case BookingStatus.cancelled:
        return 'ملغي';
      case BookingStatus.expired:
        return 'منتهي الصلاحية';
      case BookingStatus.disputed:
        return 'قيد النزاع';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.negotiating:
        return Colors.orange;
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
