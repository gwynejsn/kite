import 'package:flutter/material.dart';
import 'package:kite/features/media/domain/models/encrypted_media_payload.dart';
import 'package:kite/features/media/domain/repositories/media_repository.dart';
import 'package:kite/shared/di/injection_container.dart';

class EncryptedFileView extends StatefulWidget {
  final String mediaUrl;
  final EncryptedMediaPayload payload;
  final bool isMe;

  const EncryptedFileView({
    super.key,
    required this.mediaUrl,
    required this.payload,
    required this.isMe,
  });

  @override
  State<EncryptedFileView> createState() => _EncryptedFileViewState();
}

class _EncryptedFileViewState extends State<EncryptedFileView> {
  bool _isDownloading = false;

  Future<void> _handleFileDownload() async {
    setState(() => _isDownloading = true);
    try {
      final bytes = await sl<MediaRepository>().downloadAndDecryptMedia(
        mediaUrl: widget.mediaUrl,
        payload: widget.payload,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Decrypted "${widget.payload.fileName}" (${(bytes.length / 1024).toStringAsFixed(1)} KB)',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download file')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileName = widget.payload.fileName.isNotEmpty
        ? widget.payload.fileName
        : 'Attachment File';

    return InkWell(
      onTap: _isDownloading ? null : _handleFileDownload,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isMe
              ? theme.colorScheme.onPrimary.withValues(alpha: 0.15)
              : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.isMe
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.2)
                    : theme.colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insert_drive_file_rounded,
                color: widget.isMe
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: widget.isMe
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Encrypted Document',
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.isMe
                          ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (_isDownloading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.isMe ? theme.colorScheme.onPrimary : null,
                ),
              )
            else
              Icon(
                Icons.download_rounded,
                size: 20,
                color: widget.isMe
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                    : theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
