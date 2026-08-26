import 'dart:convert';

class EncryptedMediaPayload {
  final String mediaKey;
  final String nonce;
  final String mac;
  final String fileName;
  final String mediaType; // "IMAGE", "VIDEO", "FILE", "AUDIO"
  final String? caption;

  const EncryptedMediaPayload({
    required this.mediaKey,
    required this.nonce,
    required this.mac,
    required this.fileName,
    required this.mediaType,
    this.caption,
  });

  factory EncryptedMediaPayload.fromJson(Map<String, dynamic> json) {
    return EncryptedMediaPayload(
      mediaKey: json['mediaKey'] as String? ?? '',
      nonce: json['nonce'] as String? ?? '',
      mac: json['mac'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      mediaType: json['mediaType'] as String? ?? 'IMAGE',
      caption: json['caption'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaKey': mediaKey,
      'nonce': nonce,
      'mac': mac,
      'fileName': fileName,
      'mediaType': mediaType.toUpperCase(),
      if (caption != null && caption!.isNotEmpty) 'caption': caption,
    };
  }

  String encode() => jsonEncode(toJson());

  static EncryptedMediaPayload? tryDecode(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic> && decoded.containsKey('mediaKey')) {
        return EncryptedMediaPayload.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }
}
