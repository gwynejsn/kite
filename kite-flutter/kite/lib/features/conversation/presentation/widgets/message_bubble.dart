import 'package:flutter/material.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/conversation_type.dart';
import 'package:kite/features/conversation/domain/message_response.dart';
import 'package:kite/features/media/domain/models/encrypted_media_payload.dart';
import 'package:kite/features/media/presentation/widgets/encrypted_audio_view.dart';
import 'package:kite/features/media/presentation/widgets/encrypted_file_view.dart';
import 'package:kite/features/media/presentation/widgets/encrypted_image_view.dart';
import 'package:kite/features/media/presentation/widgets/encrypted_video_view.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:kite/shared/security/encryption_service.dart';
import 'package:provider/provider.dart';

class MessageBubble extends StatelessWidget {
  final MessageResponse message;
  final bool isMe;
  final String searchQuery;
  final Conversation conversation;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.searchQuery,
    required this.conversation,
  });

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        context.watch<UserProfileProvider>().userProfile?.userId;

    final isGroup = conversation.type == ConversationType.group;
    final showSenderHeader = !isMe && isGroup;
    final memberProfile = conversation.memberProfiles[message.senderId];
    final senderName = memberProfile?.displayName ?? 'User';
    final photoUrl = memberProfile?.profilePhoto;
    final initials = memberProfile?.initials ??
        (senderName.isNotEmpty ? senderName[0].toUpperCase() : 'U');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (showSenderHeader) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? Text(
                        initials,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 6),
            ],
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isMe
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.6),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (showSenderHeader) ...[
                    Text(
                      senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  FutureBuilder<String>(
                    future: () async {
                      String? groupKeyBase64;
                      if (conversation.type == ConversationType.group) {
                        groupKeyBase64 = await conversation.getGroupKey(
                          sl<EncryptionService>(),
                          currentUserId: currentUserId,
                        );
                      }
                      return message.getDecryptedContent(
                        sl<EncryptionService>(),
                        currentUserId: currentUserId,
                        groupKeyBase64: groupKeyBase64,
                      );
                    }(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isMe ? Colors.white : null,
                          ),
                        );
                      }

                      final text = snapshot.data ?? 'Encrypted Message';
                      final mediaPayload = EncryptedMediaPayload.tryDecode(text);

                      if (mediaPayload != null &&
                          message.mediaUrl != null &&
                          message.mediaUrl!.isNotEmpty) {
                        final type = mediaPayload.mediaType.toUpperCase();
                        return Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (type == 'IMAGE')
                              EncryptedImageView(
                                mediaUrl: message.mediaUrl!,
                                payload: mediaPayload,
                                width: 220,
                                height: 220,
                              )
                            else if (type == 'VIDEO')
                              EncryptedVideoView(
                                mediaUrl: message.mediaUrl!,
                                payload: mediaPayload,
                                width: 240,
                              )
                            else if (type == 'AUDIO')
                              EncryptedAudioView(
                                mediaUrl: message.mediaUrl!,
                                payload: mediaPayload,
                                isMe: isMe,
                              )
                            else
                              EncryptedFileView(
                                mediaUrl: message.mediaUrl!,
                                payload: mediaPayload,
                                isMe: isMe,
                              ),
                            if (mediaPayload.caption != null &&
                                mediaPayload.caption!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                mediaPayload.caption!,
                                style: TextStyle(
                                  color: isMe
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        );
                      }

                      final isMatch = searchQuery.isNotEmpty &&
                          text.toLowerCase().contains(searchQuery);

                      return Container(
                        padding: isMatch
                            ? const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2)
                            : EdgeInsets.zero,
                        decoration: isMatch
                            ? BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(4),
                              )
                            : null,
                        child: Text(
                          text,
                          style: TextStyle(
                            color: isMe
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            fontSize: 15,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe
                          ? Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.7)
                          : Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.7),
                    ),
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
