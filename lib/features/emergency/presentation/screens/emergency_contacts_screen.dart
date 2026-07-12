import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/widgets/sanad_button.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sanad/features/emergency/domain/entities/emergency_contact_entity.dart';
import 'package:sanad/features/emergency/presentation/cubit/emergency_cubit.dart';
import 'package:sanad/features/emergency/presentation/cubit/emergency_state.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    if (user != null) {
      context.read<EmergencyCubit>().watchContacts(user.id);
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'تعذر إجراء الاتصال بالرقم $phoneNumber';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('الرجاء تسجيل الدخول أولاً', style: AppTextStyles.body1),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'جهات اتصال الطوارئ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddContactBottomSheet(context, user.id),
          backgroundColor: AppColors.sos,
          icon: const Icon(Icons.add_call, color: Colors.white),
          label: Text(
            'إضافة جهة اتصال طوارئ',
            style: AppTextStyles.button.copyWith(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Notice ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.sos, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'في حالة الطوارئ، سيتمكن المساعد المتاح من الاتصال بهذه الجهات فوراً لتأمين سلامتك.',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Contacts List ────────────────────────────────────────────────
              Expanded(
                child: BlocBuilder<EmergencyCubit, EmergencyState>(
                  builder: (context, state) {
                    if (state.status == EmergencyStatus.loading && state.contacts.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }

                    if (state.status == EmergencyStatus.error) {
                      return Center(
                        child: Text(
                          state.errorMessage ?? 'حدث خطأ أثناء تحميل جهات الاتصال',
                          style: AppTextStyles.body1.copyWith(color: AppColors.error),
                        ),
                      );
                    }

                    final contacts = state.contacts;

                    if (contacts.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      itemCount: contacts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return _buildContactCard(contact);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.sos.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.contact_phone_outlined,
              color: AppColors.sos,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد أرقام طوارئ مسجلة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'الرجاء إضافة جهة اتصال واحدة على الأقل للاستدعاء السريع عند الحاجة.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContactEntity contact) {
    return Container(
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.sos.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.family_restroom_rounded,
              color: AppColors.sos,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الصلة: ${contact.relation} • ${contact.phoneNumber}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Call Button
          IconButton(
            icon: const Icon(Icons.phone_forwarded_rounded, color: AppColors.success),
            onPressed: () => _makeCall(contact.phoneNumber),
            tooltip: 'اتصال سريع',
          ),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () => _confirmDelete(contact.id, contact.clientId),
            tooltip: 'حذف',
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String contactId, String clientId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف جهة الاتصال', style: AppTextStyles.heading2),
          content: const Text('هل أنت متأكد من رغبتك في حذف جهة اتصال الطوارئ هذه؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                context.read<EmergencyCubit>().removeContact(contactId, clientId);
                Navigator.pop(dialogCtx);
              },
              child: const Text('حذف', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContactBottomSheet(BuildContext context, String clientId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<EmergencyCubit>(),
        child: _AddContactBottomSheetContent(clientId: clientId),
      ),
    );
  }
}

// ── Add Contact Bottom Sheet Content ─────────────────────────────────────────
class _AddContactBottomSheetContent extends StatefulWidget {
  final String clientId;
  const _AddContactBottomSheetContent({required this.clientId});

  @override
  State<_AddContactBottomSheetContent> createState() => _AddContactBottomSheetContentState();
}

class _AddContactBottomSheetContentState extends State<_AddContactBottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<EmergencyCubit>().addContact(
          clientId: widget.clientId,
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          relation: _relationController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: BlocConsumer<EmergencyCubit, EmergencyState>(
          listener: (context, state) {
            if (state.status == EmergencyStatus.error && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            if (!state.isSubmitting && state.status == EmergencyStatus.success) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت إضافة جهة اتصال الطوارئ بنجاح ✅'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إضافة جهة اتصال طوارئ',
                        style: AppTextStyles.heading2,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Name Input
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      hintText: 'مثال: أحمد خالد',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'الرجاء إدخال اسم جهة الاتصال' : null,
                  ),
                  const SizedBox(height: 18),

                  // Phone Input
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      hintText: 'مثال: 05XXXXXXXX',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'الرجاء إدخال رقم الهاتف' : null,
                  ),
                  const SizedBox(height: 18),

                  // Relation Input
                  TextFormField(
                    controller: _relationController,
                    decoration: const InputDecoration(
                      labelText: 'صلة القرابة',
                      hintText: 'مثال: ابن، ابنة، زوج، صديق',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'الرجاء إدخال صلة القرابة' : null,
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  SanadButton(
                    text: 'حفظ جهة الاتصال',
                    isLoading: state.isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
