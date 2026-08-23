import 'package:flutter/material.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/conversation_type.dart';

class ConversationRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Conversation conversation;
  final bool isOnline;
  final bool isSearching;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onToggleSearch;
  final VoidCallback onOpenDetails;

  const ConversationRoomAppBar({
    super.key,
    required this.conversation,
    required this.isOnline,
    required this.isSearching,
    required this.searchController,
    required this.onSearchChanged,
    required this.onToggleSearch,
    required this.onOpenDetails,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGroup = conversation.type == ConversationType.group;

    final titleText = conversation.name ?? 'Conversation';
    final photoUrl = conversation.conversationPhoto;

    return AppBar(
      titleSpacing: 0,
      title: isSearching
          ? TextField(
              controller: searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search messages...',
                border: InputBorder.none,
              ),
              onChanged: onSearchChanged,
            )
          : InkWell(
              onTap: onOpenDetails,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                              ? NetworkImage(photoUrl)
                              : null,
                          child: (photoUrl == null || photoUrl.isEmpty)
                              ? Icon(
                                  isGroup
                                      ? Icons.group_rounded
                                      : Icons.person_rounded,
                                  color: theme.colorScheme.onPrimaryContainer,
                                  size: 20,
                                )
                              : null,
                        ),
                        if (isOnline)
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
                                  color: theme.colorScheme.surface,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isGroup
                                ? '${conversation.memberIds.length} members'
                                : (isOnline ? 'Online' : 'Offline'),
                            style: TextStyle(
                              fontSize: 11,
                              color: !isGroup && isOnline
                                  ? Colors.green
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: !isGroup && isOnline
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close_rounded : Icons.search_rounded),
          onPressed: onToggleSearch,
        ),
        IconButton(
          icon: const Icon(Icons.info_outline_rounded),
          onPressed: onOpenDetails,
        ),
      ],
    );
  }
}
