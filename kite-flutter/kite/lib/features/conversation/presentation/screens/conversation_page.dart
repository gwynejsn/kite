import 'package:flutter/material.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_controller.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_state.dart';
import 'package:kite/features/conversation/presentation/screens/conversation_room_page.dart';
import 'package:kite/features/conversation/presentation/screens/create_group_page.dart';
import 'package:kite/features/conversation/presentation/widgets/conversation_tile.dart';
import 'package:kite/features/social/presentation/screens/social_page.dart';
import 'package:kite/features/wingman/presentation/widgets/wingman_bottom_sheet.dart';
import 'package:kite/features/presence/presentation/presence_provider.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:kite/shared/widgets/skeleton_loader.dart';
import 'package:provider/provider.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late final ConversationController _controller;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = sl<ConversationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentUserId =
            context.read<UserProfileProvider>().userProfile?.userId;
        _controller.fetchConversations(currentUserId: currentUserId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId =
        context.watch<UserProfileProvider>().userProfile?.userId;

    if (currentUserId != null && currentUserId.isNotEmpty) {
      _controller.updateCurrentUser(currentUserId);
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search chats...',
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() {}),
              )
            : const Text(
                'Kite',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
        actions: [
          IconButton(
            icon:
                Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'Create Group',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateGroupPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<ConversationState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.conversations.isNotEmpty) {
            final allMemberIds = <String>{};
            for (final c in state.conversations) {
              for (final mId in c.memberIds) {
                if (mId != currentUserId && mId.isNotEmpty) {
                  allMemberIds.add(mId);
                }
              }
            }
            if (allMemberIds.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context
                      .read<PresenceProvider>()
                      .fetchAndTrackPresences(allMemberIds);
                }
              });
            }
          }

          if (state.isLoading) {
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8.0),
              itemCount: 8,
              itemBuilder: (context, index) => const SkeletonLoader(
                child: ListTile(
                  leading: CircleAvatar(radius: 28),
                  title: SkeletonBox(width: 140, height: 16),
                  subtitle: SkeletonBox(width: 200, height: 12),
                ),
              ),
            );
          }

          if (state.errorMessage != null && state.conversations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _controller.fetchConversations(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final searchQuery = _searchController.text.trim().toLowerCase();
          final filteredList = state.conversations.where((c) {
            if (searchQuery.isEmpty) return true;
            final name = (c.name ?? '').toLowerCase();
            return name.contains(searchQuery);
          }).toList();

          if (filteredList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    searchQuery.isNotEmpty
                        ? Icons.search_off_rounded
                        : Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color:
                        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    searchQuery.isNotEmpty
                        ? 'No conversations match "$searchQuery"'
                        : 'No conversations yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (searchQuery.isEmpty)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SocialPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text('Connect with People'),
                    ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _controller.fetchConversations(),
            child: ListView.separated(
              itemCount: filteredList.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 84),
              itemBuilder: (context, index) {
                final conv = filteredList[index];
                return ConversationTile(
                  conversation: conv,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationRoomPage(
                          conversation: conv,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showWingmanBottomSheet(context);
        },
        tooltip: 'Kite AI Wingman',
        child: Image.asset(
          'assets/images/kite_icon.png',
          width: 28,
          height: 28,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.auto_awesome_rounded,
          ),
        ),
      ),
    );
  }
}
