import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_strings.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/widgets/sanad_button.dart';
import 'package:sanad/features/auth/domain/entities/user_entity.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_state.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            AppStrings.myAccount,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, authState) {
            if (authState.status == AuthStatus.unauthenticated) {
              context.go(AppRoutes.login);
            }
          },
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final user = authState.user;
              final isHelper = user?.role == 'helper';
              final isLoading = authState.status == AuthStatus.loading;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // ── Avatar & Name ────────────────────────────────────────
                      _ProfileAvatar(
                        user: user,
                        isHelper: isHelper,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 28),

                      // ── Info Card ────────────────────────────────────────────
                      _buildInfoCard(
                        children: [
                          _buildInfoRow(
                            icon: Icons.person_outline_rounded,
                            label: AppStrings.fullName,
                            value: user?.name ?? '—',
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                              onPressed: () => _showEditNameDialog(context, user?.name ?? ''),
                            ),
                          ),
                          const Divider(height: 24, thickness: 1),
                          _buildInfoRow(
                            icon: Icons.email_outlined,
                            label: AppStrings.emailLabel,
                            value: user?.email ?? '—',
                          ),
                          const Divider(height: 24, thickness: 1),
                          _buildInfoRow(
                            icon: isHelper
                                ? Icons.support_agent_rounded
                                : Icons.person_rounded,
                            label: AppStrings.accountType,
                            value: isHelper ? AppStrings.helperAccountType : AppStrings.clientAccountType,
                          ),
                          if (isHelper) ...[
                            const Divider(height: 24, thickness: 1),
                            _buildInfoRow(
                              icon: Icons.verified_outlined,
                              label: AppStrings.verificationStatus,
                              value: user?.isVerifiedHelper == true
                                  ? AppStrings.helperVerified
                                  : AppStrings.helperPendingVerification,
                              valueColor: user?.isVerifiedHelper == true
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Settings Placeholder Card ─────────────────────────────
                      _buildInfoCard(
                        children: [
                          if (!isHelper) ...[
                            _buildActionRow(
                              icon: Icons.contact_phone_outlined,
                              label: AppStrings.emergencyContactsLabel,
                              onTap: () {
                                context.push(AppRoutes.emergencyContacts);
                              },
                            ),
                            const Divider(height: 24, thickness: 1),
                          ],
                          _buildActionRow(
                            icon: Icons.notifications_outlined,
                            label: AppStrings.notificationsLabel,
                            onTap: () {
                              context.push(AppRoutes.notifications);
                            },
                          ),
                          const Divider(height: 24, thickness: 1),
                          _buildActionRow(
                            icon: Icons.lock_outline_rounded,
                            label: AppStrings.changePasswordLabel,
                            onTap: () {
                              context.push(AppRoutes.changePassword);
                            },
                          ),
                          if (user?.role == 'admin') ...[
                            const Divider(height: 24, thickness: 1),
                            _buildActionRow(
                              icon: Icons.admin_panel_settings_outlined,
                              label: AppStrings.adminPanelLabel,
                              onTap: () {
                                context.push(AppRoutes.adminPanel);
                              },
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ── Logout Button ─────────────────────────────────────────
                      SanadButton(
                        text: AppStrings.logout,
                        backgroundColor: AppColors.error,
                        onPressed: () =>
                            context.read<AuthCubit>().logout(),
                      ),
                      const SizedBox(height: 16),

                      // App version footer
                      Text(
                        AppStrings.appVersion,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
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

  // ── Card Wrapper ───────────────────────────────────────────────────────────
  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(AppStrings.editNameTitle, style: AppTextStyles.heading3),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: AppStrings.enterNewName,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text(AppStrings.cancel, style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  context.read<AuthCubit>().updateProfileName(newName);
                }
                Navigator.pop(dialogCtx);
              },
              child: const Text(AppStrings.save, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.body1.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body1
                  .copyWith(color: AppColors.textPrimary),
            ),
          ),
          const Icon(Icons.arrow_back_ios_new_rounded,
              size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

// ── Profile Avatar with Upload ──────────────────────────────────────────────
class _ProfileAvatar extends StatelessWidget {
  final UserEntity? user;
  final bool isHelper;
  final bool isLoading;

  const _ProfileAvatar({
    required this.user,
    required this.isHelper,
    required this.isLoading,
  });

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (file != null && context.mounted) {
      context.read<AuthCubit>().uploadProfileImage(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? AppStrings.userLabel;
    final profileUrl = user?.profileImageUrl;
    final hasImage = profileUrl != null && profileUrl.isNotEmpty;

    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join()
        : '?';

    final gradientColors = isHelper
        ? [AppColors.secondary, const Color(0xFF008F7F)]
        : [AppColors.primary, const Color(0xFF2C5E9E)];

    return Column(
      children: [
        GestureDetector(
          onTap: isLoading ? null : () => _pickAndUploadImage(context),
          child: Stack(
            children: [
              // ── Avatar circle ──────────────────────────
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: hasImage
                      ? null
                      : LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                         ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isHelper ? AppColors.secondary : AppColors.primary)
                          .withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: profileUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                initials.toUpperCase(),
                                style: AppTextStyles.heading1.copyWith(
                                  color: Colors.white,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                initials.toUpperCase(),
                                style: AppTextStyles.heading1.copyWith(
                                  color: Colors.white,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            initials.toUpperCase(),
                            style: AppTextStyles.heading1.copyWith(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                        ),
                ),
              ),

              // ── Loading overlay ────────────────────────
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Camera badge ───────────────────────────
              if (!isLoading)
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isHelper ? AppColors.secondaryLight : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isHelper ? AppStrings.trustedHelperBadge : AppStrings.clientBadge,
            style: AppTextStyles.caption.copyWith(
              color: isHelper ? AppColors.secondary : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
