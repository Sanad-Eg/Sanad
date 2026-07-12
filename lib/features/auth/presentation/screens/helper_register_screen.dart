import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_strings.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:sanad/core/widgets/sanad_button.dart';
import 'package:sanad/core/widgets/sanad_text_field.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_state.dart';

class HelperRegisterScreen extends StatefulWidget {
  const HelperRegisterScreen({super.key});

  @override
  State<HelperRegisterScreen> createState() => _HelperRegisterScreenState();
}

class _HelperRegisterScreenState extends State<HelperRegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(AppRoutes.verificationPending);
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
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.surface,
              title: Text(
                AppStrings.registerHelper,
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.surface,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: () {
                  if (state.helperRegisterStep > 1) {
                    context.read<AuthCubit>().goBackHelperStep();
                  } else {
                    context.go(AppRoutes.roleSelect);
                  }
                },
              ),
            ),
            body: Column(
              children: [
                // Progress bar
                _StepProgressBar(currentStep: state.helperRegisterStep),

                // Step content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: state.helperRegisterStep == 1
                        ? const _Step1PersonalInfo(key: ValueKey(1))
                        : state.helperRegisterStep == 2
                        ? const _Step2ProfessionalProfile(key: ValueKey(2))
                        : const _Step3Documents(key: ValueKey(3)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Progress Bar ────────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  const _StepProgressBar({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondary,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Row(
        children: List.generate(3, (i) {
          final step = i + 1;
          final isDone = step < currentStep;
          final isCurrent = step == currentStep;
          return Expanded(
            child: Row(
              children: [
                // Circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDone || isCurrent
                        ? AppColors.surface
                        : AppColors.surface.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: AppColors.secondary,
                          )
                        : Text(
                            '$step',
                            style: AppTextStyles.body2.copyWith(
                              color: isCurrent
                                  ? AppColors.secondary
                                  : AppColors.surface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                // Line (between steps)
                if (step < 3)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 2,
                      color: step < currentStep
                          ? AppColors.surface
                          : AppColors.surface.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Step 1: Personal Info ────────────────────────────────────────────────────

class _Step1PersonalInfo extends StatefulWidget {
  const _Step1PersonalInfo({super.key});
  @override
  State<_Step1PersonalInfo> createState() => _Step1PersonalInfoState();
}

class _Step1PersonalInfoState extends State<_Step1PersonalInfo> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepHeader('البيانات الشخصية', 'أدخل معلوماتك الأساسية للتسجيل'),
            const SizedBox(height: 24),

            SanadTextField(
              controller: _nameCtrl,
              label: AppStrings.name,
              hint: 'أدخل اسمك الكامل',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.length < 3)
                  ? 'الاسم يجب أن يكون 3 أحرف على الأقل'
                  : null,
            ),
            const SizedBox(height: 16),

            SanadTextField(
              controller: _phoneCtrl,
              label: AppStrings.phone,
              hint: '05XXXXXXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.length < 10) ? 'رقم الجوال غير صحيح' : null,
            ),
            const SizedBox(height: 16),

            SanadTextField(
              controller: _emailCtrl,
              label: AppStrings.email,
              hint: 'example@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'بريد إلكتروني غير صحيح'
                  : null,
            ),
            const SizedBox(height: 16),

            SanadTextField(
              controller: _passwordCtrl,
              label: AppStrings.password,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscure,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) => (v == null || v.length < 6)
                  ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                  : null,
            ),
            const SizedBox(height: 32),

            SanadButton(
              text: 'التالي ←',
              backgroundColor: AppColors.secondary,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<AuthCubit>().saveHelperStep1(
                    name: _nameCtrl.text.trim(),
                    phone: _phoneCtrl.text.trim(),
                    email: _emailCtrl.text.trim(),
                    password: _passwordCtrl.text,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 2: Professional Profile ────────────────────────────────────────────

class _Step2ProfessionalProfile extends StatefulWidget {
  const _Step2ProfessionalProfile({super.key});
  @override
  State<_Step2ProfessionalProfile> createState() =>
      _Step2ProfessionalProfileState();
}

class _Step2ProfessionalProfileState extends State<_Step2ProfessionalProfile> {
  final _formKey = GlobalKey<FormState>();
  final _aboutCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();

  final List<String> _allSpecialties = [
    'mobility_assistance',
    'visual_impairment',
    'elderly_care',
    'home_tasks',
    'companionship',
  ];
  final Map<String, String> _specialtyLabels = {
    'mobility_assistance': 'مساعدة حركية 🦽',
    'visual_impairment': 'إعاقة بصرية 👁',
    'elderly_care': 'رعاية كبار السن 👴',
    'home_tasks': 'أعمال منزلية 🏠',
    'companionship': 'مرافقة خارج المنزل 🚶',
  };
  final Set<String> _selectedSpecialties = {};
  final _serviceAreasCtrl = TextEditingController();

  @override
  void dispose() {
    _aboutCtrl.dispose();
    _rateCtrl.dispose();
    _serviceAreasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepHeader(
              'الملف المهني',
              'أخبرنا عن نفسك وخبرتك في تقديم المساعدة',
            ),
            const SizedBox(height: 24),

            SanadTextField(
              controller: _aboutCtrl,
              label: 'نبذة عنك',
              hint: 'اكتب نبذة مختصرة عن نفسك وخبراتك...',
              icon: Icons.info_outline_rounded,
              maxLines: 3,
              validator: (v) => (v == null || v.length < 20)
                  ? 'النبذة يجب أن تكون 20 حرفاً على الأقل'
                  : null,
            ),
            const SizedBox(height: 16),

            SanadTextField(
              controller: _rateCtrl,
              label: AppStrings.hourlyRate,
              hint: '50',
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
                final rate = double.tryParse(v);
                if (rate == null || rate < 10) {
                  return 'الحد الأدنى 10 جنيه/ساعة';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            Text(
              'التخصصات (اختر واحداً أو أكثر)',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allSpecialties.map((s) {
                final selected = _selectedSpecialties.contains(s);
                return FilterChip(
                  label: Text(
                    _specialtyLabels[s]!,
                    style: AppTextStyles.body2.copyWith(
                      color: selected
                          ? AppColors.surface
                          : AppColors.textPrimary,
                    ),
                  ),
                  selected: selected,
                  onSelected: (v) {
                    setState(
                      () => v
                          ? _selectedSpecialties.add(s)
                          : _selectedSpecialties.remove(s),
                    );
                  },
                  selectedColor: AppColors.secondary,
                  backgroundColor: AppColors.surface,
                  checkmarkColor: AppColors.surface,
                  side: BorderSide(
                    color: selected
                        ? AppColors.secondary
                        : AppColors.textHint.withValues(alpha: 0.4),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            SanadTextField(
              controller: _serviceAreasCtrl,
              label: 'مناطق الخدمة',
              hint: 'مثال: أسيوط، الأقصر، قنا، سوهاج... إلخ',
              icon: Icons.location_on_outlined,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
            ),
            const SizedBox(height: 32),

            SanadButton(
              text: 'التالي ←',
              backgroundColor: AppColors.secondary,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (_selectedSpecialties.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يرجى اختيار تخصص واحد على الأقل'),
                        backgroundColor: AppColors.warning,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  context.read<AuthCubit>().saveHelperStep2(
                    aboutMe: _aboutCtrl.text.trim(),
                    hourlyRate: double.parse(_rateCtrl.text),
                    specialties: _selectedSpecialties.toList(),
                    serviceAreas: _serviceAreasCtrl.text
                        .split('،')
                        .map((e) => e.trim())
                        .toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 3: Documents ────────────────────────────────────────────────────────

class _Step3Documents extends StatefulWidget {
  const _Step3Documents({super.key});
  @override
  State<_Step3Documents> createState() => _Step3DocumentsState();
}

class _Step3DocumentsState extends State<_Step3Documents> {
  String? _idFrontPath;
  String? _idBackPath;
  String? _selfiePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String type) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() {
        if (type == 'front') _idFrontPath = file.path;
        if (type == 'back') _idBackPath = file.path;
        if (type == 'selfie') _selfiePath = file.path;
      });
    }
  }

  void _submit() {
    if (_idFrontPath == null || _idBackPath == null || _selfiePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى رفع جميع المستندات المطلوبة'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.read<AuthCubit>().submitHelperRegistration(
      idFrontPath: _idFrontPath!,
      idBackPath: _idBackPath!,
      selfieWithIdPath: _selfiePath!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _stepHeader(
                'رفع المستندات',
                'نحتاج إلى التحقق من هويتك قبل البدء',
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ستُراجع المستندات من قِبل فريق سند خلال 24-48 ساعة.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _DocUploadCard(
                label: AppStrings.nationalIdFront,
                imagePath: _idFrontPath,
                onTap: () => _pickImage('front'),
              ),
              const SizedBox(height: 12),

              _DocUploadCard(
                label: AppStrings.nationalIdBack,
                imagePath: _idBackPath,
                onTap: () => _pickImage('back'),
              ),
              const SizedBox(height: 12),

              _DocUploadCard(
                label: AppStrings.selfieWithId,
                imagePath: _selfiePath,
                onTap: () => _pickImage('selfie'),
                isSelfie: true,
              ),
              const SizedBox(height: 32),

              SanadButton(
                text: 'إرسال للمراجعة ✓',
                backgroundColor: AppColors.secondary,
                onPressed: _submit,
                isLoading: isLoading,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DocUploadCard extends StatelessWidget {
  final String label;
  final String? imagePath;
  final VoidCallback onTap;
  final bool isSelfie;

  const _DocUploadCard({
    required this.label,
    required this.imagePath,
    required this.onTap,
    this.isSelfie = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasImage ? AppColors.secondaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage
                ? AppColors.secondary
                : AppColors.textHint.withValues(alpha: 0.4),
            width: hasImage ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Preview or placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: hasImage
                  ? Image.file(
                      File(imagePath!),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 64,
                      height: 64,
                      color: AppColors.background,
                      child: Icon(
                        isSelfie ? Icons.face_rounded : Icons.badge_outlined,
                        size: 32,
                        color: AppColors.textHint,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasImage ? AppStrings.imageUploaded : AppStrings.uploadImage,
                    style: AppTextStyles.caption.copyWith(
                      color: hasImage
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasImage ? Icons.check_circle_rounded : Icons.upload_rounded,
              color: hasImage ? AppColors.success : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

Widget _stepHeader(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
      ),
    ],
  );
}
