import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kite/shared/security/encryption_service.dart';

class SimpleE2eeService implements EncryptionService {
  final _keyAlgorithm = X25519();
  final _cipherAlgorithm = AesGcm.with256bits();
  final _secureStorage = const FlutterSecureStorage();

  static const _privateKeyStorageKey = 'user_e2ee_private_key';

  @override
  Future<String> initAndGetPublicKey() async {
    final existingPrivateKey = await _getPrivateKey();
    if (existingPrivateKey != null && existingPrivateKey.isNotEmpty) {
      final seed = base64Decode(existingPrivateKey);
      final keyPair = await _keyAlgorithm.newKeyPairFromSeed(seed);
      final publicKey = await keyPair.extractPublicKey();
      return base64Encode(publicKey.bytes);
    }

    final keyPair = await _keyAlgorithm.newKeyPair();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();

    // we only store the private key because the public key can easily be
    // derived from the private key which is why we call it a key pair
    await _secureStorage.write(
      key: _privateKeyStorageKey,
      value: base64Encode(privateKeyBytes),
    );

    return base64Encode(publicKey.bytes);
  }

  @override
  Future<Map<String, dynamic>> encryptEnvelope({
    required String plainText,
    required Map<String, String> memberPublicKeys,
  }) async {
    // generate a one-time random symmetric key for this specific message payload
    final messageKey = await _cipherAlgorithm.newSecretKey();
    final messageKeyBytes = await messageKey.extractBytes();

    // symmetric Layer: encrypt the message payload using the symmetric key (Symmetric Authenticated Encryption)
    // this outputs the 'secretBox' containing ciphertext, nonce, and MAC tag
    final secretBox = await _cipherAlgorithm.encrypt(
      utf8.encode(plainText),
      secretKey: messageKey,
    );

    // load the local asymmetric X25519 key pair initialized during account setup
    final myKeyPair = await _loadLocalKeyPair();

    // retrieve our base64-encoded public key to attach to the outbound payload metadata
    final senderPublicKey = await initAndGetPublicKey();

    final Map<String, String> encryptedGroupKeys = {};

    // asymmetric Layer: Encrypt the symmetric message key individually for each recipient
    for (final entry in memberPublicKeys.entries) {
      final userId = entry.key;
      final pubKeyBase64 = entry.value;

      if (pubKeyBase64.isEmpty) continue;

      // parse the recipient's public key as an X25519 public key coordinate
      final recipientPublicKey = SimplePublicKey(
        base64Decode(pubKeyBase64),
        type: KeyPairType.x25519,
      );

      // perform X25519 Elliptic-Curve Diffie-Hellman (ECDH) key agreement
      // to derive a unique, shared symmetric secret between the sender and this recipient
      final sharedSecretKey = await _keyAlgorithm.sharedSecretKey(
        keyPair: myKeyPair,
        remotePublicKey: recipientPublicKey,
      );

      // encrypt the raw symmetric 'messageKeyBytes' using the derived shared secret.
      // this outputs a 'keyBox' unique to this specific recipient
      final keyBox = await _cipherAlgorithm.encrypt(
        messageKeyBytes,
        secretKey: sharedSecretKey,
      );

      // serialize the recipient's keyBox into a unified string segment
      final keyCombined =
          '${base64Encode(keyBox.cipherText)}:${base64Encode(keyBox.nonce)}:${base64Encode(keyBox.mac.bytes)}';
      encryptedGroupKeys[userId] = keyCombined;
    }

    // return the composite envelope payload containing the encrypted message and all wrapped keys
    return {
      'cipherText': base64Encode(secretBox.cipherText),
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
      'senderPublicKey': senderPublicKey,
      'encryptedGroupKeys': encryptedGroupKeys,
    };
  }

