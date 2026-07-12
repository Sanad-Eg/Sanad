import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_strings.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_state.dart';

class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            final user = state.user;
            if (user != null &&
                user.role == 'helper' &&
                (user.verificationStatus == 'approved' || user.verificationStatus == 'verified') &&
                state.status == AuthStatus.authenticated) {
              context.go(AppRoutes.helperHome);
            }
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(seconds: 2),
                    curve: Curves.elasticOut,
                    builder: (_, scale, child) => Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pending_actions_rounded,
                        size: 72,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    AppStrings.verificationPendingTitle,
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    AppStrings.verificationPendingSubtitle,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Steps
                  const _VerificationStep(
                    icon: Icons.upload_file_rounded,
                    label: AppStrings.docsUploaded,
                    done: true,
                  ),
                  const SizedBox(height: 12),
                  const _VerificationStep(
                    icon: Icons.manage_search_rounded,
                    label: AppStrings.reviewInProgress,
                    done: false,
                  ),
                  const SizedBox(height: 12),
                  const _VerificationStep(
                    icon: Icons.verified_rounded,
                    label: AppStrings.approvalNotification,
                    done: false,
                  ),

                  const SizedBox(height: 40),

                  // Log in later TextButton
                  TextButton(
                    onPressed: () async {
                      await context.read<AuthCubit>().logout();
                      if (context.mounted) {
                        context.go(AppRoutes.login);
                      }
                    },
                    child: Text(
                      AppStrings.loginLater,
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VerificationStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool done;

  const _VerificationStep({
    required this.icon,
    required this.label,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: done
            ? AppColors.success.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.textHint.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : icon,
            color: done ? AppColors.success : AppColors.textHint,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.body1.copyWith(
              color: done ? AppColors.success : AppColors.textSecondary,
              fontWeight: done ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
