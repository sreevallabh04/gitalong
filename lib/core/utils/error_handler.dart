import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import '../constants/app_constants.dart';
import 'logger.dart';

class ErrorHandler {
  static final List<AppError> _errorHistory = [];
  static const int maxErrorHistory = 100;

  static List<AppError> get errorHistory => List.unmodifiable(_errorHistory);

  /// Handle Flutter framework errors
  static void handleFlutterError(FlutterErrorDetails details) {
    final error = AppError.fromFlutterError(details);
    _recordError(error);

    if (kDebugMode) {
      // In debug mode, show the error overlay
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In release mode, log silently
      AppLogger.logger.e(
        'Flutter Error: ${error.message}',
        error: error.exception,
        stackTrace: error.stackTrace,
      );
    }
  }

  /// Handle platform errors (Dart isolate errors)
  static bool handlePlatformError(Object error, StackTrace stackTrace) {
    final appError = AppError.fromPlatformError(error, stackTrace);
    _recordError(appError);

    if (kDebugMode) {
      AppLogger.logger.e('❌ Platform Error: ${appError.message}');
    }

    // Return true to prevent the error from propagating
    return true;
  }

  /// Handle network errors
  static AppError handleNetworkError(dynamic error) {
    final appError = AppError.networkError(error);
    _recordError(appError);

    AppLogger.logger.network('Network Error: ${appError.message}');
    return appError;
  }

  /// Handle authentication errors
  static AppError handleAuthError(dynamic error) {
    final appError = AppError.authError(error);
    _recordError(appError);

    AppLogger.logger.auth('Auth Error: ${appError.message}');
    return appError;
  }

  /// Handle validation errors
  static AppError handleValidationError(String message, {String? field}) {
    final appError = AppError.validationError(message, field: field);
    _recordError(appError);

    AppLogger.logger.w('Validation Error: ${appError.message}');
    return appError;
  }

  /// Handle general application errors
  static AppError handleAppError(dynamic error, {StackTrace? stackTrace}) {
    final appError = AppError.general(error, stackTrace: stackTrace);
    _recordError(appError);

    AppLogger.logger.e(
      'App Error: ${appError.message}',
      error: error,
      stackTrace: stackTrace,
    );
    return appError;
  }

  /// Handle Firestore/Database errors
  static AppError handleFirestoreError(dynamic error) {
    final appError = AppError.firestoreError(error);
    _recordError(appError);

    AppLogger.logger.e('Firestore Error: ${appError.message}');
    return appError;
  }

  /// Handle profile setup errors specifically
  static AppError handleProfileSetupError(dynamic error) {
    final appError = AppError.profileSetupError(error);
    _recordError(appError);

    AppLogger.logger.e('Profile Setup Error: ${appError.message}');
    return appError;
  }

  /// Show error dialog to user
  static void showErrorDialog(BuildContext context, AppError error) {
    if (error.shouldShowToUser) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(error: error),
      );
    }
  }

  /// Show error snackbar to user
  static void showErrorSnackbar(BuildContext context, AppError error) {
    if (error.shouldShowToUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.userMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: error.retryAction ?? () {},
          ),
        ),
      );
    }
  }

  /// Record error in history
  static void _recordError(AppError error) {
    _errorHistory.insert(0, error);
    if (_errorHistory.length > maxErrorHistory) {
      _errorHistory.removeRange(maxErrorHistory, _errorHistory.length);
    }

    // Send to crash reporting service in production
    if (!kDebugMode && error.severity.index >= ErrorSeverity.high.index) {
      _sendToCrashReporting(error);
    }
  }

  /// Send error to crash reporting service
  static void _sendToCrashReporting(AppError error) {
    // TODO: Implement crash reporting
    // You can integrate with services like:
    // - Firebase Crashlytics
    // - Sentry
    // - Bugsnag
    // - Custom crash reporting service

    // Example implementation:
    // try {
    //   CrashlyticsService.recordError(
    //     error.exception ?? error.message,
    //     error.stackTrace,
    //     information: [
    //       'Error Type': error.type.name,
    //       'Severity': error.severity.name,
    //       'Timestamp': error.timestamp.toIso8601String(),
    //       'User Message': error.userMessage,
    //       'Technical Message': error.message,
    //     ],
    //   );
    // } catch (e) {
    //   // Fail silently
    // }
  }

  /// Clear error history
  static void clearErrorHistory() {
    _errorHistory.clear();
  }

  /// Get errors by type
  static List<AppError> getErrorsByType(ErrorType type) {
    return _errorHistory.where((error) => error.type == type).toList();
  }

  /// Get errors by severity
  static List<AppError> getErrorsBySeverity(ErrorSeverity severity) {
    return _errorHistory.where((error) => error.severity == severity).toList();
  }
}

