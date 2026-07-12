import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/features/auth/data/models/user_model.dart';
import 'package:sanad/features/auth/domain/entities/user_entity.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_users_cubit.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_users_state.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'إدارة المستخدمين',
            style: AppTextStyles.heading1,
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'العملاء'),
              Tab(text: 'المساعدين'),
            ],
          ),
        ),
        body: BlocBuilder<AdminUsersCubit, AdminUsersState>(
          builder: (context, state) {
            if (state is AdminUsersLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is AdminUsersError) {
              return Center(
                child: Text(
                  state.message,
                  style: AppTextStyles.body1.copyWith(color: AppColors.error),
                ),
              );
            }

            if (state is AdminUsersLoaded) {
              final clients = state.users.where((u) => u.role == 'client').toList();
              final helpers = state.users.where((u) => u.role == 'helper').toList();

              return TabBarView(
                children: [
                  _buildUserList(context, clients, isHelperTab: false),
                  _buildUserList(context, helpers, isHelperTab: true),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildUserList(
    BuildContext context,
    List<UserEntity> users, {
    required bool isHelperTab,
  }) {
    if (users.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد مستخدمين مسجلين',
          style: AppTextStyles.body1,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        List<String> specialties = [];
        if (user is UserModel) {
          specialties = user.specialties ?? [];
        }

        // Helpers only: is this helper NOT yet approved by admin?
        final needsApproval = isHelperTab && user.verificationStatus != 'approved';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: needsApproval
                  ? AppColors.warning.withValues(alpha: 0.5)
                  : AppColors.textHint.withValues(alpha: 0.2),
              width: needsApproval ? 1.5 : 1.0,
            ),
          ),
          color: needsApproval
              ? AppColors.warning.withValues(alpha: 0.04)
              : AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──────────────────────────────────────
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isHelperTab
                          ? AppColors.secondaryLight
                          : AppColors.primaryLight,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0] : '?',
                        style: TextStyle(
                          color: isHelperTab
                              ? AppColors.secondary
                              : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: AppTextStyles.heading3),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ── Approval badge ──────────────────────────────
                    if (needsApproval)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.hourglass_empty_rounded,
                              color: AppColors.warning,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'قيد المراجعة',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const Divider(height: 24),

                // ── Phone ────────────────────────────────────────────
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(user.phone, style: AppTextStyles.body2),
                  ],
                ),

                // ── Specialties ──────────────────────────────────────
                if (isHelperTab && specialties.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'التخصصات:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: specialties.map((spec) {
                      return Chip(
                        label: Text(spec),
                        backgroundColor: AppColors.primaryLight,
                        labelStyle: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],

                // ── Approve button (only for unapproved helpers) ─────
                if (needsApproval) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () =>
                          context.read<AdminUsersCubit>().approveHelper(user.id),
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          size: 18),
                      label: const Text('قبول المساعد'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
