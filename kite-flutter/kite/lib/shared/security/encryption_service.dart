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
}
