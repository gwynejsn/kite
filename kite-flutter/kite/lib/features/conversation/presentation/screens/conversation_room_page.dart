import 'package:flutter/material.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/message_response.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_room_controller.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_room_state.dart';
import 'package:kite/features/presence/presentation/presence_provider.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:kite/shared/security/encryption_service.dart';
import 'package:provider/provider.dart';

class ConversationRoomPage extends StatefulWidget {
  final Conversation conversation;

  const ConversationRoomPage({super.key, required this.conversation});

  @override
  State<ConversationRoomPage> createState() => _ConversationRoomPageState();
}

class _ConversationRoomPageState extends State<ConversationRoomPage> {
  late final ConversationRoomController _controller;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = sl<ConversationRoomController>();
    _controller.initRoom(widget.conversation.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleSendMessage(String? currentUserId) {
    final content = _textController.text.trim();
    if (content.isNotEmpty && currentUserId != null) {
      _textController.clear();

      String? recipientPublicKey;
      final otherMemberId = widget.conversation.memberIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      if (otherMemberId.isNotEmpty) {
        recipientPublicKey =
            widget.conversation.memberPublicKeys[otherMemberId];
      }

      _controller.sendMessage(
        conversationId: widget.conversation.id,
        content: content,
        currentUserId: currentUserId,
        recipientPublicKey: recipientPublicKey,
        memberPublicKeys: widget.conversation.memberPublicKeys,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.conversation.name != null && widget.conversation.name!.isNotEmpty
        ? widget.conversation.name!
        : 'Chat';
    final initials = title.isNotEmpty ? title[0].toUpperCase() : 'C';
    final currentUserId = context
        .watch<UserProfileProvider>()
        .userProfile
        ?.userId;

    final isOnline = context.watch<PresenceProvider>().isAnyMemberOnline(
      widget.conversation.memberIds,
      currentUserId,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage:
                  widget.conversation.conversationPhoto != null &&
                      widget.conversation.conversationPhoto!.isNotEmpty
                  ? NetworkImage(widget.conversation.conversationPhoto!)
                  : null,
              child:
                  widget.conversation.conversationPhoto == null ||
                      widget.conversation.conversationPhoto!.isEmpty
                  ? Text(
                      initials,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  isOnline
                      ? Text(
                          'Active now',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(
                          'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_rounded), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.videocam_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages Display List
          Expanded(
            child: ValueListenableBuilder<ConversationRoomState>(
              valueListenable: _controller,
              builder: (context, state, child) {
                if (state.isLoading && state.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.errorMessage != null && state.messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _controller.initRoom(widget.conversation.id),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mark_chat_read_outlined,
                          size: 56,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Say hi to start the conversation!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isMe = message.senderId == currentUserId;
                    return _MessageBubble(
                      message: message,
                      isMe: isMe,
                      currentUserId: currentUserId,
                    );
                  },
                );
              },
            ),
          ),

          // Message Input Field Bar
          _MessageInputBar(
            textController: _textController,
            onSend: () => _handleSendMessage(currentUserId),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageResponse message;
  final bool isMe;
  final String? currentUserId;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.currentUserId,
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? primaryColor : surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: message.getDecryptedContent(
                sl<EncryptionService>(),
                currentUserId: currentUserId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    'Decrypting...',
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: isMe
                          ? Colors.white70
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                final text = snapshot.data ?? 'Encrypted Message';
                return Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: isMe
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
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
                    ? Colors.white.withValues(alpha: 0.7)
                    : Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSend;

  const _MessageInputBar({required this.textController, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.image_outlined),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: textController,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}
