package com.gwynejsn.kite.conversation.infrastructure.exceptions;

public class UserIsNotAMemberException extends RuntimeException {
    public UserIsNotAMemberException(String message) {
        super(message);
    }
}
