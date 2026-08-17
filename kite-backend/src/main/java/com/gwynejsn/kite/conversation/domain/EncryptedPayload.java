package com.gwynejsn.kite.conversation.domain;

import lombok.Value;

import java.util.Map;

@Value
public class EncryptedPayload {
    String cipherText;
    String nonce;
    String mac;
    String senderPublicKey;
    Map<String, String> encryptedGroupKeys;
}