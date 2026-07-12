import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_state.dart';
import 'package:sanad/features/auth/domain/entities/user_entity.dart';

class AdminHelperDetailsScreen extends StatelessWidget {
  final UserEntity helper;

  const AdminHelperDetailsScreen({super.key, required this.helper});

  void _confirmReject(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('رفض طلب الانضمام', style: AppTextStyles.heading2),
          content: Text(
            'هل أنت متأكد من رفض طلب انضمام المساعد "${helper.name}"؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                Navigator.pop(dialogCtx);
                context.read<AdminCubit>().verifyHelper(helper.id, false);
              },
              child: const Text('رفض الطلب'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmApprove(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('قبول طلب الانضمام', style: AppTextStyles.heading2),
          content: Text(
            'هل أنت متأكد من قبول وتفعيل حساب المساعد "${helper.name}"؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.success),
              onPressed: () {
                Navigator.pop(dialogCtx);
                context.read<AdminCubit>().verifyHelper(helper.id, true);
              },
              child: const Text('تفعيل الحساب'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminCubit, AdminState>(
      listener: (context, state) {
        // When action succeeds and helper is no longer in pending list (or status success), navigate back.
        // We can check if the helper is still in the pendingHelpers list.
        final isStillPending = state.pendingHelpers.any((h) => h.id == helper.id);
        if (!isStillPending && !state.isActionLoading && state.status == AdminStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث حالة المساعد بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
        if (state.status == AdminStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('تفاصيل طلب المساعد', style: TextStyle(fontWeight: FontWeight.bold)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile Overview Card ─────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.textHint.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: ClipOval(
                              child: helper.profileImageUrl != null && helper.profileImageUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: helper.profileImageUrl!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => _buildAvatarPlaceholder(),
                                    )
                                  : _buildAvatarPlaceholder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            helper.name,
                            style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'قيد المراجعة ⏳',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(height: 32, thickness: 1),
                          _buildDetailRow(Icons.phone_outlined, 'رقم الجوال', helper.phone),
                          const SizedBox(height: 12),
                          _buildDetailRow(Icons.email_outlined, 'البريد الإلكتروني', helper.email),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Verification Documents ────────────────────────────────
                    const Text('المستندات الثبوتية', style: AppTextStyles.heading2),
                    const SizedBox(height: 16),

                    _buildDocumentCard(
                      label: 'صورة الهوية الوطنية (الأمام)',
                      imageUrl: helper.idFrontUrl,
                    ),
                    const SizedBox(height: 16),

                    _buildDocumentCard(
                      label: 'صورة الهوية الوطنية (الخلف)',
                      imageUrl: helper.idBackUrl,
                    ),
                    const SizedBox(height: 16),

                    _buildDocumentCard(
                      label: 'صورة شخصية مع الهوية',
                      imageUrl: helper.selfieUrl,
                    ),
                  ],
                ),
              ),

              // ── Action Buttons (Fixed Bottom) ───────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmApprove(context),
                          icon: const Icon(Icons.check_rounded, color: Colors.white),
                          label: const Text(
                            'قبول وتفعيل',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmReject(context),
                          icon: const Icon(Icons.close_rounded, color: AppColors.error),
                          label: const Text(
                            'رفض الطلب',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Action Loading Overlay ──────────────────────────────
              BlocBuilder<AdminCubit, AdminState>(
                builder: (context, state) {
                  if (state.isActionLoading) {
                    return Container(
                      color: Colors.black.withValues(alpha: 0.25),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.primaryLight,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: 40,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard({required String label, required String? imageUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textHint.withValues(alpha: 0.15)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    errorWidget: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_rounded, color: AppColors.textHint, size: 48),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.image_not_supported_rounded, color: AppColors.textHint, size: 48),
                  ),
          ),
        ),
      ],
    );
  }
}
