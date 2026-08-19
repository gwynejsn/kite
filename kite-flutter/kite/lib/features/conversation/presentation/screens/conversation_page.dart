import 'package:flutter/material.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_controller.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_state.dart';
import 'package:kite/features/conversation/presentation/screens/conversation_room_page.dart';
import 'package:kite/features/presence/presentation/presence_provider.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:kite/features/social/presentation/screens/social_page.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:kite/shared/security/encryption_service.dart';
import 'package:provider/provider.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late final ConversationController _controller;
  String? _lastSubscribedUserId;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = sl<ConversationController>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _syncPresences(ConversationState state, String? currentUserId) {
    if (state.conversations.isNotEmpty && currentUserId != null) {
      final memberIds = state.conversations
          .expand((c) => c.memberIds)
          .where((id) => id != currentUserId && id.isNotEmpty)
          .toSet();
      if (memberIds.isNotEmpty) {
        context.read<PresenceProvider>().fetchAndTrackPresences(memberIds);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<UserProfileProvider>().userProfile?.userId;

    if (userId != null &&
        userId.isNotEmpty &&
        _lastSubscribedUserId != userId) {
      _lastSubscribedUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.fetchConversations(currentUserId: userId);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: 'Search chats...',
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
            : const Text(
                'Chats',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<ConversationState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          _syncPresences(state, userId);

          if (state.isLoading && state.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && state.conversations.isEmpty) {
            return _ErrorView(
              errorMessage: state.errorMessage!,
              onRetry: () =>
                  _controller.fetchConversations(currentUserId: userId),
            );
          }

          if (state.conversations.isEmpty) {
            return _EmptyConversationsView(
              onRefresh: () =>
                  _controller.fetchConversations(currentUserId: userId),
            );
          }

          final query = _searchController.text.trim().toLowerCase();
          final filteredConversations = query.isEmpty
              ? state.conversations
              : state.conversations.where((c) {
                  final name = (c.name ?? '').toLowerCase();
                  return name.contains(query);
                }).toList();

          if (filteredConversations.isEmpty && query.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No chats matching "$query"',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                _controller.fetchConversations(currentUserId: userId),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: filteredConversations.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 76),
              itemBuilder: (context, index) {
                return _ConversationTile(
                  conversation: filteredConversations[index],
                  currentUserId: userId,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String? currentUserId;

  const _ConversationTile({
    required this.conversation,
    this.currentUserId,
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
    }
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final title = conversation.name != null && conversation.name!.isNotEmpty
        ? conversation.name!
        : 'Conversation';

    final timestampStr = conversation.lastMessage != null
        ? _formatTime(conversation.lastMessage!.timestamp)
        : _formatTime(conversation.updatedAt);

    final initials = title.isNotEmpty ? title[0].toUpperCase() : 'C';

    final isOnline = context.watch<PresenceProvider>().isAnyMemberOnline(
          conversation.memberIds,
          currentUserId,
        );

    final isSentByMe = conversation.lastMessage != null &&
        currentUserId != null &&
        conversation.lastMessage!.senderId == currentUserId;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: conversation.conversationPhoto != null &&
                    conversation.conversationPhoto!.isNotEmpty
                ? NetworkImage(conversation.conversationPhoto!)
                : null,
            child: conversation.conversationPhoto == null ||
                    conversation.conversationPhoto!.isEmpty
                ? Text(
                    initials,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  )
                : null,
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2.5,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Text(
            timestampStr,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: conversation.lastMessage != null
            ? FutureBuilder<String>(
                future: conversation.lastMessage!.getDecryptedContent(
                  sl<EncryptionService>(),
                  currentUserId: currentUserId,
                ),
                builder: (context, snapshot) {
                  final text = snapshot.data ??
                      (snapshot.connectionState == ConnectionState.waiting
                          ? 'Loading message...'
                          : 'Encrypted Message');
                  return Row(
                    children: [
                      if (isSentByMe) ...[
                        Icon(
                          Icons.done_all_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            : Text(
                'No messages yet',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConversationRoomPage(conversation: conversation),
          ),
        );
      },
    );
  }
}

class _EmptyConversationsView extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyConversationsView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No conversations yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a chat to get connected!',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SocialPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people_outline_rounded, size: 18),
                  label: const Text(
                    'Discover People',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorView({required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
