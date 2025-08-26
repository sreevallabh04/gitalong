import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

// Add log level enum
enum LogLevel { debug, info, warning, error }

class AppLogger {
  static Logger? _logger;
  static final List<LogEvent> _logHistory = [];
  static const int maxLogHistory = 1000;
  static List<LogEvent> get logHistory => List.unmodifiable(_logHistory);
  static bool _isInitialized = false;

  static LogLevel logLevel = const bool.fromEnvironment('dart.vm.product')
      ? LogLevel.warning
      : LogLevel.debug;

  static void d(String message) {
    if (logLevel.index <= LogLevel.debug.index) {
      print('[DEBUG] $message');
    }
  }

  static void i(String message) {
    if (logLevel.index <= LogLevel.info.index) {
      print('[INFO] $message');
    }
  }

  static void w(String message) {
    if (logLevel.index <= LogLevel.warning.index) {
      print('[WARN] $message');
    }
  }

  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    if (logLevel.index <= LogLevel.error.index) {
      print('[ERROR] $message');
      if (error != null) print('  Error: $error');
      if (stackTrace != null) print('  StackTrace: $stackTrace');
    }
  }

  static void initialize() {
    if (!_isInitialized) {
      _logger = Logger(
        printer: AppLogPrinter(),
        output: AppLogOutput(),
        filter: AppLogFilter(),
        level: kDebugMode ? Level.debug : Level.info,
      );
      _isInitialized = true;
    }
  }

  static Logger get logger {
    if (!_isInitialized || _logger == null) {
      // Auto-initialize with default settings for tests
      initialize();
    }
    return _logger!;
  }

  static void clearHistory() {
    _logHistory.clear();
  }

  static List<LogEvent> getLogsForLevel(Level level) {
    return _logHistory.where((log) => log.level == level).toList();
  }

  static List<LogEvent> getRecentLogs([int count = 50]) {
    return _logHistory.take(count).toList();
  }

  static void _addToHistory(LogEvent event) {
    _logHistory.insert(0, event);
    if (_logHistory.length > maxLogHistory) {
      _logHistory.removeRange(maxLogHistory, _logHistory.length);
    }
  }
}

class AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // In debug mode, log everything
    if (kDebugMode) return true;

    // In release mode, only log warnings and errors
    return event.level.index >= Level.warning.index;
  }
}

class AppLogPrinter extends LogPrinter {
  static final Map<Level, String> _levelEmojis = {
    Level.debug: '🐛',
    Level.info: 'ℹ️ ',
    Level.warning: '⚠️ ',
    Level.error: '❌',
    Level.fatal: '💀',
  };

  static final Map<Level, String> _levelNames = {
    Level.debug: 'DEBUG',
    Level.info: 'INFO ',
    Level.warning: 'WARN ',
    Level.error: 'ERROR',
    Level.fatal: 'FATAL',
  };

  @override
  List<String> log(LogEvent event) {
    final emoji = _levelEmojis[event.level] ?? '';
    final levelName =
        _levelNames[event.level] ?? event.level.name.toUpperCase();
    final timestamp = DateTime.now().toIso8601String();

    final List<String> output = [];

    // Header
    output.add('$emoji [$levelName] $timestamp');

    // Message
    if (event.message.isNotEmpty) {
      output.add('📝 ${event.message}');
    }

    // Error
    if (event.error != null) {
      output.add('🔥 Error: ${event.error}');
    }

    // Stack trace
    if (event.stackTrace != null) {
      output.add('📍 Stack trace:');
      output.addAll(event.stackTrace.toString().split('\n'));
    }

    // Separator
    output.add('-' * 50);

    return output;
  }
}

class AppLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // Store in history
    AppLogger._addToHistory(event.origin);

    // Print to console in debug mode
    if (kDebugMode) {
      for (final line in event.lines) {
        // ignore: avoid_print
        print(line);
      }
    }

    // TODO: Send to remote logging service in production
    // You can integrate with services like:
    // - Firebase Crashlytics
    // - Sentry
    // - LogRocket
    // - Custom analytics service

    if (!kDebugMode && event.origin.level.index >= Level.error.index) {
      _sendToRemoteLogging(event.origin);
    }
  }

  void _sendToRemoteLogging(LogEvent event) {
    // TODO: Implement remote logging
    // This is where you would send critical errors to your logging service

    // Example implementation:
    // try {
    //   final logData = {
    //     'level': event.level.name,
    //     'message': event.message,
    //     'error': event.error?.toString(),
    //     'stackTrace': event.stackTrace?.toString(),
    //     'timestamp': DateTime.now().toIso8601String(),
    //     'platform': Platform.operatingSystem,
    //     'appVersion': AppConfig.appVersion,
    //   };
    //
    //   // Send to your logging service
    //   RemoteLoggingService.send(logData);
    // } catch (e) {
    //   // Fail silently - don't crash the app because of logging
    // }
  }
}

// Extension for easier logging
extension LoggerExtension on Logger {
  void success(String message) {
    i('✅ $message');
  }

  void network(String message) {
    d('🌐 $message');
  }

  void auth(String message) {
    d('🔐 $message');
  }

  void navigation(String message) {
    d('🧭 $message');
  }

  void performance(String message) {
    d('⚡ $message');
  }

  void ui(String message) {
    d('🎨 $message');
  }

  void firestore(String message) {
    d('🗄️ $message');
  }

  void profile(String message) {
    d('👤 $message');
  }

  void validation(String message) {
    w('⚠️ $message');
  }

  void security(String message) {
    w('�� $message');
  }
}

// Static logger instance for easy access (lazy initialization)
Logger get logger => AppLogger.logger;

