import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:sanad/core/widgets/sanad_button.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/injection_container.dart';
import 'package:sanad/features/helper_discovery/domain/usecases/get_helper_reviews_usecase.dart';
import 'package:sanad/features/helper_discovery/domain/entities/review_entity.dart';
import 'package:sanad/features/helper_discovery/presentation/cubit/helper_discovery_cubit.dart';
import 'package:sanad/features/helper_discovery/presentation/cubit/helper_discovery_state.dart';

class HelperProfileScreen extends StatelessWidget {
  final String helperId;

  const HelperProfileScreen({super.key, required this.helperId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          title: const Text('الملف الشخصي للمساعد'),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.search);
              }
            },
          ),
        ),
        body: BlocBuilder<HelperDiscoveryCubit, HelperDiscoveryState>(
          builder: (context, state) {
            if (state.status == HelperDiscoveryStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.status == HelperDiscoveryStatus.error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage ?? 'حدث خطأ في تحميل ملف المساعد',
                    style: AppTextStyles.body1.copyWith(color: AppColors.error),
                  ),
                ),
              );
            }

            final helper = state.selectedHelper;
            if (helper == null) {
              return Center(
                child: Text(
                  'لم يتم العثور على المساعد.',
                  style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Helper Main Card (Avatar, Name, Badge, Availability)
                        _buildMainInfoCard(helper),
                        const SizedBox(height: 20),

                        // Stats Row
                        _buildStatsRow(helper),
                        const SizedBox(height: 24),

                        // Specialties
                        _buildSpecialtiesSection(helper),
                        const SizedBox(height: 24),

                        // About Me
                        _buildAboutMeSection(helper),
                        const SizedBox(height: 24),

                        // Service Areas
                        _buildServiceAreasSection(helper),
                        const SizedBox(height: 24),

                        // Ratings & Reviews Section
                        _buildReviewsSection(context, helper.id),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Call-to-action Bar
                _buildBottomActionBar(context, helper),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainInfoCard(helper) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textHint.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          // Avatar with online status indicator
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: helper.profileImageUrl.isNotEmpty
                    ? Image.network(
                        helper.profileImageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: AppColors.primaryLight,
                          child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 50),
                        ),
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 50),
                      ),
              ),
              if (helper.isOnline)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 3),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Name and Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                helper.name,
                style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified_rounded, color: AppColors.secondary, size: 20),
            ],
          ),
          const SizedBox(height: 6),

          // Role subtitle
          Text(
            'مساعد معتمد وموثق بهوية سند',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                (helper.rating == 0.0 || helper.reviewCount == 0)
                    ? 'جديد'
                    : '${helper.rating.toStringAsFixed(1)} (${helper.reviewCount} تقييم)',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(helper) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textHint.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Icons.star_rounded,
            iconColor: AppColors.warning,
            value: helper.rating == 0.0 ? 'جديد' : helper.rating.toStringAsFixed(1),
            label: '${helper.reviewCount} تقييم',
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.secondary,
            value: '${helper.completedTasksCount}',
            label: 'مهمة منجزة',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.textHint.withValues(alpha: 0.2),
    );
  }

  Widget _buildSpecialtiesSection(helper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التخصصات والخدمات',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: helper.specialties.map<Widget>((s) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Text(
                _getSpecialtyArabicName(s),
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAboutMeSection(helper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نبذة عن المساعد',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.textHint.withValues(alpha: 0.15)),
          ),
          child: Text(
            helper.aboutMe,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceAreasSection(helper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مناطق تغطية الخدمة',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: helper.serviceAreas.map<Widget>((area) {
            return Chip(
              label: Text(
                area,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              backgroundColor: AppColors.surface,
              side: BorderSide(color: AppColors.textHint.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context, helper) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.textHint.withValues(alpha: 0.15)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Pricing info
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التكلفة التقديرية',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${helper.hourlyRate.toInt()} جنيه',
                        style: AppTextStyles.heading1.copyWith(color: AppColors.primary, fontSize: 24),
                      ),
                      Text(
                        ' / ساعة',
                        style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Book Button
            SizedBox(
              width: 160,
              child: SanadButton(
                text: 'طلب حجز',
                backgroundColor: AppColors.primary,
                onPressed: () {
                  // Direct to Book Step 1 — pass helper data via extra
                  context.push(
                    AppRoutes.bookDateTime,
                    extra: helper,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSpecialtyArabicName(String key) {
    switch (key) {
      case 'mobility_assistance':
        return 'مساعدة حركية';
      case 'visual_impairment':
        return 'إعاقة بصرية';
      case 'elderly_care':
        return 'رعاية كبار السن';
      case 'home_tasks':
        return 'أعمال منزلية';
      case 'companionship':
        return 'مرافقة خارجية';
      default:
        return 'مساعدة عامة';
    }
  }

  Widget _buildReviewsSection(BuildContext context, String helperId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التقييمات والتعليقات',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        StreamBuilder<Either<Failure, List<ReviewEntity>>>(
          stream: sl<GetHelperReviewsUseCase>().call(helperId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            if (!snapshot.hasData) {
              return _buildEmptyReviewsState();
            }

            final result = snapshot.data!;
            return result.fold(
              (failure) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'حدث خطأ في تحميل التعليقات',
                    style: AppTextStyles.body2.copyWith(color: AppColors.error),
                  ),
                ),
              ),
              (reviews) {
                if (reviews.isEmpty) {
                  return _buildEmptyReviewsState();
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.textHint.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  review.clientName.isNotEmpty
                                      ? review.clientName[0].toUpperCase()
                                      : 'ع',
                                  style: AppTextStyles.body1.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  review.clientName.isNotEmpty
                                      ? review.clientName
                                      : 'عميل',
                                  style: AppTextStyles.body1.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: AppColors.warning, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    review.rating.toStringAsFixed(1),
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (review.reviewText.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              review.reviewText,
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyReviewsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textHint.withValues(alpha: 0.15)),
      ),
      child: Center(
        child: Text(
          'لا توجد تعليقات حتى الآن',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
