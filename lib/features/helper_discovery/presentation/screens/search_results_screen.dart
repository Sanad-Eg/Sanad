import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:sanad/features/helper_discovery/domain/entities/helper_entity.dart';
import 'package:sanad/features/helper_discovery/presentation/cubit/helper_discovery_cubit.dart';
import 'package:sanad/features/helper_discovery/presentation/cubit/helper_discovery_state.dart';

class SearchResultsScreen extends StatefulWidget {
  final String? initialSearchQuery;
  final String? initialSpecialty;

  const SearchResultsScreen({
    super.key,
    this.initialSearchQuery,
    this.initialSpecialty,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _searchCtrl;
  String _selectedSpecialty = 'all';

  final List<Map<String, String>> _filterOptions = const [
    {'id': 'all', 'label': 'الكل 🌐'},
    {'id': 'mobility_assistance', 'label': 'مساعدة حركية 🦽'},
    {'id': 'visual_impairment', 'label': 'إعاقة بصرية 👁'},
    {'id': 'elderly_care', 'label': 'رعاية مسنين 👴'},
    {'id': 'home_tasks', 'label': 'أعمال منزلية 🏠'},
    {'id': 'companionship', 'label': 'مرافقة خارجية 🚶'},
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialSearchQuery);
    _selectedSpecialty = widget.initialSpecialty ?? 'all';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<HelperDiscoveryCubit>().fetchHelpers(
          query: _searchCtrl.text,
          specialty: _selectedSpecialty,
        );
  }

  void _onSpecialtySelected(String specialtyId) {
    setState(() {
      _selectedSpecialty = specialtyId;
    });
    context.read<HelperDiscoveryCubit>().fetchHelpers(
          query: _searchCtrl.text,
          specialty: specialtyId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          title: Text(
            'البحث عن المساعدين',
            style: AppTextStyles.heading3.copyWith(color: AppColors.surface),
          ),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => context.go(AppRoutes.clientHome),
          ),
        ),
        body: Column(
          children: [
            // Search Input Block
            _buildSearchInputSection(),

            // Specialty Filter Chips Row
            _buildFilterChipsSection(),

            // List Results
            Expanded(
              child: BlocBuilder<HelperDiscoveryCubit, HelperDiscoveryState>(
                builder: (context, state) {
                  if (state.status == HelperDiscoveryStatus.loading) {
                    return _buildLoadingSkeletonList();
                  }

                  if (state.status == HelperDiscoveryStatus.error) {
                    return _buildErrorState(state.errorMessage);
                  }

                  if (state.helpers.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: state.helpers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final helper = state.helpers[index];
                      return _buildHelperCard(helper);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInputSection() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchCtrl,
          textDirection: TextDirection.rtl,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _onSearchChanged(),
          style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'ابحث بالاسم أو الحي بالرياض...',
            hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textHint),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                    onPressed: () {
                      _searchCtrl.clear();
                      _onSearchChanged();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (_) {
            // Instant filter trigger for better user experience
            setState(() {});
            _onSearchChanged();
          },
        ),
      ),
    );
  }

  Widget _buildFilterChipsSection() {
    return Container(
      height: 60,
      color: AppColors.background,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: _filterOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final opt = _filterOptions[index];
          final isSelected = _selectedSpecialty == opt['id'];
          return ChoiceChip(
            label: Text(
              opt['label']!,
              style: AppTextStyles.body2.copyWith(
                color: isSelected ? AppColors.surface : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => _onSpecialtySelected(opt['id']!),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            checkmarkColor: AppColors.surface,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.textHint.withValues(alpha: 0.3),
            ),
          );
        },
      ),
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

            // Info
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

            // Cost
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

  Widget _buildLoadingSkeletonList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => Container(
        height: 104,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textHint.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 120, height: 16, color: Colors.grey[200]),
                    const SizedBox(height: 10),
                    Container(width: 180, height: 12, color: Colors.grey[200]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 72,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'عذراً، لم نجد نتائج تطابق بحثك',
            style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'حاول تغيير عبارة البحث أو اختيار تخصص آخر للعثور على المساعد المناسب.',
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () {
              _searchCtrl.clear();
              _onSpecialtySelected('all');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            child: Text(
              'إعادة ضبط البحث',
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              error ?? 'حدث خطأ غير متوقع',
              style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onSearchChanged,
              child: const Text('إعادة المحاولة'),
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
}
