enum MessageType {
  text,
  image,
  video,
  file,
  audio,
  system;

  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => MessageType.text,
    );
  }
}
