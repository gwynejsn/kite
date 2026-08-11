abstract class EncryptionService {
  Future<String> initAndGetPublicKey();
  Future<Map<String, String>> encryptMessage({
    required String plainText,
    required String recipientPublicKeyBase64,
  });
  Future<String> decryptMessage({
    required Map<String, String> payload,
    required String senderPublicKeyBase64,
  });
}
