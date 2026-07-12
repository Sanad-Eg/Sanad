import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_state.dart';
import 'package:sanad/features/helper_discovery/domain/entities/helper_entity.dart';
import 'package:sanad/features/helper_discovery/presentation/cubit/helper_discovery_cubit.dart';
import 'package:sanad/features/helper_discovery/presentation/cubit/helper_discovery_state.dart';
import 'package:sanad/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:sanad/features/notifications/presentation/cubit/notifications_state.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      context.go('${AppRoutes.search}?q=${Uri.encodeComponent(query.trim())}');
    }
  }

  void _onCategoryTapped(String specialty) {
    context.go('${AppRoutes.search}?s=$specialty');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => context.read<HelperDiscoveryCubit>().fetchHelpers(),
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSearchBox(),
                  const SizedBox(height: 28),
                  _buildCategoriesSection(),
                  const SizedBox(height: 28),
                  _buildTopHelpersSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final name = authState.user?.name ?? 'زائرنا الكريم';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً بك، $name 👋',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'كيف يمكننا مساعدتك اليوم؟',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Notification Bell with Badge
                BlocBuilder<NotificationsCubit, NotificationsState>(
                  builder: (context, notifState) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.primary,
                            size: 28,
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
                const SizedBox(width: 8),
                // Profile image / placeholder circle
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        textDirection: TextDirection.rtl,
        textInputAction: TextInputAction.search,
        onSubmitted: _onSearchSubmitted,
        style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'البحث عن مساعد أو حي بالرياض...',
          hintStyle: AppTextStyles.body1.copyWith(color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 24),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
            onPressed: () => context.go(AppRoutes.search),
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final List<Map<String, dynamic>> categories = [
      {
        'id': 'mobility_assistance',
        'title': 'مساعدة حركية',
        'icon': Icons.accessible_rounded,
        'color': const Color(0xFF00B5A3),
        'bgColor': const Color(0xFFE0F7F5),
      },
      {
        'id': 'visual_impairment',
        'title': 'إعاقة بصرية',
        'icon': Icons.visibility_rounded,
        'color': const Color(0xFF1A3A6B),
        'bgColor': const Color(0xFFE8EDF5),
      },
      {
        'id': 'elderly_care',
        'title': 'رعاية مسنين',
        'icon': Icons.elderly_rounded,
        'color': const Color(0xFFF59E0B),
        'bgColor': const Color(0xFFFEF3C7),
      },
      {
        'id': 'home_tasks',
        'title': 'أعمال منزلية',
        'icon': Icons.home_repair_service_rounded,
        'color': const Color(0xFFEC4899),
        'bgColor': const Color(0xFFFCE7F3),
      },
      {
        'id': 'companionship',
        'title': 'مرافقة خارجية',
        'icon': Icons.directions_walk_rounded,
        'color': const Color(0xFF8B5CF6),
        'bgColor': const Color(0xFFEDE9FE),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أقسام الخدمات',
          style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return InkWell(
                onTap: () => _onCategoryTapped(cat['id']),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.textHint.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cat['bgColor'],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(cat['icon'], color: cat['color'], size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['title'],
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopHelpersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المساعدون الأعلى تقييماً',
              style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.search),
              child: Text(
                'عرض الكل',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<HelperDiscoveryCubit, HelperDiscoveryState>(
          builder: (context, state) {
            if (state.status == HelperDiscoveryStatus.loading) {
              return _buildShimmerHelpers();
            }

            if (state.status == HelperDiscoveryStatus.error) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(state.errorMessage ?? 'حدث خطأ أثناء تحميل البيانات'),
                ),
              );
            }

            final topHelpers = state.helpers.toList()
              ..sort((a, b) => b.rating.compareTo(a.rating));

            if (topHelpers.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.people_outline_rounded, size: 48, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    Text(
                      'لا يوجد مساعدون متاحون حالياً.',
                      style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topHelpers.take(3).length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final helper = topHelpers[index];
                return _buildHelperCard(helper);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildHelperCard(HelperEntity helper) {
    return InkWell(
      onTap: () => context.go('${AppRoutes.search}/${helper.id}'),
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
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: helper.profileImageUrl.isNotEmpty
                  ? Image.network(
                      helper.profileImageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72,
                        height: 72,
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 36),
                      ),
                    )
                  : Container(
                      width: 72,
                      height: 72,
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 36),
                    ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        helper.name,
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded, color: AppColors.secondary, size: 16),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    helper.specialties.map((s) => _getSpecialtyArabicName(s)).join(' • '),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        (helper.rating == 0.0 || helper.reviewCount == 0)
                            ? '⭐ جديد'
                            : '⭐ ${helper.rating.toStringAsFixed(1)} (${helper.reviewCount} تقييم)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Pricing & Navigation arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${helper.hourlyRate.toInt()} جنيه',
                  style: AppTextStyles.heading3.copyWith(color: AppColors.primary, fontSize: 16),
                ),
                Text(
                  '/ ساعة',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                ),
                const SizedBox(height: 10),
                const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerHelpers() {
    return Column(
      children: List.generate(2, (index) => Container(
        height: 104,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textHint.withValues(alpha: 0.15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(width: 72, height: 72, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 100, height: 16, color: Colors.grey[200]),
                    const SizedBox(height: 10),
                    Container(width: 150, height: 12, color: Colors.grey[200]),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
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
}
