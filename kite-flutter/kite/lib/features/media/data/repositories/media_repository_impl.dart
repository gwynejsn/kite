import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kite/features/media/data/datasources/media_remote_datasource.dart';
import 'package:kite/features/media/domain/models/encrypted_media_payload.dart';
import 'package:kite/features/media/domain/repositories/media_repository.dart';
import 'package:kite/shared/security/encryption_service.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDatasource mediaRemoteDatasource;
  final EncryptionService encryptionService;
  final ImagePicker _picker;

  final Map<String, Uint8List> _decryptedCache = {};

  MediaRepositoryImpl({
    required this.mediaRemoteDatasource,
    required this.encryptionService,
    ImagePicker? picker,
  }) : _picker = picker ?? ImagePicker();

  @override
  Future<MediaPickResult?> pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      return MediaPickResult(
        rawBytes: bytes,
        fileName: file.name,
        mediaType: 'IMAGE',
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  @override
  Future<MediaPickResult?> pickVideo(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickVideo(source: source);
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      return MediaPickResult(
        rawBytes: bytes,
        fileName: file.name,
        mediaType: 'VIDEO',
      );
    } catch (e) {
      debugPrint('Error picking video: $e');
      return null;
    }
  }

  @override
  Future<MediaPickResult?> pickFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.any,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      return MediaPickResult(
        rawBytes: bytes,
        fileName: file.name,
        mediaType: 'FILE',
      );
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  @override
  Future<MediaPickResult?> pickAudio() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.audio,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      return MediaPickResult(
        rawBytes: bytes,
        fileName: file.name,
        mediaType: 'AUDIO',
      );
    } catch (e) {
      debugPrint('Error picking audio: $e');
      return null;
    }
  }

  @override
  Future<UploadedMediaResult> encryptAndUploadMedia({
    required Uint8List rawBytes,
    required String fileName,
    required String mediaType, // "IMAGE", "VIDEO", "FILE", "AUDIO"
    required String uploaderId,
    required String conversationId,
    String? caption,
  }) async {
    final mediaEncResult = await encryptionService.encryptMediaBytes(rawBytes);

    final mediaUrl = await mediaRemoteDatasource.uploadEncryptedMedia(
      encryptedBytes: mediaEncResult.encryptedBytes,
      fileName: fileName,
      mediaType: mediaType,
      uploaderId: uploaderId,
      conversationId: conversationId,
    );

    final payload = EncryptedMediaPayload(
      mediaKey: mediaEncResult.keyBase64,
      nonce: mediaEncResult.nonceBase64,
      mac: mediaEncResult.macBase64,
      fileName: fileName,
      mediaType: mediaType,
      caption: caption,
    );

    _decryptedCache[mediaUrl] = rawBytes;

    return UploadedMediaResult(
      mediaUrl: mediaUrl,
      payload: payload,
    );
  }

  @override
  Future<Uint8List> downloadAndDecryptMedia({
    required String mediaUrl,
    required EncryptedMediaPayload payload,
  }) async {
    if (_decryptedCache.containsKey(mediaUrl)) {
      return _decryptedCache[mediaUrl]!;
    }

    final encryptedBytes =
        await mediaRemoteDatasource.downloadEncryptedMedia(mediaUrl);

    final decryptedBytes = await encryptionService.decryptMediaBytes(
      encryptedBytes: encryptedBytes,
      keyBase64: payload.mediaKey,
      nonceBase64: payload.nonce,
      macBase64: payload.mac,
    );

    _decryptedCache[mediaUrl] = decryptedBytes;
    return decryptedBytes;
  }
}
