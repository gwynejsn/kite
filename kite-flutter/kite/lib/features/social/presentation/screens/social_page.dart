import 'package:flutter/material.dart';
import 'package:kite/features/presence/presentation/presence_provider.dart';
import 'package:kite/features/social/domain/relation_status.dart';
import 'package:kite/features/social/domain/user_discovery.dart';
import 'package:kite/features/social/presentation/controllers/social_controller.dart';
import 'package:kite/features/social/presentation/controllers/social_state.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:provider/provider.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage>
    with SingleTickerProviderStateMixin {
  late final SocialController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = sl<SocialController>();
    _controller.fetchPeople();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _syncPresences(SocialState state) {
    if (state.people.isNotEmpty) {
      final friendIds = state.people
          .where((p) => p.relationStatus == RelationStatus.accepted)
          .map((p) => p.userId)
          .toSet();
      if (friendIds.isNotEmpty) {
        context.read<PresenceProvider>().fetchAndTrackPresences(friendIds);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'People',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Discover'),
            Tab(text: 'Requests'),
            Tab(text: 'Friends'),
          ],
        ),
      ),
      body: ValueListenableBuilder<SocialState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          _syncPresences(state);

          if (state.isLoading && state.people.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && state.people.isEmpty) {
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
                      onPressed: () => _controller.fetchPeople(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final discoverList = state.people
              .where((p) => p.relationStatus == null)
              .toList();
          final requestsList = state.people
              .where((p) => p.relationStatus == RelationStatus.pending)
              .toList();
          final friendsList = state.people
              .where((p) => p.relationStatus == RelationStatus.accepted)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _UserListView(
                users: discoverList,
                emptyMessage: 'No new people to discover right now.',
                controller: _controller,
              ),
              _UserListView(
                users: requestsList,
                emptyMessage: 'No pending friend requests.',
                controller: _controller,
              ),
              _UserListView(
                users: friendsList,
                emptyMessage: 'You have not added any friends yet.',
                controller: _controller,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserListView extends StatelessWidget {
  final List<UserDiscovery> users;
  final String emptyMessage;
  final SocialController controller;

  const _UserListView({
    required this.users,
    required this.emptyMessage,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => controller.fetchPeople(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 56,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      emptyMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchPeople(),
      child: ListView.separated(
        padding: const EdgeInsets.all(12.0),
        itemCount: users.length,
        separatorBuilder: (context, index) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final user = users[index];
          return _UserCard(user: user, controller: controller);
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserDiscovery user;
  final SocialController controller;

  const _UserCard({required this.user, required this.controller});

  @override
  Widget build(BuildContext context) {
    final fullName = '${user.firstName} ${user.lastName}'.trim();
    final nameDisplay = fullName.isNotEmpty ? fullName : user.username;
    final initials = nameDisplay.isNotEmpty
        ? nameDisplay[0].toUpperCase()
        : 'U';

    final isOnline = user.relationStatus == RelationStatus.accepted &&
        context.watch<PresenceProvider>().isUserOnline(user.userId);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage: user.profileImageLink.isNotEmpty
                      ? NetworkImage(user.profileImageLink)
                      : null,
                  child: user.profileImageLink.isEmpty
                      ? Text(
                          initials,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nameDisplay,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  if (user.bio.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.bio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // 1. Discover Tab (Not Connected)
    if (user.relationStatus == null) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onPressed: () => controller.sendFriendRequest(user.userId),
        icon: const Icon(Icons.person_add_rounded, size: 18),
        label: const Text('Add'),
      );
    }

    // 2. Pending Requests Tab
    if (user.relationStatus == RelationStatus.pending) {
      if (user.isRequester == true) {
        // Outgoing Request
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: user.relationId != null
              ? () => controller.declineFriendRequest(user.relationId!)
              : null,
          child: const Text('Cancel'),
        );
      } else {
        // Incoming Request
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
              tooltip: 'Accept',
              onPressed: user.relationId != null
                  ? () => controller.acceptFriendRequest(user.relationId!)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.cancel_rounded, color: Colors.red),
              tooltip: 'Decline',
              onPressed: user.relationId != null
                  ? () => controller.declineFriendRequest(user.relationId!)
                  : null,
            ),
          ],
        );
      }
    }

    // 3. Friends Tab (Accepted)
    if (user.relationStatus == RelationStatus.accepted) {
      return PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'block') {
            controller.blockUser(user.userId);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'block',
            child: Row(
              children: [
                Icon(Icons.block_rounded, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Block User', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 4),
              Text(
                'Friends',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
