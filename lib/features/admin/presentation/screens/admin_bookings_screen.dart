import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_bookings_cubit.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_bookings_state.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'معلق';
      case BookingStatus.negotiating:
        return 'قيد التفاوض';
      case BookingStatus.confirmed:
        return 'مقبول';
      case BookingStatus.inProgress:
        return 'قيد التنفيذ';
      case BookingStatus.confirmingCompletion:
        return 'تأكيد الاكتمال';
      case BookingStatus.completed:
        return 'مكتمل';
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
        return Colors.orange;
      case BookingStatus.negotiating:
        return Colors.blue;
      case BookingStatus.confirmed:
        return Colors.teal;
      case BookingStatus.inProgress:
        return AppColors.primary;
      case BookingStatus.confirmingCompletion:
        return Colors.indigo;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
      case BookingStatus.expired:
        return Colors.grey;
      case BookingStatus.disputed:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'مراقبة الطلبات',
            style: AppTextStyles.heading1,
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'النشطة'),
              Tab(text: 'المعلقة'),
              Tab(text: 'السجل'),
            ],
          ),
        ),
        body: BlocBuilder<AdminBookingsCubit, AdminBookingsState>(
          builder: (context, state) {
            if (state is AdminBookingsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is AdminBookingsError) {
              return Center(
                child: Text(
                  state.message,
                  style: AppTextStyles.body1.copyWith(color: AppColors.error),
                ),
              );
            }

            if (state is AdminBookingsLoaded) {
              final activeList = state.bookings.where((b) =>
                  b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.inProgress ||
                  b.status == BookingStatus.confirmingCompletion ||
                  b.status == BookingStatus.negotiating ||
                  b.status == BookingStatus.disputed).toList();

              final pendingList = state.bookings.where((b) =>
                  b.status == BookingStatus.pending).toList();

              final historyList = state.bookings.where((b) =>
                  b.status == BookingStatus.completed ||
                  b.status == BookingStatus.cancelled ||
                  b.status == BookingStatus.expired).toList();

              return TabBarView(
                children: [
                  _buildBookingList(context, activeList),
                  _buildBookingList(context, pendingList),
                  _buildBookingList(context, historyList),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, List<BookingEntity> bookings) {
    if (bookings.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد طلبات في هذا القسم',
          style: AppTextStyles.body1,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final formattedDate = intl.DateFormat('yyyy/MM/dd - hh:mm a').format(booking.startTime);
        final statusColor = _getStatusColor(booking.status);
        final statusLabel = _getStatusLabel(booking.status);
        
        final price = booking.agreedHourlyRate ?? booking.proposedHourlyRate;
        final totalAmount = booking.totalAmount;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.textHint.withValues(alpha: 0.2),
            ),
          ),
          color: AppColors.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              context.push('${AppRoutes.bookingTracking}/${booking.id}');
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking.taskDescription,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.heading3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.locationAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'السعر: $price جنيه/ساعة',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (totalAmount != null)
                        Text(
                          'الإجمالي: $totalAmount جنيه',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
