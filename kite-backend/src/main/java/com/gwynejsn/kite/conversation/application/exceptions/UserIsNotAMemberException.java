package com.gwynejsn.kite.conversation.application.exceptions;

public class UserIsNotAMemberException extends RuntimeException {
    public UserIsNotAMemberException(String message) {
        super(message);
    }
}
