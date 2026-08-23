import 'package:flutter/material.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/conversation_type.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_controller.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_state.dart';
import 'package:kite/features/conversation/presentation/widgets/add_members_dialog.dart';
import 'package:kite/features/conversation/presentation/widgets/info_section_tile.dart';
import 'package:kite/features/conversation/presentation/widgets/member_tile.dart';
import 'package:kite/features/presence/presentation/presence_provider.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
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
  State<ConversationDetailsPage> createState() =>
      _ConversationDetailsPageState();
}

class _ConversationDetailsPageState extends State<ConversationDetailsPage> {
  bool _isMembersExpanded = false;

  void _confirmKickMember(
      BuildContext context, String memberId, String memberName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kick Member'),
        content: Text('Are you sure you want to remove $memberName from the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await sl<ConversationController>().kickMemberFromGroup(
                  conversationId: widget.conversation.id,
                  targetMemberId: memberId,
                );
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$memberName has been removed from the group'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to remove member: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Kick'),
          ),
        ],
      ),
    );
  }

  void _confirmPromoteMember(
      BuildContext context, String memberId, String memberName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Make Admin'),
        content: Text('Are you sure you want to promote $memberName to an Admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await sl<ConversationController>().promoteMemberInGroup(
                  conversationId: widget.conversation.id,
                  targetMemberId: memberId,
                );
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$memberName is now an Admin'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to promote member: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Make Admin'),
          ),
        ],
      ),
    );
  }

  void _confirmDemoteMember(
      BuildContext context, String memberId, String memberName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dismiss as Admin'),
        content: Text('Are you sure you want to remove Admin privileges from $memberName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await sl<ConversationController>().demoteMemberInGroup(
                  conversationId: widget.conversation.id,
                  targetMemberId: memberId,
                );
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$memberName is no longer an Admin'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to demote member: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Dismiss Admin'),
          ),
        ],
      ),
    );
  }

  void _confirmLeaveGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await sl<ConversationController>()
                    .leaveGroupConversation(conversationId: widget.conversation.id);
                if (mounted && context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              } catch (e) {
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to leave group: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<ConversationState>(
      valueListenable: sl<ConversationController>(),
      builder: (context, convState, child) {
        final currentConv = convState.conversations.firstWhere(
          (c) => c.id == widget.conversation.id,
          orElse: () => widget.conversation,
        );

        final currentUserId =
            context.watch<UserProfileProvider>().userProfile?.userId;
        final isGroup = currentConv.type == ConversationType.group;
        final presenceProvider = context.watch<PresenceProvider>();

        final otherMemberId = currentConv.memberIds.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );
        final liveIsOnline = isGroup
            ? presenceProvider.isAnyMemberOnline(
                currentConv.memberIds, currentUserId)
            : presenceProvider.isUserOnline(otherMemberId);

        final isAdmin =
            isGroup && currentUserId != null && currentConv.adminIds.contains(currentUserId);
        final title = currentConv.name ?? 'Conversation Info';
        final photoUrl = currentConv.conversationPhoto;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Details'),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            children: [
              const SizedBox(height: 12),

              // Hero Profile Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage:
                              (photoUrl != null && photoUrl.isNotEmpty)
                                  ? NetworkImage(photoUrl)
                                  : null,
                          child: (photoUrl == null || photoUrl.isEmpty)
                              ? Icon(
                                  isGroup
                                      ? Icons.group_rounded
                                      : Icons.person_rounded,
                                  size: 46,
                                  color: theme.colorScheme.onPrimaryContainer,
                                )
                              : null,
                        ),
                        if (liveIsOnline)
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGroup
                          ? '${currentConv.memberIds.length} Members'
                          : (liveIsOnline ? 'Online' : 'Offline'),
                      style: TextStyle(
                        fontSize: 14,
                        color: !isGroup && liveIsOnline
                            ? Colors.green
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: !isGroup && liveIsOnline
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // End-to-End Encryption Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Messages are end-to-end encrypted. No one outside of this chat can read them.',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Options
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    InfoSectionTile(
                      icon: Icons.search_rounded,
                      title: 'Search in Conversation',
                      onTap: widget.onSearchTap,
                    ),
                    const Divider(height: 1, indent: 56),
                    InfoSectionTile(
                      icon: Icons.perm_media_outlined,
                      title: 'Media, Links, and Docs',
                      subtitle: '0 items',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Group Members Expansion List
              if (isGroup) ...[
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: _isMembersExpanded,
                    onExpansionChanged: (val) {
                      setState(() {
                        _isMembersExpanded = val;
                      });
                    },
                    leading: Icon(
                      Icons.people_outline_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text(
                      'Group Members',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${currentConv.memberIds.length} members'),
                    children: [
                      if (isAdmin)
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.primary.withValues(alpha: 0.15),
                            child: Icon(
                              Icons.person_add_outlined,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Add Members',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () => AddMembersDialog.show(
                            context,
                            conversation: currentConv,
                            currentUserId: currentUserId,
                          ),
                        ),
                      ...currentConv.memberIds.map((mId) {
                        final memberProf = currentConv.memberProfiles[mId];
                        final memberIsAdmin = currentConv.adminIds.contains(mId);
                        final isMe = mId == currentUserId;
                        final memberName = memberProf?.displayName ?? 'User';

                        return MemberTile(
                          memberId: mId,
                          profile: memberProf,
                          isAdmin: memberIsAdmin,
                          isCurrentAdmin: isAdmin,
                          isMe: isMe,
                          onKick: () => _confirmKickMember(context, mId, memberName),
                          onPromote: () => _confirmPromoteMember(context, mId, memberName),
                          onDemote: () => _confirmDemoteMember(context, mId, memberName),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Leave Group Option
                Card(
                  elevation: 0,
                  color: Colors.red.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InfoSectionTile(
                    icon: Icons.exit_to_app_rounded,
                    title: 'Leave Group',
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () => _confirmLeaveGroup(context),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
