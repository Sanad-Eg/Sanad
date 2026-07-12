import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_strings.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:sanad/core/widgets/sanad_button.dart';
import 'package:sanad/core/widgets/sanad_text_field.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _navigateAfterAuth(BuildContext context, AuthState state) {
    if (state.user == null) return;
    if (state.user!.isClient) {
      context.go(AppRoutes.clientHome);
    } else if (state.user!.isHelper) {
      if (state.user!.isPendingHelper) {
        context.go(AppRoutes.verificationPending);
      } else {
        context.go(AppRoutes.helperHome);
      }
    } else if (state.user!.isAdmin) {
      context.go(AppRoutes.adminPanel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              _navigateAfterAuth(context, state);
            }
            if (state.status == AuthStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? ''),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state.status == AuthStatus.loading;
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),

                      // Header
                      Center(
                        child: Image.asset('assets/logo.png', height: 150),
                      ),
                      const SizedBox(height: 24),

                      Center(
                        child: Text(
                          AppStrings.loginTitle,
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          AppStrings.loginSubtitle,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Email field
                      SanadTextField(
                        controller: _emailController,
                        label: AppStrings.email,
                        hint: 'example@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                          if (!v.contains('@')) return AppStrings.invalidEmail;
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      SanadTextField(
                        controller: _passwordController,
                        label: AppStrings.password,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                          if (v.length < 6) {
                            return AppStrings.passwordLoginMinLength;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerLeft, // Left aligned since RTL makes it visually right
                        child: TextButton(
                          onPressed: () {
                            context.push(AppRoutes.forgotPassword);
                          },
                          child: Text(
                            AppStrings.forgotPasswordLink,
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Login button
                      SanadButton(
                        text: AppStrings.loginTitle,
                        onPressed: _login,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 24),
                      
                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.dontHaveAccount,
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(AppRoutes.roleSelect),
                            child: Text(
                              AppStrings.register,
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
