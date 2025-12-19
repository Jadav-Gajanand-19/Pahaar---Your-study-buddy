/// App Error Types
enum AppErrorType {
  network,
  auth,
  firestore,
  validation,
  unknown,
}

/// Application Error Model
class AppError {
  final AppErrorType type;
  final String message;
  final String? details;
  final StackTrace? stackTrace;

  AppError({
    required this.type,
    required this.message,
    this.details,
    this.stackTrace,
  });

  /// Get user-friendly error message
  String get userMessage {
    switch (type) {
      case AppErrorType.network:
        return 'Network error. Please check your connection and try again.';
      case AppErrorType.auth:
        return 'Authentication error. Please sign in again.';
      case AppErrorType.firestore:
        return 'Database error. Please try again later.';
      case AppErrorType.validation:
        return message; // Validation messages are already user-friendly
      case AppErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, details: $details)';
  }
}
