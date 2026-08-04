package com.gwynejsn.kite.conversation.domain;

import com.gwynejsn.kite.conversation.domain.enums.MessageType;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LastMessage {
    private MessageId messageId;
    private UserId senderId;
    private String content;
    private MessageType messageType;
    private Instant timestamp;
}
