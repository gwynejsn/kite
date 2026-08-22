package com.gwynejsn.kite.conversation.application.exceptions;

public class UserIsNotAnAdminException extends RuntimeException {
    public UserIsNotAnAdminException(String message) {
        super(message);
    }
}
