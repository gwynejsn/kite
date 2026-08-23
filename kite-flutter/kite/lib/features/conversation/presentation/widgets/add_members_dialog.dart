import 'package:flutter/material.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_controller.dart';
import 'package:kite/features/social/domain/repositories/social_repository.dart';
import 'package:kite/features/social/domain/user_discovery.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:kite/shared/security/encryption_service.dart';

class AddMembersDialog extends StatefulWidget {
  final Conversation conversation;
  final String currentUserId;

  const AddMembersDialog({
    super.key,
    required this.conversation,
    required this.currentUserId,
  });

  static Future<void> show(
    BuildContext context, {
    required Conversation conversation,
    required String currentUserId,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AddMembersDialog(
        conversation: conversation,
        currentUserId: currentUserId,
      ),
    );
  }

  @override
  State<AddMembersDialog> createState() => _AddMembersDialogState();
}

class _AddMembersDialogState extends State<AddMembersDialog> {
  final socialRepo = sl<SocialRepository>();
  List<UserDiscovery> availableFriends = [];
  final Set<String> selectedToAdd = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  void _loadFriends() {
    socialRepo.getPeopleToConnect().then((people) {
      if (mounted) {
        setState(() {
          availableFriends = people
              .where((p) =>
                  p.userId != widget.currentUserId &&
                  !widget.conversation.memberIds.contains(p.userId))
              .toList();
          isLoading = false;
        });
      }
    }).catchError((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> _submitAddMembers() async {
    Navigator.pop(context);
    try {
      final encryptionService = sl<EncryptionService>();
      Map<String, String>? groupKeyMap;

      final encryptedGroupKey =
          widget.conversation.groupKeyMap[widget.currentUserId];
      if (encryptedGroupKey != null && encryptedGroupKey.isNotEmpty) {
        try {
          final groupKey = await encryptionService.decryptGroupKey(
            encryptedGroupKey: encryptedGroupKey,
          );
          groupKeyMap = {};
          for (final friend in availableFriends
              .where((f) => selectedToAdd.contains(f.userId))) {
            final pubKey = (friend.publicKey != null &&
                    friend.publicKey!.isNotEmpty)
                ? friend.publicKey
                : widget.conversation.memberPublicKeys[friend.userId];
            if (pubKey != null && pubKey.isNotEmpty) {
              groupKeyMap[friend.userId] =
                  await encryptionService.encryptGroupKeyForRecipient(
                groupKeyBase64: groupKey,
                recipientPublicKeyBase64: pubKey,
              );
            } else {
              debugPrint(
                  'Warning: Public key missing for user ${friend.userId}');
            }
          }
        } catch (e) {
          debugPrint('Could not encrypt group key for new members: $e');
        }
      }

      await sl<ConversationController>().addMembersToGroup(
        conversationId: widget.conversation.id,
        memberIds: selectedToAdd.toList(),
        groupKeyMap: groupKeyMap,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Members added successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add members: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          setState(() {
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedToAdd.isEmpty ? null : _submitAddMembers,
          child: Text('Add (${selectedToAdd.length})'),
        ),
      ],
    );
  }
}
