import 'package:flutter/material.dart';
import 'package:kite/features/conversation/domain/member_profile.dart';

class MemberTile extends StatelessWidget {
  final String memberId;
  final MemberProfile? profile;
  final bool isAdmin;
  final bool isCurrentAdmin;
  final bool isMe;
  final VoidCallback? onKick;
  final VoidCallback? onPromote;
  final VoidCallback? onDemote;

  const MemberTile({
    super.key,
    required this.memberId,
    this.profile,
    required this.isAdmin,
    required this.isCurrentAdmin,
    required this.isMe,
    this.onKick,
    this.onPromote,
    this.onDemote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = profile?.displayName ?? 'User';
    final photoUrl = profile?.profilePhoto;
    final initials = profile?.initials ??
        (displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U');
    final username = profile?.username ?? memberId;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
              ? NetworkImage(photoUrl)
              : null,
          child: (photoUrl == null || photoUrl.isEmpty)
              ? Text(
                  initials,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ADMIN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '@$username',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: (isCurrentAdmin && !isMe)
            ? PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onSelected: (action) {
                  if (action == 'promote' && onPromote != null) {
                    onPromote!();
                  } else if (action == 'demote' && onDemote != null) {
                    onDemote!();
                  } else if (action == 'kick' && onKick != null) {
                    onKick!();
                  }
                },
                itemBuilder: (context) => [
                  if (!isAdmin)
                    const PopupMenuItem(
                      value: 'promote',
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Make Admin'),
                        ],
                      ),
                    )
                  else
                    const PopupMenuItem(
                      value: 'demote',
                      child: Row(
                        children: [
                          Icon(Icons.remove_moderator_outlined,
                              size: 18, color: Colors.orange),
                          SizedBox(width: 10),
                          Text('Dismiss as Admin',
                              style: TextStyle(color: Colors.orange)),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'kick',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove_outlined,
                            size: 18, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Remove from Group',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
