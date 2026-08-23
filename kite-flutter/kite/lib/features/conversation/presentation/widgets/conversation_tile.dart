import 'package:flutter/material.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/conversation_type.dart';
import 'package:kite/features/presence/presentation/presence_provider.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:kite/shared/security/encryption_service.dart';
import 'package:provider/provider.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      final hour = dateTime.hour > 12
          ? dateTime.hour - 12
          : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[dateTime.weekday - 1];
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year.toString().substring(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfileProvider = context.watch<UserProfileProvider>();
    final currentUserId = userProfileProvider.userProfile?.userId;
    final presenceProvider = context.watch<PresenceProvider>();

    final isGroup = conversation.type == ConversationType.group;

    String? otherMemberId;
    if (!isGroup && currentUserId != null) {
      otherMemberId = conversation.memberIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
    }

    final isOnline = isGroup
        ? presenceProvider.isAnyMemberOnline(
            conversation.memberIds, currentUserId)
        : (otherMemberId != null &&
            otherMemberId.isNotEmpty &&
            presenceProvider.isUserOnline(otherMemberId));

    final title = conversation.name ?? 'Conversation';
    final photoUrl = conversation.conversationPhoto;

    final timestampStr = conversation.lastMessage != null
        ? _formatTime(conversation.lastMessage!.timestamp)
        : '';

    final isSentByMe = currentUserId != null &&
        conversation.lastMessage != null &&
        conversation.lastMessage!.senderId == currentUserId;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                      ? NetworkImage(photoUrl)
                      : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? Icon(
                          isGroup
                              ? Icons.group_rounded
                              : Icons.person_rounded,
                          size: 28,
                          color: theme.colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timestampStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (conversation.lastMessage != null)
                        Expanded(
                          child: FutureBuilder<String>(
                            future: () async {
                              String? groupKeyBase64;
                              if (conversation.type == ConversationType.group) {
                                groupKeyBase64 =
                                    await conversation.getGroupKey(
                                  sl<EncryptionService>(),
                                  currentUserId: currentUserId,
                                );
                              }
                              return conversation.lastMessage!
                                  .getDecryptedContent(
                                sl<EncryptionService>(),
                                currentUserId: currentUserId,
                                groupKeyBase64: groupKeyBase64,
                              );
                            }(),
                            builder: (context, snapshot) {
                              final text = snapshot.data ??
                                  (snapshot.connectionState ==
                                          ConnectionState.waiting
                                      ? 'Loading message...'
                                      : 'Encrypted Message');
                              return Row(
                                children: [
                                  if (isSentByMe) ...[
                                    Icon(
                                      Icons.done_all_rounded,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Expanded(
                                    child: Text(
                                      text,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      else
                        Expanded(
                          child: Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
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
