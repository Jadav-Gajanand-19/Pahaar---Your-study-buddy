import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prahar/core/models/app_error.dart';

/// Global Error Handler
class ErrorHandler {
  /// Log error for debugging
  static void logError(dynamic error, StackTrace? stackTrace, {String? context}) {
    developer.log(
      'Error${context != null ? ' in $context' : ''}: $error',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Convert exception to AppError
  static AppError handleError(dynamic error, {StackTrace? stackTrace}) {
    logError(error, stackTrace);

    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    } else if (error is FirebaseException) {
      return _handleFirestoreError(error);
    } else if (error is AppError) {
      return error;
    } else {
      return AppError(
        type: AppErrorType.unknown,
        message: error.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle Firebase Auth errors
  static AppError _handleAuthError(FirebaseAuthException error) {
    String message;
    
    switch (error.code) {
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'Incorrect password.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email.';
        break;
      case 'invalid-email':
        message = 'Invalid email address.';
        break;
      case 'weak-password':
        message = 'Password is too weak. Use at least 6 characters.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your connection.';
        break;
      default:
        message = 'Authentication error: ${error.message ?? error.code}';
    }

    return AppError(
      type: AppErrorType.auth,
      message: message,
      details: error.code,
    );
  }

  /// Handle Firestore errors
  static AppError _handleFirestoreError(FirebaseException error) {
    String message;

    switch (error.code) {
      case 'permission-denied':
        message = 'You don\'t have permission to access this data.';
        break;
      case 'not-found':
        message = 'Requested data not found.';
        break;
      case 'already-exists':
        message = 'This data already exists.';
        break;
      case 'resource-exhausted':
        message = 'Too many requests. Please try again later.';
        break;
      case 'failed-precondition':
        message = 'Operation failed. Please check your data.';
        break;
      case 'aborted':
        message = 'Operation was aborted. Please try again.';
        break;
      case 'unavailable':
        message = 'Service temporarily unavailable. Please try again.';
        break;
      default:
        message = 'Database error: ${error.message ?? error.code}';
    }

    return AppError(
      type: AppErrorType.firestore,
      message: message,
      details: error.code,
    );
  }

  /// Validate input and throw AppError if invalid
  static void validateInput(bool condition, String message) {
    if (!condition) {
      throw AppError(
        type: AppErrorType.validation,
        message: message,
      );
    }
  }

  /// Validate email format
  static void validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    validateInput(
      emailRegex.hasMatch(email),
      'Please enter a valid email address',
    );
  }

  /// Validate password strength
  static void validatePassword(String password) {
    validateInput(
      password.length >= 6,
      'Password must be at least 6 characters long',
    );
  }

  /// Validate required field
  static void validateRequired(String? value, String fieldName) {
    validateInput(
      value != null && value.trim().isNotEmpty,
      '$fieldName is required',
    );
  }
}
