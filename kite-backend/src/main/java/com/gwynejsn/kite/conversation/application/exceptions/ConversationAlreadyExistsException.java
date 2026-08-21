package com.gwynejsn.kite.conversation.application.exceptions;

public class ConversationAlreadyExistsException extends RuntimeException {
  public ConversationAlreadyExistsException(String message) {
    super(message);
  }
}
