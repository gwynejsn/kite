import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_controller.dart';
import 'package:kite/features/media/domain/repositories/media_repository.dart';
import 'package:kite/shared/di/injection_container.dart';

class EditGroupInfoDialog extends StatefulWidget {
  final Conversation conversation;

  const EditGroupInfoDialog({
    super.key,
    required this.conversation,
  });

  static Future<void> show(
    BuildContext context, {
    required Conversation conversation,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => EditGroupInfoDialog(conversation: conversation),
    );
  }

  @override
  State<EditGroupInfoDialog> createState() => _EditGroupInfoDialogState();
}

class _EditGroupInfoDialogState extends State<EditGroupInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _photoController;

  bool _isSaving = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.conversation.name ?? '');
    _photoController =
        TextEditingController(text: widget.conversation.conversationPhoto ?? '');
    _photoController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final mediaRepo = sl<MediaRepository>();
      final pickResult = await mediaRepo.pickImage(source);
      if (pickResult == null) return;

      setState(() => _isUploading = true);

      final uploadedUrl = await mediaRepo.uploadUnencryptedMedia(
        rawBytes: pickResult.rawBytes,
        fileName: pickResult.fileName,
      );

      if (mounted) {
        setState(() {
          _photoController.text = uploadedUrl;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group photo uploaded successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            if (_photoController.text.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _photoController.clear();
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final newName = _nameController.text.trim();
    final newPhoto = _photoController.text.trim();

    setState(() => _isSaving = true);

    try {
      await sl<ConversationController>().updateGroupConversationInfo(
        conversationId: widget.conversation.id,
        groupName: newName.isNotEmpty ? newName : null,
        conversationPhoto: newPhoto.isNotEmpty ? newPhoto : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group information updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update group: ${e.toString()}'),
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
    final photoUrl = _photoController.text.trim();

    return AlertDialog(
      title: const Text('Edit Group Info'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Photo Avatar with Edit Badge
              Center(
                child: GestureDetector(
                  onTap: (_isSaving || _isUploading) ? null : _showImageSourcePicker,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage:
                            photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                        child: _isUploading
                            ? const CircularProgressIndicator()
                            : (photoUrl.isEmpty
                                ? Icon(
                                    Icons.group_rounded,
                                    size: 42,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  )
                                : null),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: theme.colorScheme.primary,
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed:
                    (_isSaving || _isUploading) ? null : _showImageSourcePicker,
                icon: const Icon(Icons.image_rounded, size: 16),
                label: const Text('Change Photo'),
              ),
              const SizedBox(height: 16),
              // Group Name input
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'Enter group name...',
                  prefixIcon: const Icon(Icons.group_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Group name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Group Cover Photo URL input
              TextFormField(
                controller: _photoController,
                decoration: InputDecoration(
                  labelText: 'Photo URL (Optional)',
                  hintText: 'https://example.com/photo.jpg',
                  prefixIcon: const Icon(Icons.link_rounded),
                  suffixIcon: photoUrl.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => _photoController.clear(),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: (_isSaving || _isUploading)
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_isSaving || _isUploading) ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
