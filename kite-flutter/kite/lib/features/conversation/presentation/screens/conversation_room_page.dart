import 'package:flutter/material.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/message_response.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_room_controller.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_room_state.dart';
import 'package:kite/features/presence/presentation/presence_provider.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:kite/features/social/domain/user_discovery.dart';
import 'package:kite/features/social/presentation/controllers/social_controller.dart';
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

  void _showConversationInfoModal(BuildContext context, bool isOnline) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ConversationInfoSheet(
        conversation: widget.conversation,
        isOnline: isOnline,
        onSearchTap: () {
          Navigator.pop(context);
          setState(() {
            _isSearching = true;
          });
        },
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
        'Sunday'
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
      'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
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

    final searchQuery = _searchController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.7),
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
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage:
                        widget.conversation.conversationPhoto != null &&
                                widget.conversation.conversationPhoto!.isNotEmpty
                            ? NetworkImage(
                                widget.conversation.conversationPhoto!,
                              )
                            : null,
                    child: widget.conversation.conversationPhoto == null ||
                            widget.conversation.conversationPhoto!.isEmpty
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
                  onPressed: () => _showConversationInfoModal(context, isOnline),
                ),
              ],
      ),
      body: Column(
        children: [
          // Messages Display List
          Expanded(
            child: Stack(
              children: [
                ValueListenableBuilder<ConversationRoomState>(
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
                                color:
                                    Theme.of(context).colorScheme.onSurfaceVariant,
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
                          final prevMessageInTime = state.messages[index + 1];
                          if (!_isSameDay(
                              message.createdAt, prevMessageInTime.createdAt)) {
                            showDateDivider = true;
                          }
                        }

                        return Column(
                          children: [
                            if (showDateDivider)
                              _DateDivider(
                                dateText:
                                    _formatDateDivider(message.createdAt),
                              ),
                            _MessageBubble(
                              message: message,
                              isMe: isMe,
                              searchQuery: searchQuery,
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
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
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
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                ),
              ],
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
                    onSubmitted: (_) => _handleSendMessage(currentUserId),
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
                  onPressed: () => _handleSendMessage(currentUserId),
                ),
              ],
            ),
          ),
        ],
      ),
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
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.8),
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

class _ConversationInfoSheet extends StatelessWidget {
  final Conversation conversation;
  final bool isOnline;
  final VoidCallback onSearchTap;

  const _ConversationInfoSheet({
    required this.conversation,
    required this.isOnline,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = conversation.name != null && conversation.name!.isNotEmpty
        ? conversation.name!
        : 'Chat';
    final initials = title.isNotEmpty ? title[0].toUpperCase() : 'C';

    final currentUserProfile =
        context.watch<UserProfileProvider>().userProfile;
    final currentUserId = currentUserProfile?.userId;

    List<UserDiscovery> socialPeople = [];
    try {
      socialPeople = sl<SocialController>().value.people;
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Large Avatar Header
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage:
                            conversation.conversationPhoto != null &&
                                    conversation.conversationPhoto!.isNotEmpty
                                ? NetworkImage(conversation.conversationPhoto!)
                                : null,
                        child: conversation.conversationPhoto == null ||
                                conversation.conversationPhoto!.isEmpty
                            ? Text(
                                initials,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              )
                            : null,
                      ),
                      if (isOnline)
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 3,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOnline ? 'Active now' : 'Offline',
                    style: TextStyle(
                      color: isOnline ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // E2EE Security Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'End-to-End Encrypted',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Messages and calls stay secured with X25519 & AES-256 encryption.',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Members List Section
            Text(
              'Members (${conversation.memberIds.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...conversation.memberIds.map((mId) {
              final isCurrentUser = mId == currentUserId;

              UserDiscovery? socialMatch;
              for (final p in socialPeople) {
                if (p.userId == mId) {
                  socialMatch = p;
                  break;
                }
              }

              String memberName;
              String usernameStr;
              String photoUrl = '';

              if (isCurrentUser && currentUserProfile != null) {
                final fn =
                    '${currentUserProfile.firstName} ${currentUserProfile.lastName}'
                        .trim();
                memberName = fn.isNotEmpty
                    ? '$fn (You)'
                    : '@${currentUserProfile.username} (You)';
                usernameStr = currentUserProfile.username;
                photoUrl = currentUserProfile.profileImageLink;
              } else if (socialMatch != null) {
                final fn = '${socialMatch.firstName} ${socialMatch.lastName}'
                    .trim();
                memberName = fn.isNotEmpty ? fn : socialMatch.username;
                usernameStr = socialMatch.username;
                photoUrl = socialMatch.profileImageLink;
              } else {
                memberName = conversation.name != null &&
                        conversation.name!.isNotEmpty
                    ? conversation.name!
                    : 'Member';
                usernameStr = mId.length > 8 ? mId.substring(0, 8) : mId;
              }

              final memberInitials = memberName.isNotEmpty
                  ? memberName[0].toUpperCase()
                  : 'M';

              final memberOnline = context
                  .watch<PresenceProvider>()
                  .isUserOnline(mId);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          backgroundImage: photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl.isEmpty
                              ? Text(
                                  memberInitials,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                )
                              : null,
                        ),
                        if (memberOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memberName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (usernameStr.isNotEmpty)
                            Text(
                              '@$usernameStr',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.key_rounded,
                            size: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Key Active',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            const Divider(height: 20),

            // Actions List
            _InfoSectionTile(
              icon: Icons.search_rounded,
              title: 'Search in Conversation',
              subtitle: 'Find specific messages',
              onTap: onSearchTap,
            ),
            const Divider(height: 20),
            _InfoSectionTile(
              icon: Icons.notifications_none_rounded,
              title: 'Mute Notifications',
              subtitle: 'Off',
              onTap: () {},
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoSectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _InfoSectionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right_rounded, size: 20)
          : null,
      onTap: onTap,
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageResponse message;
  final bool isMe;
  final String searchQuery;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.searchQuery,
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

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
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
                      ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
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
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: isMatch ? FontWeight.bold : FontWeight.normal,
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
                        ? Colors.white.withValues(alpha: 0.7)
                        : Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all_rounded,
                    size: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
