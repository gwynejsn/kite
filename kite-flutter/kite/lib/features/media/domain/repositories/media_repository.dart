import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kite/features/media/domain/models/encrypted_media_payload.dart';

class MediaPickResult {
  final Uint8List rawBytes;
  final String fileName;
  final String mediaType; // "IMAGE", "VIDEO", "FILE", "AUDIO"

  const MediaPickResult({
    required this.rawBytes,
    required this.fileName,
    required this.mediaType,
  });
}

class UploadedMediaResult {
  final String mediaUrl;
  final EncryptedMediaPayload payload;

  const UploadedMediaResult({
    required this.mediaUrl,
    required this.payload,
  });
}

abstract interface class MediaRepository {
  Future<MediaPickResult?> pickImage(ImageSource source);
  Future<MediaPickResult?> pickVideo(ImageSource source);
  Future<MediaPickResult?> pickFile();
  Future<MediaPickResult?> pickAudio();

  Future<UploadedMediaResult> encryptAndUploadMedia({
    required Uint8List rawBytes,
    required String fileName,
    required String mediaType, // "IMAGE", "VIDEO", "FILE", "AUDIO"
    required String uploaderId,
    required String conversationId,
    String? caption,
  });

  Future<Uint8List> downloadAndDecryptMedia({
    required String mediaUrl,
    required EncryptedMediaPayload payload,
  });

  Future<String> uploadUnencryptedMedia({
    required Uint8List rawBytes,
    required String fileName,
    String? uploaderId,
  });
}
