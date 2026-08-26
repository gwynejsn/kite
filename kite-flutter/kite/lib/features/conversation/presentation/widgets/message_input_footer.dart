import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessageInputFooter extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSend;
  final Function(ImageSource source)? onPickImage;
  final Function(ImageSource source)? onPickVideo;

  const MessageInputFooter({
    super.key,
    required this.textController,
    required this.onSend,
    this.onPickImage,
    this.onPickVideo,
  });

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: Colors.blue),
                  title: const Text('Photo Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    onPickImage?.call(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: Colors.green),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    onPickImage?.call(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_library_rounded, color: Colors.purple),
                  title: const Text('Video Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    onPickVideo?.call(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam_rounded, color: Colors.red),
                  title: const Text('Record Video'),
                  onTap: () {
                    Navigator.pop(context);
                    onPickVideo?.call(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.75),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => _showAttachmentOptions(context),
          ),
          IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => onPickImage?.call(ImageSource.camera),
          ),
          Expanded(
            child: TextField(
              controller: textController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: const CircleBorder(),
            ),
            icon: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