  @override
  Future<String> decryptEnvelope({
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

    final encryptedKeyForUser = payload['encryptedKey'];
    if (encryptedKeyForUser == null || encryptedKeyForUser.isEmpty) {
      throw Exception('Encrypted key missing in envelope payload');
    }

    final keyParts = encryptedKeyForUser.split(':');
    if (keyParts.length < 3) {
      throw Exception('Invalid envelope key format');
    }

    final keyBox = SecretBox(
      base64Decode(keyParts[0]),
      nonce: base64Decode(keyParts[1]),
      mac: Mac(base64Decode(keyParts[2])),
    );

    final messageKeyBytes = await _cipherAlgorithm.decrypt(
      keyBox,
      secretKey: sharedSecretKey,
    );

    final messageSecretBox = SecretBox(
      base64Decode(payload['cipherText']!),
      nonce: base64Decode(payload['nonce']!),
      mac: Mac(base64Decode(payload['mac']!)),
    );

    final clearBytes = await _cipherAlgorithm.decrypt(
      messageSecretBox,
      secretKey: SecretKey(messageKeyBytes),
    );

    return utf8.decode(clearBytes);
  }

  // generate secretKey using aes gcm
  @override
  Future<String> generateGroupKey() async {
    final secretKey = await _cipherAlgorithm.newSecretKey();
    final bytes = await secretKey.extractBytes();
    return base64Encode(bytes);
  }

  // encrypt the secretKey generated using x25519
  @override
  Future<String> encryptGroupKeyForRecipient({
    required String groupKeyBase64,
    required String recipientPublicKeyBase64,
  }) async {
    final myKeyPair = await _loadLocalKeyPair();
    final recipientPublicKey = SimplePublicKey(
      base64Decode(recipientPublicKeyBase64),
      type: KeyPairType.x25519,
    );

    final sharedSecretKey = await _keyAlgorithm.sharedSecretKey(
      keyPair: myKeyPair,
      remotePublicKey: recipientPublicKey,
    );

    final groupKeyBytes = base64Decode(groupKeyBase64);
    final keyBox = await _cipherAlgorithm.encrypt(
      groupKeyBytes,
      secretKey: sharedSecretKey,
    );

    final myPublicKeyBase64 = await initAndGetPublicKey();

    return '$myPublicKeyBase64:${base64Encode(keyBox.cipherText)}:${base64Encode(keyBox.nonce)}:${base64Encode(keyBox.mac.bytes)}';
  }

  // using the stored private key, unlock the encrypted group secret key
  @override
  Future<String> decryptGroupKey({
    required String encryptedGroupKey,
    String? senderPublicKeyBase64,
  }) async {
    final keyParts = encryptedGroupKey.split(':');
    String senderPubKey;
    int offset = 0;

    if (keyParts.length >= 4) {
      senderPubKey = keyParts[0];
      offset = 1;
    } else if (senderPublicKeyBase64 != null &&
        senderPublicKeyBase64.isNotEmpty) {
      senderPubKey = senderPublicKeyBase64;
    } else {
      throw Exception('Sender public key missing for decrypting group key');
    }

    final myKeyPair = await _loadLocalKeyPair();
    final senderPublicKey = SimplePublicKey(
      base64Decode(senderPubKey),
      type: KeyPairType.x25519,
    );

    final sharedSecretKey = await _keyAlgorithm.sharedSecretKey(
      keyPair: myKeyPair,
      remotePublicKey: senderPublicKey,
    );

    final keyBox = SecretBox(
      base64Decode(keyParts[offset]),
      nonce: base64Decode(keyParts[offset + 1]),
      mac: Mac(base64Decode(keyParts[offset + 2])),
    );

    final groupKeyBytes = await _cipherAlgorithm.decrypt(
      keyBox,
      secretKey: sharedSecretKey,
    );

    return base64Encode(groupKeyBytes);
  }

  // use aes to encrypt the message with the secret key being the group secret key
  @override
  Future<Map<String, dynamic>> encryptWithGroupKey({
    required String plainText,
    required String groupKeyBase64,
  }) async {
    final groupSecretKey = SecretKey(base64Decode(groupKeyBase64));
    final secretBox = await _cipherAlgorithm.encrypt(
      utf8.encode(plainText),
      secretKey: groupSecretKey,
    );

    final senderPublicKey = await initAndGetPublicKey();

    return {
      'cipherText': base64Encode(secretBox.cipherText),
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
      'senderPublicKey': senderPublicKey,
    };
  }

  @override
  Future<String> decryptWithGroupKey({
    required Map<String, String> payload,
    required String groupKeyBase64,
  }) async {
    final groupSecretKey = SecretKey(base64Decode(groupKeyBase64));
    final secretBox = SecretBox(
      base64Decode(payload['cipherText']!),
      nonce: base64Decode(payload['nonce']!),
      mac: Mac(base64Decode(payload['mac']!)),
    );

    final clearBytes = await _cipherAlgorithm.decrypt(
      secretBox,
      secretKey: groupSecretKey,
    );

    return utf8.decode(clearBytes);
  }

  @override
  Future<MediaEncryptionResult> encryptMediaBytes(Uint8List bytes) async {
    final secretKey = await _cipherAlgorithm.newSecretKey();
    final secretKeyBytes = await secretKey.extractBytes();
    final secretBox = await _cipherAlgorithm.encrypt(
      bytes,
      secretKey: secretKey,
    );

    return MediaEncryptionResult(
      encryptedBytes: Uint8List.fromList(secretBox.cipherText),
      keyBase64: base64Encode(secretKeyBytes),
      nonceBase64: base64Encode(secretBox.nonce),
      macBase64: base64Encode(secretBox.mac.bytes),
    );
  }

  @override
  Future<Uint8List> decryptMediaBytes({
    required Uint8List encryptedBytes,
    required String keyBase64,
    required String nonceBase64,
    required String macBase64,
  }) async {
    final secretKey = SecretKey(base64Decode(keyBase64));
    final secretBox = SecretBox(
      encryptedBytes,
      nonce: base64Decode(nonceBase64),
      mac: Mac(base64Decode(macBase64)),
    );

    final clearBytes = await _cipherAlgorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return Uint8List.fromList(clearBytes);
  }


  Future<SimpleKeyPair> _loadLocalKeyPair() async {
    String? privateKeyBase64 = await _getPrivateKey();
    if (privateKeyBase64 == null || privateKeyBase64.isEmpty) {
      await initAndGetPublicKey();
      privateKeyBase64 = await _getPrivateKey();
    }
    final seed = base64Decode(privateKeyBase64!);
    return await _keyAlgorithm.newKeyPairFromSeed(seed);
  }

  Future<String?> _getPrivateKey() async {
    try {
      return await _secureStorage.read(key: _privateKeyStorageKey);
    } catch (e) {
      debugPrint('Error reading private key: $e');
      return null;
    }
  }
}
