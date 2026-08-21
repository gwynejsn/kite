package com.gwynejsn.kite.conversation.application.dto;


import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record CreateGroupConversationRequest (
        @NotEmpty(message = "Group member IDs must not be empty")
        List<String> membersId,

        @NotBlank(message = "Conversation name must not be blank")
        String conversationName,

        String conversationPhoto,

        List<String> adminsId
){ }
