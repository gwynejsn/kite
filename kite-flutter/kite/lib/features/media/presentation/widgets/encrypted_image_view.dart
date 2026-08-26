import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:kite/features/media/domain/models/encrypted_media_payload.dart';
import 'package:kite/features/media/domain/repositories/media_repository.dart';
import 'package:kite/shared/di/injection_container.dart';

class EncryptedImageView extends StatefulWidget {
  final String mediaUrl;
  final EncryptedMediaPayload payload;
  final BoxFit fit;
  final double? width;
  final double? height;

  const EncryptedImageView({
    super.key,
    required this.mediaUrl,
    required this.payload,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<EncryptedImageView> createState() => _EncryptedImageViewState();
}

class _EncryptedImageViewState extends State<EncryptedImageView> {
  late final Future<Uint8List> _decryptedBytesFuture;

  @override
  void initState() {
    super.initState();
    _decryptedBytesFuture = sl<MediaRepository>().downloadAndDecryptMedia(
      mediaUrl: widget.mediaUrl,
      payload: widget.payload,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _decryptedBytesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: widget.width ?? 200,
            height: widget.height ?? 200,
            color: Colors.black12,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            width: widget.width ?? 200,
            height: widget.height ?? 150,
            color: Colors.black12,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  'Failed to load image',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    backgroundColor: Colors.black,
                    iconTheme: const IconThemeData(color: Colors.white),
                  ),
                  body: Center(
                    child: InteractiveViewer(
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              snapshot.data!,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
            ),
          ),
        );
      },
    );
  }
}
