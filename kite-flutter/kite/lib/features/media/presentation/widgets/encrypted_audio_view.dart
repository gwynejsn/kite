import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:kite/features/media/domain/models/encrypted_media_payload.dart';
import 'package:kite/features/media/domain/repositories/media_repository.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:path_provider/path_provider.dart';

class EncryptedAudioView extends StatefulWidget {
  final String mediaUrl;
  final EncryptedMediaPayload payload;
  final bool isMe;

  const EncryptedAudioView({
    super.key,
    required this.mediaUrl,
    required this.payload,
    required this.isMe,
  });

  @override
  State<EncryptedAudioView> createState() => _EncryptedAudioViewState();
}

class _EncryptedAudioViewState extends State<EncryptedAudioView> {
  late final AudioPlayer _audioPlayer;
  bool _isLoading = false;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  File? _decryptedFile;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() {
          _duration = d;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          _position = p;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudioPlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    if (_decryptedFile != null && await _decryptedFile!.exists()) {
      await _audioPlayer.play(DeviceFileSource(_decryptedFile!.path));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final bytes = await sl<MediaRepository>().downloadAndDecryptMedia(
        mediaUrl: widget.mediaUrl,
        payload: widget.payload,
      );

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/audio_${widget.payload.mediaKey.hashCode}.m4a',
      );
      await tempFile.writeAsBytes(bytes);
      _decryptedFile = tempFile;

      await _audioPlayer.play(DeviceFileSource(tempFile.path));
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to play audio')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: widget.isMe
            ? theme.colorScheme.onPrimary.withValues(alpha: 0.15)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.isMe ? theme.colorScheme.onPrimary : null,
                    ),
                  )
                : Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    size: 36,
                    color: widget.isMe
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                  ),
            onPressed: _isLoading ? null : _toggleAudioPlayback,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.payload.fileName.isNotEmpty
                      ? widget.payload.fileName
                      : 'Voice Note',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: widget.isMe
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _duration.inMilliseconds > 0
                            ? (_position.inMilliseconds / _duration.inMilliseconds)
                                .clamp(0.0, 1.0)
                            : 0.0,
                        backgroundColor: widget.isMe
                            ? theme.colorScheme.onPrimary.withValues(alpha: 0.2)
                            : theme.colorScheme.primary.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.isMe
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _duration > Duration.zero
                          ? _formatTime(_position)
                          : 'Voice',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.isMe
                            ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