enum ErrorType {
  network,
  authentication,
  validation,
  permission,
  storage,
  ui,
  platform,
  general,
}

enum ErrorSeverity { low, medium, high, critical }

class AppError {
  final String message;
  final String userMessage;
  final ErrorType type;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final Object? exception;
  final StackTrace? stackTrace;
  final String? context;
  final Map<String, dynamic>? metadata;
  final VoidCallback? retryAction;

  const AppError({
    required this.message,
    required this.userMessage,
    required this.type,
    required this.severity,
    required this.timestamp,
    this.exception,
    this.stackTrace,
    this.context,
    this.metadata,
    this.retryAction,
  });

  bool get shouldShowToUser => severity.index >= ErrorSeverity.medium.index;

  factory AppError.fromFlutterError(FlutterErrorDetails details) {
    return AppError(
      message: details.toString(),
      userMessage: AppConstants.genericErrorMessage,
      type: ErrorType.ui,
      severity: ErrorSeverity.high,
      timestamp: DateTime.now(),
      exception: details.exception,
      stackTrace: details.stack,
      context: details.context?.toString(),
    );
  }

  factory AppError.fromPlatformError(Object error, StackTrace stackTrace) {
    return AppError(
      message: error.toString(),
      userMessage: AppConstants.genericErrorMessage,
      type: ErrorType.platform,
      severity: ErrorSeverity.critical,
      timestamp: DateTime.now(),
      exception: error,
      stackTrace: stackTrace,
    );
  }

  factory AppError.networkError(dynamic error) {
    String message = AppConstants.networkErrorMessage;
    ErrorSeverity severity = ErrorSeverity.medium;

    if (error is SocketException) {
      message = 'No internet connection';
    } else if (error is TimeoutException) {
      message = 'Request timed out';
    } else if (error is FormatException) {
      message = 'Invalid response format';
      severity = ErrorSeverity.low;
    }

    return AppError(
      message: error.toString(),
      userMessage: message,
      type: ErrorType.network,
      severity: severity,
      timestamp: DateTime.now(),
      exception: error,
    );
  }

  factory AppError.authError(dynamic error) {
    String userMessage = AppConstants.authErrorMessage;

    if (error.toString().contains('network')) {
      userMessage = AppConstants.networkErrorMessage;
    } else if (error.toString().contains('invalid_credentials')) {
      userMessage = 'Invalid email or password';
    } else if (error.toString().contains('user_not_found')) {
      userMessage = 'Account not found';
    } else if (error.toString().contains('email_not_confirmed')) {
      userMessage = 'Please verify your email address';
    }

    return AppError(
      message: error.toString(),
      userMessage: userMessage,
      type: ErrorType.authentication,
      severity: ErrorSeverity.medium,
      timestamp: DateTime.now(),
      exception: error,
    );
  }

  factory AppError.validationError(String message, {String? field}) {
    return AppError(
      message: message,
      userMessage: message,
      type: ErrorType.validation,
      severity: ErrorSeverity.low,
      timestamp: DateTime.now(),
      metadata: field != null ? {'field': field} : null,
    );
  }

  factory AppError.permissionError(String permission) {
    return AppError(
      message: 'Permission denied: $permission',
      userMessage: AppConstants.permissionErrorMessage,
      type: ErrorType.permission,
      severity: ErrorSeverity.medium,
      timestamp: DateTime.now(),
      metadata: {'permission': permission},
    );
  }

  factory AppError.storageError(dynamic error) {
    return AppError(
      message: error.toString(),
      userMessage: 'Storage operation failed',
      type: ErrorType.storage,
      severity: ErrorSeverity.medium,
      timestamp: DateTime.now(),
      exception: error,
    );
  }

  factory AppError.general(dynamic error, {StackTrace? stackTrace}) {
    return AppError(
      message: error.toString(),
      userMessage: AppConstants.genericErrorMessage,
      type: ErrorType.general,
      severity: ErrorSeverity.medium,
      timestamp: DateTime.now(),
      exception: error,
      stackTrace: stackTrace,
    );
  }

