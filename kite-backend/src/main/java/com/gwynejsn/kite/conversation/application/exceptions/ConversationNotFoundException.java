package com.gwynejsn.kite.conversation.application.exceptions;

public class ConversationNotFoundException extends RuntimeException {
    public ConversationNotFoundException(String message) {
        super(message);
    }
}
