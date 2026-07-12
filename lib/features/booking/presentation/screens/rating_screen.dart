import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:sanad/features/booking/presentation/cubit/booking_state.dart';

class RatingScreen extends StatefulWidget {
  final String bookingId;

  const RatingScreen({super.key, required this.bookingId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _selectedStars = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: const Text(
            'تقييم المساعد',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<BookingCubit, BookingState>(
          listener: (context, state) {
            if (_isSubmitting && state.status == BookingCubitStatus.loaded) {
              setState(() {
                _isSubmitting = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('شكراً! تم إرسال تقييمك.'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.pop();
            }
            if (_isSubmitting && state.status == BookingCubitStatus.error) {
              setState(() {
                _isSubmitting = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'حدث خطأ أثناء إرسال التقييم'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == BookingCubitStatus.loading && state.booking == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.status == BookingCubitStatus.error && state.booking == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage ?? 'حدث خطأ في تحميل بيانات الحجز',
                    style: AppTextStyles.body1.copyWith(color: AppColors.error),
                  ),
                ),
              );
            }

            final booking = state.booking;
            if (booking == null) {
              return Center(
                child: Text(
                  'لم يتم العثور على الحجز.',
                  style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // ── Rating Icon ─────────────────────────────────────────────
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: AppColors.warning,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Title ────────────────────────────────────────────────────
                  Text(
                    'كيف كانت تجربتك مع المساعد؟',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'رأيك يساعدنا على تحسين الخدمة',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // ── Star Selector ─────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _selectedStars == 0
                              ? 'اختر تقييمك'
                              : _starLabel(_selectedStars),
                          style: AppTextStyles.body1.copyWith(
                            color: _selectedStars == 0
                                ? AppColors.textHint
                                : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starIndex = index + 1;
                            return IconButton(
                              key: Key('star_$starIndex'),
                              onPressed: () {
                                setState(() {
                                  _selectedStars = starIndex;
                                });
                              },
                              icon: Icon(
                                starIndex <= _selectedStars
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: starIndex <= _selectedStars
                                    ? AppColors.warning
                                    : AppColors.textHint,
                                size: 42,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              constraints: const BoxConstraints(),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Review TextField ──────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _reviewController,
                      maxLines: 4,
                      style: AppTextStyles.body1
                          .copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'اكتب تعليقك هنا...',
                        hintStyle: AppTextStyles.body2
                            .copyWith(color: AppColors.textHint),
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Submit Button ─────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('submit_rating_button'),
                      onPressed: _selectedStars == 0 || _isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _isSubmitting = true;
                              });
                              context.read<BookingCubit>().submitRatingAndReview(
                                    bookingId: widget.bookingId,
                                    helperId: booking.helperId,
                                    clientId: booking.clientId,
                                    rating: _selectedStars.toDouble(),
                                    reviewText: _reviewController.text.trim(),
                                  );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.textHint.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'إرسال التقييم',
                              style: AppTextStyles.button,
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Skip Link ─────────────────────────────────────────────────
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'تخطي الآن',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _starLabel(int stars) {
    switch (stars) {
      case 1:
        return 'سيء جداً';
      case 2:
        return 'سيء';
      case 3:
        return 'مقبول';
      case 4:
        return 'جيد';
      case 5:
        return 'ممتاز';
      default:
        return '';
    }
  }
}
