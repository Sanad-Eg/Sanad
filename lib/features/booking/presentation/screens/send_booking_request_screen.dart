import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:sanad/core/widgets/sanad_button.dart';
import 'package:sanad/core/widgets/sanad_text_field.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:sanad/features/booking/presentation/cubit/booking_state.dart';
import 'package:sanad/features/helper_discovery/domain/entities/helper_entity.dart';

class SendBookingRequestScreen extends StatefulWidget {
  final HelperEntity helper;

  const SendBookingRequestScreen({
    super.key,
    required this.helper,
  });

  @override
  State<SendBookingRequestScreen> createState() =>
      _SendBookingRequestScreenState();
}

class _SendBookingRequestScreenState extends State<SendBookingRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  int _selectedDuration = 2; // Default to 2 hours
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _taskCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  // ── Date Picker Helper ────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      locale: const Locale('ar', 'SA'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // ── Time Picker Helper ────────────────────────────────────────────────────
  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // ── Submit Logic ──────────────────────────────────────────────────────────
  void _submitRequest() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار تاريخ ووقت بدء الخدمة.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    final clientId = authState.user?.id ?? 'guest-client';

    // Combine picked Date and Time into a single DateTime
    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final endDateTime = startDateTime.add(Duration(hours: _selectedDuration));

    final bookingRequest = BookingEntity(
      id: '', // Will be assigned by Firestore Auto ID
      clientId: clientId,
      helperId: widget.helper.id,
      startTime: startDateTime,
      endTime: endDateTime,
      durationHours: _selectedDuration,
      latitude: 24.7136, // Default Riyadh Center Coordinates
      longitude: 46.6753,
      locationAddress: _locationCtrl.text.trim(),
      taskDescription: _taskCtrl.text.trim(),
      proposedHourlyRate: widget.helper.hourlyRate,
      agreedHourlyRate: widget.helper.hourlyRate,
      totalAmount: widget.helper.hourlyRate * _selectedDuration,
      status: BookingStatus.pending,
      negotiationRound: 0,
      createdAt: DateTime.now(),
      clientConfirmed: false,
      helperConfirmed: false,
    );

    context.read<BookingCubit>().sendRequest(bookingRequest);
  }

  @override
  Widget build(BuildContext context) {
    final totalCost = widget.helper.hourlyRate * _selectedDuration;
    final dateFormatter = intl.DateFormat('yyyy/MM/dd');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'طلب مساعدة جديد',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
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

            if (state.status == BookingCubitStatus.loaded &&
                state.booking != null) {
              // Successfully created booking - navigate to tracking page
              context.go('${AppRoutes.bookingTracking}/${state.booking!.id}');
            }
          },
          builder: (context, state) {
            final isLoading = state.status == BookingCubitStatus.loading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Helper Summary Card
                      _buildHelperCard(),
                      const SizedBox(height: 24),

                      // Task Description
                      SanadTextField(
                        controller: _taskCtrl,
                        label: 'وصف المهمة المطلوبة',
                        hint: 'مثال: أحتاج لمساعدتي في مرافقتي للمستشفى لشراء الأدوية.',
                        icon: Icons.edit_note_rounded,
                        maxLines: 3,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
                          if (v.length < 10) return 'الرجاء كتابة وصف تفصيلي (10 أحرف على الأقل)';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Location
                      SanadTextField(
                        controller: _locationCtrl,
                        label: 'عنوان اللقاء والمنزل',
                        hint: 'مثال: حي الصحافة، شارع العليا، الرياض',
                        icon: Icons.location_on_outlined,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date & Time Picker Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'تاريخ بدء الخدمة',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: isLoading ? null : _pickDate,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textPrimary,
                                    side: BorderSide(
                                      color: AppColors.textHint.withValues(alpha: 0.4),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.calendar_month_outlined,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  label: Text(
                                    _selectedDate != null
                                        ? dateFormatter.format(_selectedDate!)
                                        : 'اختر التاريخ',
                                    style: AppTextStyles.body2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'وقت البدء',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: isLoading ? null : _pickTime,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textPrimary,
                                    side: BorderSide(
                                      color: AppColors.textHint.withValues(alpha: 0.4),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.access_time_rounded,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  label: Text(
                                    _selectedTime != null
                                        ? _selectedTime!.format(context)
                                        : 'اختر الوقت',
                                    style: AppTextStyles.body2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Duration Selector
                      const Text(
                        'المدة الزمنية (بالساعات)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedDuration,
                        onChanged: isLoading
                            ? null
                            : (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedDuration = val;
                                  });
                                }
                              },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.textHint.withValues(alpha: 0.4),
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.timer_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        items: List.generate(
                          8,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text(
                              '${index + 1} ساعات',
                              style: AppTextStyles.body1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Financial Summary Section
                      _buildCostSection(totalCost),
                      const SizedBox(height: 32),

                      // Submit Button
                      SanadButton(
                        text: 'إرسال الطلب للموافقة',
                        onPressed: _submitRequest,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Helper Summary Component ─────────────────────────────────────────────
  Widget _buildHelperCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.helper.name,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أجر الساعة: ${widget.helper.hourlyRate.toInt()} جنيه / ساعة',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Pricing Breakdown Component ──────────────────────────────────────────
  Widget _buildCostSection(double totalCost) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textHint.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أجر المساعد بالساعة',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${widget.helper.hourlyRate.toInt()} جنيه',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المدة الزمنية',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$_selectedDuration ساعات',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع المقدر للخدمة',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${totalCost.toInt()} جنيه',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