  factory AppError.firestoreError(dynamic error) {
    String userMessage = 'Database operation failed. Please try again.';
    ErrorSeverity severity = ErrorSeverity.medium;

    final errorString = error.toString().toLowerCase();
    if (errorString.contains('permission')) {
      userMessage = 'Permission denied. Please check your internet connection.';
      severity = ErrorSeverity.high;
    } else if (errorString.contains('unavailable')) {
      userMessage = 'Service temporarily unavailable. Please try again later.';
      severity = ErrorSeverity.medium;
    } else if (errorString.contains('timeout') ||
        errorString.contains('deadline')) {
      userMessage =
          'Request timed out. Please check your connection and try again.';
      severity = ErrorSeverity.medium;
    } else if (errorString.contains('network')) {
      userMessage = 'Network error. Please check your internet connection.';
      severity = ErrorSeverity.medium;
    }

    return AppError(
      message: error.toString(),
      userMessage: userMessage,
      type: ErrorType.storage,
      severity: severity,
      timestamp: DateTime.now(),
      exception: error,
    );
  }

  factory AppError.profileSetupError(dynamic error) {
    String userMessage = 'Failed to complete profile setup. Please try again.';

    final errorString = error.toString().toLowerCase();
    if (errorString.contains('name')) {
      userMessage = 'Invalid name. Please enter a valid name.';
    } else if (errorString.contains('email')) {
      userMessage = 'Invalid email. Please check your email address.';
    } else if (errorString.contains('role')) {
      userMessage = 'Invalid role selected. Please choose a valid role.';
    } else if (errorString.contains('github')) {
      userMessage =
          'Invalid GitHub URL. Please enter a valid GitHub profile URL.';
    } else if (errorString.contains('skills')) {
      userMessage = 'Too many skills selected. Please select up to 10 skills.';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      userMessage =
          'Network error. Please check your internet connection and try again.';
    } else if (errorString.contains('permission')) {
      userMessage =
          'Permission denied. Please check your internet connection and try again.';
    } else if (errorString.contains('auth')) {
      userMessage = 'Authentication error. Please sign in again.';
    }

    return AppError(
      message: error.toString(),
      userMessage: userMessage,
      type: ErrorType.validation,
      severity: ErrorSeverity.medium,
      timestamp: DateTime.now(),
      exception: error,
    );
  }

  AppError copyWith({
    String? message,
    String? userMessage,
    ErrorType? type,
    ErrorSeverity? severity,
    DateTime? timestamp,
    Object? exception,
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? metadata,
    VoidCallback? retryAction,
  }) {
    return AppError(
      message: message ?? this.message,
      userMessage: userMessage ?? this.userMessage,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      exception: exception ?? this.exception,
      stackTrace: stackTrace ?? this.stackTrace,
      context: context ?? this.context,
      metadata: metadata ?? this.metadata,
      retryAction: retryAction ?? this.retryAction,
    );
  }

  @override
  String toString() {
    return 'AppError(type: $type, severity: $severity, message: $message)';
  }
}

class ErrorDialog extends StatelessWidget {
  final AppError error;

  const ErrorDialog({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getIconForError(error.type),
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(_getTitleForError(error.type)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error.userMessage),
          if (kDebugMode && error.message != error.userMessage) ...[
            const SizedBox(height: 8),
            Text(
              'Debug: ${error.message}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      actions: [
        if (error.retryAction != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              error.retryAction?.call();
            },
            child: const Text('Retry'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  IconData _getIconForError(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.permission:
        return Icons.security;
      case ErrorType.storage:
        return Icons.storage;
      case ErrorType.ui:
        return Icons.bug_report;
      case ErrorType.platform:
        return Icons.error;
      case ErrorType.general:
        return Icons.error_outline;
    }
  }

  String _getTitleForError(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Connection Error';
      case ErrorType.authentication:
        return 'Authentication Error';
      case ErrorType.validation:
        return 'Validation Error';
      case ErrorType.permission:
        return 'Permission Required';
      case ErrorType.storage:
        return 'Storage Error';
      case ErrorType.ui:
        return 'Interface Error';
      case ErrorType.platform:
        return 'System Error';
      case ErrorType.general:
        return 'Error';
    }
  }
}
