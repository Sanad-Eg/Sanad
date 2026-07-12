import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_strings.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/widgets/sanad_button.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text(
            AppStrings.changePasswordTitle,
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.error && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state.status == AuthStatus.authenticated && state.errorMessage == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.passwordChangedSuccess),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.pop();
            }
          },
          builder: (context, state) {
            final isLoading = state.status == AuthStatus.loading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.changePasswordSubtitle,
                        style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),

                      // Current password
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return AppStrings.enterCurrentPasswordPrompt;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: AppStrings.currentPassword,
                          prefixIcon: const Icon(Icons.lock_open_rounded, color: AppColors.primary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // New password
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return AppStrings.enterNewPasswordPrompt;
                          }
                          if (val.length < 6) {
                            return AppStrings.passwordMinLength;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: AppStrings.newPassword,
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Confirm password
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return AppStrings.confirmNewPasswordPrompt;
                          }
                          if (val != _newPasswordController.text) {
                            return AppStrings.passwordsDoNotMatch;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: AppStrings.confirmNewPassword,
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Save button
                      SanadButton(
                        text: AppStrings.saveChanges,
                        isLoading: isLoading,
                        onPressed: _submit,
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
}
