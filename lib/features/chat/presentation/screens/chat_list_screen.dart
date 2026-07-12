import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sanad/features/chat/domain/entities/chat_entity.dart';
import 'package:sanad/features/chat/presentation/cubit/chat_list_cubit.dart';
import 'package:sanad/features/chat/presentation/cubit/chat_list_state.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    if (user != null) {
      context.read<ChatListCubit>().watchChats(user.id);
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

    final isClient = user.role == 'client';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'المحادثات',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<ChatListCubit, ChatListState>(
          builder: (context, state) {
            if (state.status == ChatListStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.status == ChatListStatus.error) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'حدث خطأ ما أثناء تحميل المحادثات',
                  style: AppTextStyles.body1.copyWith(color: AppColors.error),
                ),
              );
            }

            final chats = state.chats;

            if (chats.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: chats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatCard(chat, user.id, isClient);
              },
            );
          },
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
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد محادثات نشطة حالياً.',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ستبدأ المحادثة بمجرد إرسال أو قبول طلب خدمة.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(ChatEntity chat, String currentUserId, bool isClient) {
    final otherPartyId = isClient ? chat.helperId : chat.clientId;
    final otherPartyName = isClient ? chat.helperName : chat.clientName;
    final timeFormat = intl.DateFormat('hh:mm a');
    final dateFormat = intl.DateFormat('yyyy/MM/dd');

    final formattedTime = chat.updatedAt.day == DateTime.now().day
        ? timeFormat.format(chat.updatedAt)
        : dateFormat.format(chat.updatedAt);

    return InkWell(
      onTap: () {
        context.push(
          '${AppRoutes.chat}/${chat.id}',
          extra: {
            'bookingId': chat.bookingId,
            'otherPartyId': otherPartyId,
            'otherPartyName': otherPartyName,
          },
        );
      },
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
            // User Avatar Icon/Initials
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isClient ? AppColors.secondaryLight : AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isClient ? Icons.support_agent_rounded : Icons.person_rounded,
                color: isClient ? AppColors.secondary : AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Chat Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        otherPartyName,
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage ?? 'اضغط لبدء المحادثة...',
                          style: AppTextStyles.body2.copyWith(
                            color: chat.unreadCount > 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: chat.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
