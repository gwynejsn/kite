import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class MessageInputFooter extends StatefulWidget {
  final TextEditingController textController;
  final VoidCallback onSend;
  final Function(ImageSource source)? onPickImage;
  final Function(ImageSource source)? onPickVideo;
  final VoidCallback? onPickFile;
  final VoidCallback? onPickAudio;
  final Function(Uint8List audioBytes, String fileName)? onSendVoiceNote;

  const MessageInputFooter({
    super.key,
    required this.textController,
    required this.onSend,
    this.onPickImage,
    this.onPickVideo,
    this.onPickFile,
    this.onPickAudio,
    this.onSendVoiceNote,
  });

  @override
  State<MessageInputFooter> createState() => _MessageInputFooterState();
}

class _MessageInputFooterState extends State<MessageInputFooter> {
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  int _recordDurationSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path =
            '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordDurationSeconds = 0;
        });

        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _recordDurationSeconds++;
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopAndSendRecording() async {
    _timer?.cancel();
    try {
      final path = await _audioRecorder.stop();
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordDurationSeconds = 0;
        });
      }

      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          widget.onSendVoiceNote?.call(
            bytes,
            'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a',
          );
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    try {
      final path = await _audioRecorder.stop();
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordDurationSeconds = 0;
        });
      }
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

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
                    widget.onPickImage?.call(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: Colors.green),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onPickImage?.call(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_library_rounded, color: Colors.purple),
                  title: const Text('Video Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onPickVideo?.call(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.insert_drive_file_rounded, color: Colors.amber),
                  title: const Text('Document / File'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onPickFile?.call();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.audiotrack_rounded, color: Colors.orange),
                  title: const Text('Audio File'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onPickAudio?.call();
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
      child: _isRecording
          ? Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: _cancelRecording,
                ),
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_recordDurationSeconds),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                const Spacer(),
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
                  onPressed: _stopAndSendRecording,
                ),
              ],
            )
          : Row(
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
                  onPressed: () => widget.onPickImage?.call(ImageSource.camera),
                ),
                IconButton(
                  icon: Icon(
                    Icons.mic_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: _startRecording,
                ),
                Expanded(
                  child: TextField(
                    controller: widget.textController,
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
                    onSubmitted: (_) => widget.onSend(),
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
                  onPressed: widget.onSend,
                ),
              ],
            ),
    );
  }
}
