import 'package:flutter/material.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/conversation_type.dart';
import 'package:kite/features/conversation/domain/message_response.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_controller.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_room_controller.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_room_state.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_state.dart';
import 'package:kite/features/conversation/presentation/screens/conversation_details_page.dart';
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
  final ScrollController _scrollController = ScrollController();

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _controller = sl<ConversationRoomController>();
    _controller.initRoom(widget.conversation.id);

    _scrollController.addListener(() {
      final show =
          _scrollController.hasClients && _scrollController.offset > 200;
      if (show != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = show;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleSendMessage(String? currentUserId, Conversation activeConv) {
    final content = _textController.text.trim();
    if (content.isNotEmpty && currentUserId != null) {
      _textController.clear();

      String? recipientPublicKey;
      final otherMemberId = activeConv.memberIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      if (otherMemberId.isNotEmpty) {
        recipientPublicKey =
            activeConv.memberPublicKeys[otherMemberId];
      }

      _controller.sendMessage(
        conversationId: activeConv.id,
        content: content,
        currentUserId: currentUserId,
        recipientPublicKey: recipientPublicKey,
        memberPublicKeys: activeConv.memberPublicKeys,
      );
    }
  }

  void _openConversationDetailsPage(
      BuildContext context, bool isOnline, Conversation activeConv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationDetailsPage(
          conversation: activeConv,
          isOnline: isOnline,
          onSearchTap: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _formatDateDivider(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (msgDate == today) {
      return 'Today';
    } else if (msgDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      final weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return weekdays[dateTime.weekday - 1];
    }
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ConversationState>(
      valueListenable: sl<ConversationController>(),
      builder: (context, convState, child) {
        final activeConv = convState.conversations.firstWhere(
          (c) => c.id == widget.conversation.id,
          orElse: () => widget.conversation,
        );

        final title = activeConv.name != null && activeConv.name!.isNotEmpty
            ? activeConv.name!
            : 'Chat';
        final initials = title.isNotEmpty ? title[0].toUpperCase() : 'C';
        final currentUserId = context
            .watch<UserProfileProvider>()
            .userProfile
            ?.userId;

        final isOnline = context.watch<PresenceProvider>().isAnyMemberOnline(
          activeConv.memberIds,
          currentUserId,
        );

        final searchQuery = _searchController.text.trim().toLowerCase();

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 0,
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 17,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search in conversation...',
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => setState(() {}),
                  )
                : Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        backgroundImage:
                            activeConv.conversationPhoto != null &&
                                    activeConv.conversationPhoto!.isNotEmpty
                                ? NetworkImage(activeConv.conversationPhoto!)
                                : null,
                        child: activeConv.conversationPhoto == null ||
                                activeConv.conversationPhoto!.isEmpty
                            ? Text(
                                initials,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
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
                                ? const Text(
                                    'Active now',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : const Text(
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
            actions: _isSearching
                ? [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _searchController.clear();
                        });
                      },
                    ),
                  ]
                : [
                    IconButton(
                      icon: const Icon(Icons.search_rounded),
                      tooltip: 'Search messages',
                      onPressed: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.call_rounded),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam_rounded),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded),
                      tooltip: 'Conversation Details',
                      onPressed: () =>
                          _openConversationDetailsPage(context, isOnline, activeConv),
                    ),
                  ],
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.4, -0.5),
                      radius: 1.3,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.15),
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ValueListenableBuilder<ConversationRoomState>(
                          valueListenable: _controller,
                          builder: (context, state, child) {
                            if (state.isLoading && state.messages.isEmpty) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (state.errorMessage != null &&
                                state.messages.isEmpty) {
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
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () => _controller.initRoom(
                                          widget.conversation.id,
                                        ),
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No messages here yet.',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Say hello to start the conversation!',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.all(16.0),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            final isMe = message.senderId == currentUserId;

                            bool showDateDivider = false;
                            if (index == state.messages.length - 1) {
                              showDateDivider = true;
                            } else {
                              final prevMessageInTime =
                                  state.messages[index + 1];
                              if (!_isSameDay(
                                message.createdAt,
                                prevMessageInTime.createdAt,
                              )) {
                                showDateDivider = true;
                              }
                            }

                            return Column(
                              children: [
                                if (showDateDivider)
                                  _DateDivider(
                                    dateText: _formatDateDivider(
                                      message.createdAt,
                                    ),
                                  ),
                                _MessageBubble(
                                  message: message,
                                  isMe: isMe,
                                  searchQuery: searchQuery,
                                  conversation: activeConv,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    // Scroll-to-Bottom FAB
                    if (_showScrollToBottom)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: FloatingActionButton.small(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          elevation: 4,
                          onPressed: () {
                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                          child: const Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                      ),
                  ],
                ),
              ),

              // Message Input Field Footer
              Container(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 10,
                  bottom: MediaQuery.of(context).padding.bottom + 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.75),
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.15),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.mic_none_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) =>
                            _handleSendMessage(currentUserId, activeConv),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: const CircleBorder(),
                      ),
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () =>
                          _handleSendMessage(currentUserId, activeConv),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }
}

class _DateDivider extends StatelessWidget {
  final String dateText;

  const _DateDivider({required this.dateText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          dateText,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageResponse message;
  final bool isMe;
  final String searchQuery;
  final Conversation conversation;

  const _MessageBubble({
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
    final currentUserId = context
        .watch<UserProfileProvider>()
        .userProfile
        ?.userId;

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
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                    future: message.getDecryptedContent(
                      sl<EncryptionService>(),
                      currentUserId: currentUserId,
                    ),
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
                            fontWeight: isMatch
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          color: isMe
                              ? Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.75)
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.8),
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all_rounded,
                          size: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.85),
                        ),
                      ],
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
