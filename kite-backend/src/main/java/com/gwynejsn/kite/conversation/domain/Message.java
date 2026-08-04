package com.gwynejsn.kite.conversation.domain;

import com.gwynejsn.kite.conversation.domain.enums.MessageStatus;
import com.gwynejsn.kite.conversation.domain.enums.MessageType;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "messages")
public class Message {

    @Id
    private MessageId id;
    private ConversationId conversationId;
    private UserId senderId;
    private String content;
    private String mediaUrl;
    private MessageType messageType;
    private MessageStatus status;
    private MessageId replyToMessageId;
    private Instant createdAt;
    private Instant updatedAt;
}
