import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:kite/features/media/domain/models/encrypted_media_payload.dart';
import 'package:kite/features/media/domain/repositories/media_repository.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:video_player/video_player.dart';

class EncryptedVideoView extends StatefulWidget {
  final String mediaUrl;
  final EncryptedMediaPayload payload;
  final double? width;
  final double? height;

  const EncryptedVideoView({
    super.key,
    required this.mediaUrl,
    required this.payload,
    this.width,
    this.height,
  });

  @override
  State<EncryptedVideoView> createState() => _EncryptedVideoViewState();
}

class _EncryptedVideoViewState extends State<EncryptedVideoView> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAndInitializeVideo();
  }

  Future<void> _loadAndInitializeVideo() async {
    try {
      final Uint8List bytes =
          await sl<MediaRepository>().downloadAndDecryptMedia(
        mediaUrl: widget.mediaUrl,
        payload: widget.payload,
      );

      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/video_${widget.payload.mediaKey.hashCode}.mp4',
      );
      await tempFile.writeAsBytes(bytes);

      _controller = VideoPlayerController.file(tempFile);
      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load video';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width ?? 220,
        height: widget.height ?? 160,
        color: Colors.black26,
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_error != null || _controller == null || !_controller!.value.isInitialized) {
      return Container(
        width: widget.width ?? 220,
        height: widget.height ?? 160,
        color: Colors.black26,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_camera_back_outlined,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              _error ?? 'Video error',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: widget.width ?? 240,
        constraints: const BoxConstraints(maxHeight: 280),
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
            IconButton(
              iconSize: 48,
              icon: Icon(
                _controller!.value.isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
