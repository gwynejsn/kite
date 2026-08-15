package com.gwynejsn.kite.conversation.domain;

import lombok.Getter;
import lombok.Value;

@Value
public class EncryptedPayload {
    String cipherText;
    String nonce;
    String mac;
    String senderPublicKey;
}