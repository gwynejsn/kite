import 'package:flutter/material.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/conversation_type.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_controller.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_state.dart';
import 'package:kite/features/presence/presentation/presence_provider.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:kite/features/social/domain/repositories/social_repository.dart';
import 'package:kite/features/social/domain/user_discovery.dart';
import 'package:kite/features/social/presentation/controllers/social_controller.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:provider/provider.dart';

class ConversationDetailsPage extends StatefulWidget {
  final Conversation conversation;
  final bool isOnline;
  final VoidCallback onSearchTap;

  const ConversationDetailsPage({
    super.key,
    required this.conversation,
    required this.isOnline,
    required this.onSearchTap,
  });

  @override
  State<ConversationDetailsPage> createState() => _ConversationDetailsPageState();
}

class _ConversationDetailsPageState extends State<ConversationDetailsPage> {
  bool _isMembersExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<ConversationState>(
      valueListenable: sl<ConversationController>(),
      builder: (context, conversationState, child) {
        final currentConv = conversationState.conversations.firstWhere(
          (c) => c.id == widget.conversation.id,
          orElse: () => widget.conversation,
        );

        final title = currentConv.name != null && currentConv.name!.isNotEmpty
            ? currentConv.name!
            : 'Chat';
        final initials = title.isNotEmpty ? title[0].toUpperCase() : 'C';

        final currentUserProfile =
            context.watch<UserProfileProvider>().userProfile;
        final currentUserId = currentUserProfile?.userId;

        List<UserDiscovery> socialPeople = [];
        try {
          socialPeople = sl<SocialController>().value.people;
        } catch (_) {}

        final isGroup = currentConv.type == ConversationType.group;
        final isUserAdmin = currentUserId != null &&
            currentConv.adminIds.contains(currentUserId);

        return Scaffold(
          appBar: AppBar(
            title: Text(isGroup ? 'Group Info' : 'Contact Info'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar & Main Title Header
                Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            backgroundImage:
                                currentConv.conversationPhoto != null &&
                                        currentConv.conversationPhoto!.isNotEmpty
                                    ? NetworkImage(currentConv.conversationPhoto!)
                                    : null,
                            child: currentConv.conversationPhoto == null ||
                                    currentConv.conversationPhoto!.isEmpty
                                ? Text(
                                    initials,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 36,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  )
                                : null,
                          ),
                          if (widget.isOnline)
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 3,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isGroup
                            ? '${currentConv.memberIds.length} members'
                            : (widget.isOnline ? 'Active now' : 'Offline'),
                        style: TextStyle(
                          color: widget.isOnline ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // E2EE Security Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        color: theme.colorScheme.primary,
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
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Collapsible Members Dropdown Section
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: ValueKey(
                          'members_${currentConv.id}_${currentConv.memberIds.length}_${currentConv.updatedAt.millisecondsSinceEpoch}'),
                      initiallyExpanded: _isMembersExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isMembersExpanded = expanded;
                        });
                      },
                      title: Row(
                        children: [
                          Text(
                            'Members (${currentConv.memberIds.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          if (isGroup && isUserAdmin)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => _showAddMembersDialog(
                                  context, currentUserId, currentConv),
                              icon: const Icon(Icons.person_add_alt_1_rounded,
                                  size: 16),
                              label: const Text(
                                'Add Member',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      children: currentConv.memberIds.map((mId) {
                        final isCurrentUser = mId == currentUserId;
                        final isAdmin = currentConv.adminIds.contains(mId);
                        final memberProfile = currentConv.memberProfiles[mId];

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

                        if (memberProfile != null) {
                          memberName = memberProfile.displayName;
                          if (isCurrentUser) memberName += ' (You)';
                          usernameStr = memberProfile.username;
                          photoUrl = memberProfile.profilePhoto ?? '';
                        } else if (isCurrentUser && currentUserProfile != null) {
                          final fn =
                              '${currentUserProfile.firstName} ${currentUserProfile.lastName}'
                                  .trim();
                          memberName = fn.isNotEmpty
                              ? '$fn (You)'
                              : '@${currentUserProfile.username} (You)';
                          usernameStr = currentUserProfile.username;
                          photoUrl = currentUserProfile.profileImageLink;
                        } else if (socialMatch != null) {
                          final fn =
                              '${socialMatch.firstName} ${socialMatch.lastName}'
                                  .trim();
                          memberName = fn.isNotEmpty ? fn : socialMatch.username;
                          usernameStr = socialMatch.username;
                          photoUrl = socialMatch.profileImageLink;
                        } else {
                          memberName = isCurrentUser ? 'You' : 'Member';
                          usernameStr =
                              mId.length > 8 ? mId.substring(0, 8) : mId;
                        }

                        final memberInitials = memberName.isNotEmpty
                            ? memberName[0].toUpperCase()
                            : 'M';

                        final memberOnline = context
                            .watch<PresenceProvider>()
                            .isUserOnline(mId);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 6.0),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    backgroundImage: photoUrl.isNotEmpty
                                        ? NetworkImage(photoUrl)
                                        : null,
                                    child: photoUrl.isEmpty
                                        ? Text(
                                            memberInitials,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color:
                                                  theme.colorScheme.onPrimaryContainer,
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
                                            color: theme.colorScheme.surface,
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
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            memberName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isAdmin) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'ADMIN',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (usernameStr.isNotEmpty)
                                      Text(
                                        '@$usernameStr',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isGroup &&
                                  isUserAdmin &&
                                  !isCurrentUser &&
                                  !isAdmin)
                                IconButton(
                                  icon: const Icon(
                                    Icons.person_remove_rounded,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  tooltip: 'Kick Member',
                                  onPressed: () => _confirmKickMember(
                                      context, currentConv, mId, memberName),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.key_rounded,
                                      size: 12,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Key Active',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions Section
                _InfoSectionTile(
                  icon: Icons.search_rounded,
                  title: 'Search in Conversation',
                  subtitle: 'Find specific messages',
                  onTap: widget.onSearchTap,
                ),
                const Divider(height: 20),
                _InfoSectionTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Mute Notifications',
                  subtitle: 'Off',
                  onTap: () {},
                ),
                if (isGroup) ...[
                  const Divider(height: 20),
                  _InfoSectionTile(
                    icon: Icons.exit_to_app_rounded,
                    title: 'Leave Group',
                    subtitle: 'Exit this group conversation',
                    iconColor: Colors.redAccent,
                    textColor: Colors.redAccent,
                    onTap: () => _confirmLeaveGroup(context, currentConv),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddMembersDialog(
      BuildContext context, String currentUserId, Conversation currentConv) async {
    final socialRepo = sl<SocialRepository>();
    List<UserDiscovery> availableFriends = [];
    final Set<String> selectedToAdd = {};
    bool isLoading = true;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (stfCtx, setStfState) {
            if (isLoading) {
              socialRepo.getPeopleToConnect().then((people) {
                if (dialogCtx.mounted) {
                  setStfState(() {
                    availableFriends = people
                        .where((p) =>
                            p.userId != currentUserId &&
                            !currentConv.memberIds.contains(p.userId))
                        .toList();
                    isLoading = false;
                  });
                }
              }).catchError((_) {
                if (dialogCtx.mounted) {
                  setStfState(() {
                    isLoading = false;
                  });
                }
              });
            }

            return AlertDialog(
              title: const Text('Add Members to Group'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : availableFriends.isEmpty
                        ? const Center(child: Text('No new contacts to add.'))
                        : ListView.builder(
                            itemCount: availableFriends.length,
                            itemBuilder: (_, index) {
                              final friend = availableFriends[index];
                              final isSel = selectedToAdd.contains(friend.userId);
                              final displayName =
                                  '${friend.firstName} ${friend.lastName}'.trim();
                              return CheckboxListTile(
                                value: isSel,
                                title: Text(displayName.isNotEmpty
                                    ? displayName
                                    : friend.username),
                                subtitle: Text('@${friend.username}'),
                                onChanged: (val) {
                                  setStfState(() {
                                    if (val == true) {
                                      selectedToAdd.add(friend.userId);
                                    } else {
                                      selectedToAdd.remove(friend.userId);
                                    }
                                  });
                                },
                              );
                            },
                          ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedToAdd.isEmpty
                      ? null
                      : () async {
                          Navigator.pop(dialogCtx);
                          try {
                            await sl<ConversationController>().addMembersToGroup(
                              conversationId: currentConv.id,
                              memberIds: selectedToAdd.toList(),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Members added successfully'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to add members: ${e.toString()}'),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          }
                        },
                  child: Text('Add (${selectedToAdd.length})'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmKickMember(
      BuildContext context, Conversation currentConv, String targetMemberId, String memberName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Kick Member'),
        content: Text('Are you sure you want to kick $memberName from this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Kick'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await sl<ConversationController>().kickMemberFromGroup(
          conversationId: currentConv.id,
          targetMemberId: targetMemberId,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$memberName has been kicked'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to kick member: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmLeaveGroup(BuildContext context, Conversation currentConv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group chat? You will no longer receive messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await sl<ConversationController>().leaveGroupConversation(
          conversationId: currentConv.id,
        );
        if (context.mounted) {
          Navigator.pop(context); // Close ConversationDetailsPage
          Navigator.pop(context); // Pop ConversationRoomPage back to list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You left the group conversation'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to leave group: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}

class _InfoSectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;

  const _InfoSectionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? Theme.of(context).colorScheme.primary;
    final effectiveTextColor = textColor ?? Theme.of(context).colorScheme.onSurface;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: effectiveIconColor),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: effectiveTextColor),
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
