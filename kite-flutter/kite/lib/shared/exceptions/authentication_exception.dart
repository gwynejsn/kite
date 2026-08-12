class AuthenticationException implements Exception {
  final String message;
  final int errorCode;

  AuthenticationException(this.message, this.errorCode);

  @override
  String toString() =>
      "Authentication Exception: $message with error code $errorCode.";
}
