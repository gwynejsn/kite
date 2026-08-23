import 'package:flutter/foundation.dart';
import 'package:kite/shared/security/encryption_service.dart';

class EncryptedPayload {
  final String cipherText;
  final String? nonce;
  final String? mac;
  final String? senderPublicKey;
  final Map<String, String>? encryptedGroupKeys;

  const EncryptedPayload({
    required this.cipherText,
    this.nonce,
    this.mac,
    this.senderPublicKey,
    this.encryptedGroupKeys,
  });

  factory EncryptedPayload.fromJson(Map<String, dynamic> json) {
    Map<String, String>? keysMap;
    if (json['encryptedGroupKeys'] is Map) {
      keysMap = {};
      (json['encryptedGroupKeys'] as Map).forEach((k, v) {
        if (k != null && v != null) {
          keysMap![k.toString()] = v.toString();
        }
      });
    }

    return EncryptedPayload(
      cipherText: json['cipherText'] as String? ?? '',
      nonce: json['nonce'] as String?,
      mac: json['mac'] as String?,
      senderPublicKey: json['senderPublicKey'] as String?,
      encryptedGroupKeys: keysMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cipherText': cipherText,
      if (nonce != null) 'nonce': nonce,
      if (mac != null) 'mac': mac,
      if (senderPublicKey != null) 'senderPublicKey': senderPublicKey,
      if (encryptedGroupKeys != null) 'encryptedGroupKeys': encryptedGroupKeys,
    };
  }

  Future<String> decrypt(
    EncryptionService encryptionService, {
    String? currentUserId,
    String? groupKeyBase64,
  }) async {
    if (cipherText.isEmpty) return '';

    if (nonce != null && mac != null) {
      final payloadMap = <String, String>{
        'cipherText': cipherText,
        'nonce': nonce!,
        'mac': mac!,
      };

      if (groupKeyBase64 != null && groupKeyBase64.isNotEmpty) {
        try {
          final result = await encryptionService.decryptWithGroupKey(
            payload: payloadMap,
            groupKeyBase64: groupKeyBase64,
          );
          if (result.isNotEmpty) return result;
        } catch (e) {
          debugPrint('Group key decryption failed: $e');
        }
      }

      if (senderPublicKey != null &&
          encryptedGroupKeys != null &&
          encryptedGroupKeys!.isNotEmpty) {
        // 1. Try key for currentUserId first
        if (currentUserId != null &&
            encryptedGroupKeys!.containsKey(currentUserId)) {
          payloadMap['encryptedKey'] = encryptedGroupKeys![currentUserId]!;
          try {
            final result = await encryptionService.decryptEnvelope(
              payload: payloadMap,
              senderPublicKeyBase64: senderPublicKey!,
            );
            if (result.isNotEmpty) return result;
          } catch (e) {
            debugPrint('Primary key decryption failed for $currentUserId: $e');
          }
        }

        // 2. Fallback: try all keys in encryptedGroupKeys until one decrypts cleanly
        for (final entry in encryptedGroupKeys!.entries) {
          if (entry.key == currentUserId) continue;
          try {
            payloadMap['encryptedKey'] = entry.value;
            final result = await encryptionService.decryptEnvelope(
              payload: payloadMap,
              senderPublicKeyBase64: senderPublicKey!,
            );
            if (result.isNotEmpty) return result;
          } catch (_) {}
        }
      }
    }

    return '🔒 Encrypted Message';
  }
}
