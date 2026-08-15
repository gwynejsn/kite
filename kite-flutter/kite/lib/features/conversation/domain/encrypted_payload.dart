class EncryptedPayload {
  final String cipherText;
  final String? nonce;
  final String? mac;
  final String? senderPublicKey;

  const EncryptedPayload({
    required this.cipherText,
    this.nonce,
    this.mac,
    this.senderPublicKey,
  });

  factory EncryptedPayload.fromJson(Map<String, dynamic> json) {
    return EncryptedPayload(
      cipherText: json['cipherText'] as String? ?? '',
      nonce: json['nonce'] as String?,
      mac: json['mac'] as String?,
      senderPublicKey: json['senderPublicKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cipherText': cipherText,
      if (nonce != null) 'nonce': nonce,
      if (mac != null) 'mac': mac,
      if (senderPublicKey != null) 'senderPublicKey': senderPublicKey,
    };
  }
}
