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
  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.conversation.name ?? '');
    _photoController = TextEditingController(
        text: widget.conversation.conversationPhoto ?? '');
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
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (image == null) return;

      setState(() => _isUploadingImage = true);

      final bytes = await image.readAsBytes();
      final imageUrl = await sl<MediaRepository>().uploadUnencryptedMedia(
        rawBytes: bytes,
        fileName: image.name,
      );

      setState(() {
        _photoController.text = imageUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group photo uploaded successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error uploading group photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload group photo'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading:
                    const Icon(Icons.photo_library_rounded, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt_rounded, color: Colors.green),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              if (_photoController.text.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _photoController.clear();
                    });
                  },
                ),
            ],
          ),
        );
      },
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
              // Avatar Preview & Camera Button (matching Profile Page style)
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: _isUploadingImage
                          ? const CircularProgressIndicator()
                          : (photoUrl.isEmpty
                              ? Icon(
                                  Icons.group_rounded,
                                  size: 48,
                                  color: theme.colorScheme.onPrimaryContainer,
                                )
                              : null),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: (_isSaving || _isUploadingImage)
                            ? null
                            : _showImagePickerModal,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: (_isSaving || _isUploadingImage)
                      ? null
                      : _showImagePickerModal,
                  child: Text(
                    _isUploadingImage
                        ? 'Uploading...'
                        : (photoUrl.isNotEmpty
                            ? 'Change Group Photo'
                            : 'Upload Group Photo'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Group Name Input
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: (_isSaving || _isUploadingImage)
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_isSaving || _isUploadingImage) ? null : _handleSave,
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
