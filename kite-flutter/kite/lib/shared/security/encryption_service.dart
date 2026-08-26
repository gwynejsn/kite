import 'dart:typed_data';

class MediaEncryptionResult {
  final Uint8List encryptedBytes;
  final String keyBase64;
  final String nonceBase64;
  final String macBase64;

  const MediaEncryptionResult({
    required this.encryptedBytes,
    required this.keyBase64,
    required this.nonceBase64,
    required this.macBase64,
  });
}

abstract class EncryptionService {
  Future<String> initAndGetPublicKey();

  Future<Map<String, dynamic>> encryptEnvelope({
    required String plainText,
    required Map<String, String> memberPublicKeys,
  });

  Future<String> decryptEnvelope({
    required Map<String, String> payload,
    required String senderPublicKeyBase64,
  });

  Future<String> generateGroupKey();

  Future<String> encryptGroupKeyForRecipient({
    required String groupKeyBase64,
    required String recipientPublicKeyBase64,
  });

  Future<String> decryptGroupKey({
    required String encryptedGroupKey,
    String? senderPublicKeyBase64,
  });

  Future<Map<String, dynamic>> encryptWithGroupKey({
    required String plainText,
    required String groupKeyBase64,
  });

  Future<String> decryptWithGroupKey({
    required Map<String, String> payload,
    required String groupKeyBase64,
  });

  Future<MediaEncryptionResult> encryptMediaBytes(Uint8List bytes);

  Future<Uint8List> decryptMediaBytes({
    required Uint8List encryptedBytes,
    required String keyBase64,
    required String nonceBase64,
    required String macBase64,
  });
}

