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

class ClientRegisterScreen extends StatefulWidget {
  const ClientRegisterScreen({super.key});

  @override
  State<ClientRegisterScreen> createState() => _ClientRegisterScreenState();
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedNeedType = 'mobility_assistance';

  final Map<String, String> _needTypes = {
    'mobility_assistance': 'مساعدة حركية 🦽',
    'visual_impairment': 'إعاقة بصرية 👁',
    'elderly_care': 'رعاية كبار السن 👴',
    'home_tasks': 'أعمال منزلية 🏠',
    'companionship': 'مرافقة خارج المنزل 🚶',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().registerAsClient(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            primaryNeedType: _selectedNeedType,
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
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          title: Text(
            AppStrings.registerClient,
            style: AppTextStyles.heading3.copyWith(color: AppColors.surface),
          ),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => context.go(AppRoutes.roleSelect),
          ),
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              context.go(AppRoutes.clientHome);
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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'أنشئ حسابك كمحتاج مساعدة وابدأ في البحث عن مساعد موثوق قريب منك.',
                              style: AppTextStyles.body2
                                  .copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    SanadTextField(
                      controller: _nameController,
                      label: AppStrings.name,
                      hint: 'أدخل اسمك الكامل',
                      icon: Icons.person_outline_rounded,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
                        if (v.length < 3) return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    SanadTextField(
                      controller: _phoneController,
                      label: AppStrings.phone,
                      hint: '05XXXXXXXX',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
                        if (v.length < 10) return 'رقم الجوال غير صحيح';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    SanadTextField(
                      controller: _emailController,
                      label: AppStrings.email,
                      hint: 'example@email.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
                        if (!v.contains('@')) return 'بريد إلكتروني غير صحيح';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

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
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        if (v.length < 6) {
                          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Need type selector
                    Text(
                      AppStrings.primaryNeed,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...(_needTypes.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () =>
                                setState(() => _selectedNeedType = entry.key),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _selectedNeedType == entry.key
                                      ? AppColors.primaryLight
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedNeedType == entry.key
                                        ? AppColors.primary
                                        : AppColors.textHint.withValues(alpha: 0.4),
                                    width: _selectedNeedType == entry.key ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _selectedNeedType == entry.key
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                          width: 2,
                                        ),
                                      ),
                                      child: _selectedNeedType == entry.key
                                          ? Center(
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      entry.value,
                                      style: AppTextStyles.body1.copyWith(
                                        color: _selectedNeedType == entry.key
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                        fontWeight: _selectedNeedType == entry.key
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ),
                        ))),

                    const SizedBox(height: 32),

                    SanadButton(
                      text: AppStrings.register,
                      onPressed: _register,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppStrings.alreadyHaveAccount,
                            style: AppTextStyles.body2
                                .copyWith(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: Text(AppStrings.loginTitle,
                              style: AppTextStyles.body2.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
