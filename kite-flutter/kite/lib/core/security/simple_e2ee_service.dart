import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kite/core/security/encryption_service.dart';

class SimpleE2eeService implements EncryptionService {
  // X25519 is an Elliptic Curve Diffie-Hellman (ECDH)
  final _keyAlgorithm = X25519();
  final _cipherAlgorithm = AesGcm.with256bits();
  final _secureStorage = const FlutterSecureStorage();

  static const _privateKeyStorageKey = 'user_e2ee_private_key';

  @override
  Future<String> initAndGetPublicKey() async {
    final keyPair = await _keyAlgorithm.newKeyPair();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();

    await _secureStorage.write(
      key: _privateKeyStorageKey,
      value: base64Encode(privateKeyBytes),
    );

    return base64Encode(publicKey.bytes);
  }

  /// generate a secret key using my private key and the public key of the recipient,
  /// then i use aes to encrypt the message, then lock it using the secret key generated earlier
  /// the x25519 makes it so that the receiver can make the secret key by combining his private key
  /// and the sender's public key that will then unlock the aes with the message
  @override
  Future<Map<String, String>> encryptMessage({
    required String plainText,
    required String recipientPublicKeyBase64,
  }) async {
    final myKeyPair = await _loadLocalKeyPair();

    final recipientPublicKey = SimplePublicKey(
      base64Decode(recipientPublicKeyBase64),
      type: KeyPairType.x25519,
    );

    // this combines the private key with the recipient's public key using X25519 to generate a shared secret key
    final sharedSecretKey = await _keyAlgorithm.sharedSecretKey(
      keyPair: myKeyPair,
      remotePublicKey: recipientPublicKey,
    );

    // encrypt payload with AES-GCM making the created sharedSecretKey as the key
    final secretBox = await _cipherAlgorithm.encrypt(
      utf8.encode(plainText),
      secretKey: sharedSecretKey,
    );

    return {
      'cipherText': base64Encode(secretBox.cipherText),
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
    };
  }

  @override
  Future<String> decryptMessage({
    required Map<String, String> payload,
    required String senderPublicKeyBase64,
  }) async {
    final myKeyPair = await _loadLocalKeyPair();

    final senderPublicKey = SimplePublicKey(
      base64Decode(senderPublicKeyBase64),
      type: KeyPairType.x25519,
    );

    final sharedSecretKey = await _keyAlgorithm.sharedSecretKey(
      keyPair: myKeyPair,
      remotePublicKey: senderPublicKey,
    );

    final secretBox = SecretBox(
      base64Decode(payload['cipherText']!),
      nonce: base64Decode(payload['nonce']!),
      mac: Mac(base64Decode(payload['mac']!)),
    );

    final clearBytes = await _cipherAlgorithm.decrypt(
      secretBox,
      secretKey: sharedSecretKey,
    );

    return utf8.decode(clearBytes);
  }

  Future<SimpleKeyPair> _loadLocalKeyPair() async {
    final privateKeyBase64 = await _secureStorage.read(
      key: _privateKeyStorageKey,
    );
    if (privateKeyBase64 == null) {
      throw Exception('No private key found on device.');
    }
    final seed = base64Decode(privateKeyBase64);
    return await _keyAlgorithm.newKeyPairFromSeed(seed);
  }
}
