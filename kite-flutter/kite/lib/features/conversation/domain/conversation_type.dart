enum ConversationType {
  direct,
  group,
  channel;

  static ConversationType fromString(String value) {
    return ConversationType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ConversationType.direct,
    );
  }
}
