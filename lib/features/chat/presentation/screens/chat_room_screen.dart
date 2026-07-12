import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sanad/core/constants/app_colors.dart';
import 'package:sanad/core/constants/app_text_styles.dart';
import 'package:sanad/core/router/app_routes.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sanad/features/chat/domain/entities/message_entity.dart';
import 'package:sanad/features/chat/presentation/cubit/chat_room_cubit.dart';
import 'package:sanad/features/chat/presentation/cubit/chat_room_state.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String bookingId;
  final String otherPartyId;
  final String otherPartyName;
  final String clientName;
  final String helperName;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.bookingId,
    required this.otherPartyId,
    required this.otherPartyName,
    required this.clientName,
    required this.helperName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    if (user != null) {
      context.read<ChatRoomCubit>().watchMessages(widget.chatId);
      context.read<ChatRoomCubit>().markAsRead(widget.chatId, user.id);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = context.read<AuthCubit>().state.user;
    if (user == null) return;

    final message = MessageEntity(
      id: '', // Firestore will auto-generate
      chatId: widget.chatId,
      senderId: user.id,
      content: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    context.read<ChatRoomCubit>().sendMessage(message);
    _messageController.clear();

    // Mark as read after sending to clear any unread state
    context.read<ChatRoomCubit>().markAsRead(widget.chatId, user.id);
  }

  Future<Map<String, String>> _fallbackFetchOtherParty(String currentUserId, String currentRole) async {
    try {
      // 1. Try to fetch chat doc
      final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).get();
      if (chatDoc.exists) {
        final data = chatDoc.data();
        final clientId = data?['clientId'] as String? ?? '';
        final helperId = data?['helperId'] as String? ?? '';
        final isClient = currentRole == 'client';
        final otherId = isClient ? helperId : clientId;
        if (otherId.isNotEmpty) {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(otherId).get();
          final name = userDoc.data()?['name'] as String? ?? userDoc.data()?['fullName'] as String? ?? (isClient ? (data?['helperName'] as String?) : (data?['clientName'] as String?)) ?? 'المستخدم';
          return {'id': otherId, 'name': name};
        }
      }

      // 2. Try to fetch booking doc
      final bookingDoc = await FirebaseFirestore.instance.collection('bookings').doc(widget.chatId).get();
      if (bookingDoc.exists) {
        final data = bookingDoc.data();
        final clientId = data?['clientId'] as String? ?? '';
        final helperId = data?['helperId'] as String? ?? '';
        final isClient = currentRole == 'client';
        final otherId = isClient ? helperId : clientId;
        if (otherId.isNotEmpty) {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(otherId).get();
          final name = userDoc.data()?['name'] as String? ?? userDoc.data()?['fullName'] as String? ?? 'المستخدم';
          return {'id': otherId, 'name': name};
        }
      }
    } catch (_) {}
    return {'id': '', 'name': 'المحادثة'};
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
      child: BlocConsumer<ChatRoomCubit, ChatRoomState>(
        listener: (context, state) {
          if (state.status == ChatRoomStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isClient = user.role == 'client';
          final otherPartyId = (state.chat != null && (isClient ? state.chat!.helperId : state.chat!.clientId).isNotEmpty)
              ? (isClient ? state.chat!.helperId : state.chat!.clientId)
              : widget.otherPartyId;

          final reversedMessages = state.messages.reversed.toList();

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              titleSpacing: 0,
              title: otherPartyId.isEmpty
                  ? FutureBuilder<Map<String, String>>(
                      future: _fallbackFetchOtherParty(user.id, user.role),
                      builder: (context, snapshot) {
                        final name = snapshot.data?['name'] ?? '...';
                        final id = snapshot.data?['id'] ?? '';
                        final initials = name.isNotEmpty ? name[0] : '?';
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (id.isNotEmpty)
                                  const Text(
                                    'متصل الآن',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.success,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    )
                  : FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(otherPartyId).get(),
                      builder: (context, snapshot) {
                        String name = '...';
                        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                          final data = snapshot.data!.data() as Map<String, dynamic>?;
                          name = data?['name'] as String? ?? data?['fullName'] as String? ?? 'المستخدم';
                        } else if (widget.otherPartyName.isNotEmpty) {
                          name = widget.otherPartyName;
                        } else if (state.chat != null) {
                          final chatName = isClient ? state.chat!.helperName : state.chat!.clientName;
                          if (chatName.isNotEmpty && chatName != 'العميل' && chatName != 'المساعد') {
                            name = chatName;
                          }
                        }

                        final initials = name.isNotEmpty ? name[0] : '?';

                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'متصل الآن',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              ),
              actions: [
                // Route to booking details directly from chat room
                IconButton(
                  icon: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                  onPressed: () {
                    context.push('${AppRoutes.bookingTracking}/${widget.bookingId}');
                  },
                  tooltip: 'تفاصيل الطلب',
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: state.status == ChatRoomStatus.loading && state.messages.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        )
                      : reversedMessages.isEmpty
                          ? _buildEmptyChatState()
                          : ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              itemCount: reversedMessages.length,
                              itemBuilder: (context, index) {
                                final message = reversedMessages[index];
                                final isMe = message.senderId == user.id;
                                return _buildMessageBubble(message, isMe);
                              },
                            ),
                ),
                _buildInputBar(state.isSending),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.waving_hand_rounded,
            color: AppColors.warning.withValues(alpha: 0.8),
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'ابدأ المحادثة الآن!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'أرسل رسالة للتحية والاتفاق على التفاصيل.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageEntity message, bool isMe) {
    final timeFormat = intl.DateFormat('hh:mm a');
    final formattedTime = timeFormat.format(message.timestamp);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(
                    color: isMe ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isSending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'اكتب رسالة...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          if (isSending)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            )
          else
            IconButton(
              icon: const Icon(Icons.send_rounded, color: AppColors.primary),
              onPressed: _sendMessage,
            ),
        ],
      ),
    );
  }
}
