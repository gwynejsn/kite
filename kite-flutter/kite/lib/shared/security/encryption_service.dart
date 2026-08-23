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
}
