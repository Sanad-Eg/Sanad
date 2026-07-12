import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/widgets/sanad_button.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:sanad/features/booking/presentation/cubit/booking_state.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Start real-time Firestore synchronization for this booking
    context.read<BookingCubit>().watchBooking(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    final isHelper = context.read<AuthCubit>().state.user?.role == 'helper';
    final fallbackHome = isHelper ? AppRoutes.helperHome : AppRoutes.clientHome;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(fallbackHome);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'تفاصيل الطلب',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(fallbackHome);
                }
              },
            ),
          ),
          body: BlocConsumer<BookingCubit, BookingState>(
            listener: (context, state) {
              if (state.status == BookingCubitStatus.error &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.read<BookingCubit>().clearError();
              }
            },
            builder: (context, state) {
              if (state.status == BookingCubitStatus.loading &&
                  state.booking == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final booking = state.booking;

              if (booking == null) {
                return const Center(
                  child: Text(
                    'لم يتم العثور على تفاصيل الحجز.',
                    style: AppTextStyles.body1,
                  ),
                );
              }

              final isLoading = state.status == BookingCubitStatus.loading;

              // ── Derive the current user's role from UIDs ──────────────
              final authState = context.read<AuthCubit>().state;
              final currentUserId = authState.user?.id;
              final isClient = currentUserId == booking.clientId;
              final isHelper = currentUserId == booking.helperId;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      _buildStatusCard(booking.status),
                      const SizedBox(height: 12),

                      // Chat Button (only visible for confirmed, inProgress, confirmingCompletion, disputed, and only for participants)
                      if ((isClient || isHelper) &&
                          (booking.status == BookingStatus.confirmed ||
                           booking.status == BookingStatus.inProgress ||
                           booking.status == BookingStatus.confirmingCompletion ||
                           booking.status == BookingStatus.disputed)) ...[
                        _buildChatButton(context, booking, isClient),
                        const SizedBox(height: 20),
                      ],

                      // Booking Info Card
                      _buildDetailsCard(booking),
                      const SizedBox(height: 24),

                      // Actions Panel
                      _buildActionPanel(context, booking, isLoading, isClient, isHelper),
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

  // ── Chat Button ──────────────────────────────────────────────────────────
  Widget _buildChatButton(
    BuildContext context,
    BookingEntity booking,
    bool isClient,
  ) {
    final label = isClient ? 'محادثة المساعد' : 'محادثة العميل';
    final otherPartyId = isClient ? booking.helperId : booking.clientId;
    final currentUser = context.read<AuthCubit>().state.user;
    final currentUserName = currentUser?.name ?? '';

    // Pass empty string for names so Chat Room screen fetches the real name dynamically
    final clientName = isClient ? currentUserName : '';
    final helperName = isClient ? '' : currentUserName;
    const otherPartyName = '';

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          context.push(
            '${AppRoutes.chat}/${booking.id}',
            extra: {
              'bookingId': booking.id,
              'otherPartyId': otherPartyId,
              'otherPartyName': otherPartyName,
              'clientName': clientName,
              'helperName': helperName,
            },
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.chat_rounded, size: 20),
        label: Text(
          label,
          style: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }

  // ── Status Header Card ───────────────────────────────────────────────────
  Widget _buildStatusCard(BookingStatus status) {
    final statusLabel = _getStatusLabel(status);
    final statusColor = _getStatusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(status), color: statusColor, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حالة الطلب الحالية',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusLabel,
                  style: AppTextStyles.heading2.copyWith(
                    color: statusColor,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Details Card ──────────────────────────────────────────────────────────
  Widget _buildDetailsCard(BookingEntity booking) {
    final dateFormat = intl.DateFormat('yyyy/MM/dd');
    final timeFormat = intl.DateFormat('hh:mm a');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الخدمة',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24, thickness: 1),

          // Task Description
          _buildInfoRow(
            icon: Icons.description_outlined,
            title: 'المهمة المطلوبة',
            value: booking.taskDescription.isNotEmpty
                ? booking.taskDescription
                : 'غير محدد',
            isMultiLine: true,
          ),
          const SizedBox(height: 16),

          // Location
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            title: 'الموقع',
            value: booking.locationAddress.isNotEmpty
                ? booking.locationAddress
                : 'غير محدد',
            isMultiLine: true,
          ),
          const SizedBox(height: 16),

          // Date & Time
          _buildInfoRow(
            icon: Icons.calendar_month_outlined,
            title: 'التاريخ والوقت',
            value:
                '${dateFormat.format(booking.startTime)} \nمن ${timeFormat.format(booking.startTime)} إلى ${timeFormat.format(booking.endTime)}',
          ),
          const SizedBox(height: 16),

          // Duration
          _buildInfoRow(
            icon: Icons.timer_outlined,
            title: 'المدة الزمنية',
            value: '${booking.durationHours} ساعات',
          ),
          const SizedBox(height: 16),

          // Pricing
          _buildInfoRow(
            icon: Icons.payments_outlined,
            title: 'الأجر المتفق عليه',
            value: (booking.status == BookingStatus.negotiating)
                ? '${booking.proposedHourlyRate.toInt()} جنيه / ساعة (سعر التفاوض الجديد)'
                : (booking.agreedHourlyRate != null
                    ? '${booking.agreedHourlyRate!.toInt()} جنيه / ساعة'
                    : '${booking.proposedHourlyRate.toInt()} جنيه / ساعة (سعر مقترح)'),
          ),

          if (booking.status == BookingStatus.negotiating || booking.totalAmount != null) ...[
            const Divider(height: 32, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.status == BookingStatus.negotiating
                      ? 'المبلغ الإجمالي المقترح'
                      : 'المبلغ الإجمالي',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  booking.status == BookingStatus.negotiating
                      ? '${(booking.proposedHourlyRate * booking.durationHours).toInt()} جنيه'
                      : '${booking.totalAmount?.toInt() ?? 0} جنيه',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Info Row Builder ──────────────────────────────────────────────────────
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiLine
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Action Panel ──────────────────────────────────────────────────────────
  Widget _buildActionPanel(
    BuildContext context,
    BookingEntity booking,
    bool isLoading,
    bool isClient,
    bool isHelper,
  ) {
    final cubit = context.read<BookingCubit>();

    // ── 1. PENDING: Helper sees Accept/Negotiate/Reject. Client sees Cancel ──
    if (booking.status == BookingStatus.pending) {
      if (isClient) {
        // CLIENT: waiting state + cancel button only — no Accept button
        return Column(
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'بانتظار قبول الطلب من قبل المساعد.',
                  style: AppTextStyles.body1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : () => cubit.reject(booking.id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 20),
                label: const Text('إلغاء الطلب', style: AppTextStyles.button),
              ),
            ),
          ],
        );
      }
      if (isHelper) {
        // HELPER: Accept / Counter Offer / Reject
        return Column(
          children: [
            SanadButton(
              text: 'قبول الطلب',
              backgroundColor: AppColors.success,
              isLoading: isLoading,
              onPressed: () => _showAcceptDialog(context, booking),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _showCounterOfferDialog(context, booking),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    icon: const Icon(Icons.edit_note_rounded, size: 20),
                    label: const Text(
                      'تقديم عرض سعر',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : () => cubit.reject(booking.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 20),
                    label: const Text('رفض الطلب', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ],
        );
      }
      return const SizedBox.shrink(); // safety fallback
    }

    // ── 2. NEGOTIATING: Client sees Accept/Reject Offer. Helper waits ─────────
    if (booking.status == BookingStatus.negotiating) {
      if (isClient) {
        // CLIENT: Accept or reject the helper's proposed price
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'السعر المقترح الجديد: ${booking.proposedHourlyRate.toInt()} جنيه / ساعة',
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[850],
                    ),
                  ),
                ],
              ),
            ),
            SanadButton(
              text: 'قبول العرض',
              backgroundColor: AppColors.success,
              isLoading: isLoading,
              onPressed: () => cubit.accept(booking.id, booking.proposedHourlyRate),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : () => cubit.reject(booking.id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 20),
                label: const Text('رفض العرض', style: AppTextStyles.button),
              ),
            ),
          ],
        );
      }
      if (isHelper) {
        // HELPER: waiting for client's response
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'تم إرسال عرض السعر البديل وبانتظار رد العميل.',
              style: AppTextStyles.body1,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    // ── 3. CONFIRMED: Client pays (or Helper starts task/marks active) ────────
    if (booking.status == BookingStatus.confirmed) {
      if (isClient) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SanadButton(
              text: 'دفع ومباشرة الخدمة',
              backgroundColor: AppColors.primary,
              isLoading: isLoading,
              onPressed: () => cubit.pay(booking.id),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'سيتم حجز المبلغ بأمان في حساب الضمان حتى اكتمال الخدمة.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      }
      if (isHelper) {
        return Column(
          children: [
            SanadButton(
              text: 'بدء الخدمة', // "Start Task" / "Mark Active"
              backgroundColor: AppColors.primary,
              isLoading: isLoading,
              onPressed: () => cubit.pay(booking.id),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'تأكيد بدء تقديم الخدمة للعميل ومباشرة العمل.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    }

    // ── 4. ACTIVE / IN-PROGRESS: Helper marks completed. Client waits ────────
    if (booking.status == BookingStatus.inProgress) {
      if (isHelper) {
        return Column(
          children: [
            SanadButton(
              text: 'تأكيد اكتمال الخدمة', // "Mark as Completed"
              backgroundColor: AppColors.secondary,
              isLoading: isLoading,
              onPressed: () => cubit.confirm(booking.id, isClient: false),
            ),
            const SizedBox(height: 12),
            _buildConfirmationProgress(booking),
          ],
        );
      }
      if (isClient) {
        return Column(
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'الخدمة قيد التنفيذ حالياً من قبل المساعد.',
                  style: AppTextStyles.body1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildConfirmationProgress(booking),
          ],
        );
      }
      return const SizedBox.shrink();
    }

    // ── 4.5. CONFIRMING COMPLETION: Client confirms completion. Helper waits ──
    if (booking.status == BookingStatus.confirmingCompletion) {
      if (isClient) {
        final hasClientConfirmed = booking.clientConfirmed;
        if (hasClientConfirmed) {
          return Column(
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'بانتظار تأكيد المساعد لاكتمال الخدمة.',
                    style: AppTextStyles.body1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildConfirmationProgress(booking),
            ],
          );
        }
        return Column(
          children: [
            SanadButton(
              text: 'تأكيد اكتمال الخدمة',
              backgroundColor: AppColors.secondary,
              isLoading: isLoading,
              onPressed: () => cubit.confirm(booking.id, isClient: true),
            ),
            const SizedBox(height: 12),
            _buildConfirmationProgress(booking),
          ],
        );
      }
      if (isHelper) {
        return Column(
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'بانتظار تأكيد العميل لاكتمال الخدمة.',
                  style: AppTextStyles.body1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildConfirmationProgress(booking),
          ],
        );
      }
      return const SizedBox.shrink();
    }

    // ── 5. Terminal states: completed / cancelled / other ─────────────────────
    if (booking.status == BookingStatus.completed && isClient) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'تم إكمال الخدمة بنجاح. ✅',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const Key('rate_helper_button'),
              onPressed: () => context.push(
                '${AppRoutes.bookingRate}/${booking.id}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.star_rounded, size: 20),
              label: const Text('تقييم المساعد', style: AppTextStyles.button),
            ),
          ),
        ],
      );
    }

    return Center(
      child: Text(
        booking.status == BookingStatus.completed
            ? 'تم إكمال الخدمة بنجاح. ✅'
            : booking.status == BookingStatus.cancelled
            ? 'تم إلغاء هذا الطلب.'
            : 'لا توجد إجراءات مطلوبة حالياً.',
        style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }


  // ── Dual-Confirmation Progress Indicator ─────────────────────────────────
  Widget _buildConfirmationProgress(BookingEntity booking) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textHint.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildConfirmParty(
              label: 'العميل',
              icon: Icons.person_outline_rounded,
              confirmed: booking.clientConfirmed,
            ),
          ),
          Column(
            children: [
              Icon(
                Icons.handshake_outlined,
                color: (booking.clientConfirmed && booking.helperConfirmed)
                    ? AppColors.success
                    : AppColors.textHint,
                size: 24,
              ),
            ],
          ),
          Expanded(
            child: _buildConfirmParty(
              label: 'المساعد',
              icon: Icons.support_agent_rounded,
              confirmed: booking.helperConfirmed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmParty({
    required String label,
    required IconData icon,
    required bool confirmed,
  }) {
    final color = confirmed ? AppColors.success : AppColors.textHint;
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Icon(
          confirmed
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: color,
          size: 18,
        ),
      ],
    );
  }

  // ── Counter Offer Dialog ──────────────────────────────────────────────────
  void _showCounterOfferDialog(BuildContext context, BookingEntity booking) {
    final controller = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'تقديم عرض سعر بديل',
            style: AppTextStyles.heading2,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'سعر الساعة الجديد (جنيه / ساعة)',
                  hintText: 'مثال: 50',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظة للمستفيد',
                  hintText: 'اكتب سبب تغيير السعر هنا...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final rate = double.tryParse(controller.text.trim());
                if (rate != null && rate > 0) {
                  context.read<BookingCubit>().submitCounterOffer(
                    bookingId: booking.id,
                    newPrice: rate,
                    note: noteController.text.trim(),
                  );
                  Navigator.pop(dialogCtx);
                }
              },
              child: const Text('تقديم العرض'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Accept Dialog ─────────────────────────────────────────────────────────
  void _showAcceptDialog(BuildContext context, BookingEntity booking) {
    final originalPrice = booking.proposedHourlyRate;
    final totalAmount = originalPrice * booking.durationHours;

    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'قبول الطلب',
            style: AppTextStyles.heading2,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'هل أنت متأكد من قبول هذا الطلب بالسعر المعروض؟',
                style: AppTextStyles.body1,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('سعر الساعة:', style: AppTextStyles.body2),
                  Text(
                    '${originalPrice.toInt()} جنيه / ساعة',
                    style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المدة الزمنية:', style: AppTextStyles.body2),
                  Text(
                    '${booking.durationHours} ساعات',
                    style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المبلغ الإجمالي:',
                    style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${totalAmount.toInt()} جنيه',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              key: const Key('agreed_price_submit'),
              onPressed: () {
                context.read<BookingCubit>().accept(booking.id, originalPrice);
                Navigator.pop(dialogCtx);
              },
              child: const Text('تأكيد القبول'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status Helper Mappings ────────────────────────────────────────────────
  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'بانتظار رد المساعد';
      case BookingStatus.negotiating:
        return 'المساعد قدم عرض سعر جديد';
      case BookingStatus.confirmed:
        return 'مؤكد وبانتظار الدفع';
      case BookingStatus.inProgress:
        return 'قيد التنفيذ (نشط)';
      case BookingStatus.confirmingCompletion:
        return 'بانتظار تأكيد الاكتمال';
      case BookingStatus.completed:
        return 'مكتمل بنجاح';
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

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.hourglass_top_rounded;
      case BookingStatus.negotiating:
        return Icons.swap_horiz_rounded;
      case BookingStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case BookingStatus.inProgress:
        return Icons.play_circle_outline_rounded;
      case BookingStatus.confirmingCompletion:
        return Icons.published_with_changes_rounded;
      case BookingStatus.completed:
        return Icons.verified_rounded;
      case BookingStatus.cancelled:
      case BookingStatus.expired:
        return Icons.block_rounded;
      case BookingStatus.disputed:
        return Icons.gavel_rounded;
    }
  }
}
