enum MessageStatus {
  sent,
  delivered,
  read;

  static MessageStatus fromString(String? status) {
    if (status == null) return MessageStatus.sent;
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return MessageStatus.delivered;
      case 'READ':
        return MessageStatus.read;
      case 'SENT':
      default:
        return MessageStatus.sent;
    }
  }
}
