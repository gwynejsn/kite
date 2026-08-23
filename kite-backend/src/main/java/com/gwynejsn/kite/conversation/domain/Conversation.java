package com.gwynejsn.kite.conversation.domain;

import com.gwynejsn.kite.conversation.domain.enums.ConversationType;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "conversations")
public class Conversation {

    @Id
    private ConversationId id;
    private ConversationType type;
    private String name;
    private String conversationPhoto;

    @Builder.Default
    private Set<UserId> memberIds = new HashSet<>();

    @Builder.Default
    private Set<UserId> adminIds = new HashSet<>();

    @Builder.Default
    private Map<String, String> groupKeyMap = new HashMap<>();

    private LastMessage lastMessage;
    private Instant createdAt;
    private Instant updatedAt;

}
