import 'package:flutter/material.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_controller.dart';
import 'package:kite/features/conversation/presentation/screens/conversation_room_page.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:kite/features/social/domain/repositories/social_repository.dart';
import 'package:kite/features/social/domain/user_discovery.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:provider/provider.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final Set<String> _selectedMemberIds = {};
  final List<UserDiscovery> _selectedMembers = [];

  List<UserDiscovery> _friends = [];
  bool _isLoadingFriends = true;
  bool _isSubmitting = false;
  String? _friendsError;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    final currentUserId =
        context.read<UserProfileProvider>().userProfile?.userId;

    setState(() {
      _isLoadingFriends = true;
      _friendsError = null;
    });

    try {
      final socialRepo = sl<SocialRepository>();
      final people = await socialRepo.getPeopleToConnect();

      if (mounted) {
        setState(() {
          _friends = people.where((p) => p.userId != currentUserId).toList();
          _isLoadingFriends = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _friendsError = 'Failed to load contacts: ${e.toString()}';
          _isLoadingFriends = false;
        });
      }
    }
  }

  void _toggleMember(UserDiscovery user) {
    setState(() {
      if (_selectedMemberIds.contains(user.userId)) {
        _selectedMemberIds.remove(user.userId);
        _selectedMembers.removeWhere((m) => m.userId == user.userId);
      } else {
        _selectedMemberIds.add(user.userId);
        _selectedMembers.add(user);
      }
    });
  }

  Future<void> _handleCreateGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one member for the group'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final controller = sl<ConversationController>();
      final groupName = _nameController.text.trim();
      final photoUrl = _photoController.text.trim();

      final Conversation? newGroup = await controller.createGroupConversation(
        name: groupName,
        memberIds: _selectedMemberIds.toList(),
        photoUrl: photoUrl.isNotEmpty ? photoUrl : null,
      );

      if (mounted && newGroup != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ConversationRoomPage(conversation: newGroup),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating group: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchQuery = _searchController.text.trim().toLowerCase();

    final filteredFriends = searchQuery.isEmpty
        ? _friends
        : _friends.where((f) {
            final fullName = '${f.firstName} ${f.lastName}'.toLowerCase();
            final username = f.username.toLowerCase();
            return fullName.contains(searchQuery) || username.contains(searchQuery);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Group Chat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _handleCreateGroup,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Create',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Top Section: Group details input
            Container(
              padding: const EdgeInsets.all(16.0),
              color: theme.colorScheme.surfaceContainerLow,
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.group_rounded,
                          size: 32,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Group Name',
                            hintText: 'Enter group name...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Group name is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _photoController,
                    decoration: InputDecoration(
                      labelText: 'Group Cover Photo URL (Optional)',
                      hintText: 'https://example.com/photo.jpg',
                      prefixIcon: const Icon(Icons.image_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Selected Members Chips Header
            if (_selectedMembers.isNotEmpty)
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: theme.colorScheme.surface,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _selectedMembers.length,
                  itemBuilder: (context, index) {
                    final member = _selectedMembers[index];
                    final displayName =
                        '${member.firstName} ${member.lastName}'.trim();
                    final name = displayName.isNotEmpty
                        ? displayName
                        : member.username;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InputChip(
                        avatar: CircleAvatar(
                          backgroundImage: member.profileImageLink.isNotEmpty
                              ? NetworkImage(member.profileImageLink)
                              : null,
                          child: member.profileImageLink.isEmpty
                              ? Text(
                                  name[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 10),
                                )
                              : null,
                        ),
                        label: Text(name),
                        onDeleted: () => _toggleMember(member),
                        deleteIconColor: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),

            const Divider(height: 1),

            // Search Bar for Members
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search friends to add...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // Friends Selection List
            Expanded(
              child: _isLoadingFriends
                  ? const Center(child: CircularProgressIndicator())
                  : _friendsError != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _friendsError!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: theme.colorScheme.error),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _loadFriends,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : filteredFriends.isEmpty
                          ? Center(
                              child: Text(
                                searchQuery.isNotEmpty
                                    ? 'No friends matching "$searchQuery"'
                                    : 'No friends found to add',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredFriends.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1, indent: 72),
                              itemBuilder: (context, index) {
                                final friend = filteredFriends[index];
                                final isSelected =
                                    _selectedMemberIds.contains(friend.userId);
                                final name =
                                    '${friend.firstName} ${friend.lastName}'
                                        .trim();
                                final displayName = name.isNotEmpty
                                    ? name
                                    : friend.username;

                                return CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (_) => _toggleMember(friend),
                                  activeColor: theme.colorScheme.primary,
                                  secondary: CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    backgroundImage:
                                        friend.profileImageLink.isNotEmpty
                                            ? NetworkImage(
                                                friend.profileImageLink)
                                            : null,
                                    child: friend.profileImageLink.isEmpty
                                        ? Text(
                                            displayName[0].toUpperCase(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '@${friend.username}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSubmitting ? null : _handleCreateGroup,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(
              _isSubmitting
                  ? 'Creating Group...'
                  : 'Create Group (${_selectedMemberIds.length} Selected)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
