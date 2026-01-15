// 条件导入：根据平台选择不同的文件日志实现
// Web/Wasm 平台使用 stub，原生平台使用 dart:io 实现
import 'package:talker_flutter/talker_flutter.dart' hide LogLevel;

import '../abstraction/i_app_logger.dart';
import 'file_log_stub.dart' if (dart.library.io) 'file_log_io.dart';

/// 日志管理器实现 - 基于 Talker
/// 支持控制台输出和文件输出（仅原生平台）
class AppLoggerImpl implements IAppLogger {
  late Talker _talker;
  bool _initialized = false;
  String? _logFilePath;
  FileLogObserver? _fileObserver;

  @override
  Future<void> init({
    LogLevel level = LogLevel.debug,
    bool enableConsoleOutput = true,
    bool enableFileOutput = true,
    String? customLogFileName,
  }) async {
    if (_initialized) {
      // 如果已经初始化，直接返回，避免重复初始化
      return;
    }

    final List<TalkerObserver> observers = [];

    // 文件输出（通过条件导入处理平台差异）
    if (enableFileOutput) {
      final logFile = await FileLogHelper.getLogFile(customLogFileName);
      if (logFile != null) {
        _fileObserver = FileLogObserver(logFile);
        await _fileObserver!.init();
        observers.add(_fileObserver!);
        // 获取文件路径（原生平台返回实际路径，Web 返回 null）
        _logFilePath = logFile is String ? logFile : logFile.path;
      }
    }

    // 创建 Talker 实例
    _talker = TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: true,
        useConsoleLogs: enableConsoleOutput,
        maxHistoryItems: 1000,
      ),
      observer: observers.isNotEmpty
          ? (observers.length == 1
              ? observers.first
              : _MultiObserver(observers))
          : null,
    );

    _initialized = true;

    // 记录初始化日志
    i('📱 AppLogger initialized successfully');
    if (_logFilePath != null) {
      i('📁 Log file path: $_logFilePath');
    }
  }

  @override
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_initialized) return;
    if (error is StackTrace && stackTrace == null) {
      stackTrace = error;
      error = null;
    }
    _talker.verbose(message?.toString() ?? '', error, stackTrace);
  }

  @override
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_initialized) return;
    if (error is StackTrace && stackTrace == null) {
      stackTrace = error;
      error = null;
    }
    _talker.debug(message?.toString() ?? '', error, stackTrace);
  }

  @override
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_initialized) return;
    if (error is StackTrace && stackTrace == null) {
      stackTrace = error;
      error = null;
    }
    _talker.info(message?.toString() ?? '', error, stackTrace);
  }

  @override
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_initialized) return;
    if (error is StackTrace && stackTrace == null) {
      stackTrace = error;
      error = null;
    }
    _talker.warning(message?.toString() ?? '', error, stackTrace);
  }

  @override
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_initialized) return;
    if (error is StackTrace && stackTrace == null) {
      stackTrace = error;
      error = null;
    }
    _talker.error(message?.toString() ?? '', error, stackTrace);
  }

  @override
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_initialized) return;
    if (error is StackTrace && stackTrace == null) {
      stackTrace = error;
      error = null;
    }
    _talker.critical(message?.toString() ?? '', error, stackTrace);
  }

  @override
  void setLevel(LogLevel level) {
    i('📅 Log level change requested to: ${level.name}');
  }

  /// 用户行为日志
  @override
  void userAction({
    required String action,
    String? screen,
    Map<String, dynamic>? parameters,
    String? userId,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('👤 USER ACTION');
    buffer.writeln('Action: $action');

    if (screen != null) {
      buffer.writeln('Screen: $screen');
    }

    if (userId != null) {
      buffer.writeln('User ID: $userId');
    }

    if (parameters != null) {
      buffer.writeln('Parameters: $parameters');
    }

    i(buffer.toString());
  }

  /// 性能日志
  @override
  void performance({
    required String operation,
    required Duration duration,
    Map<String, dynamic>? metadata,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('⚡ PERFORMANCE');
    buffer.writeln('Operation: $operation');
    buffer.writeln('Duration: ${duration.inMilliseconds}ms');

    if (metadata != null) {
      buffer.writeln('Metadata: $metadata');
    }

    if (duration.inMilliseconds > 1000) {
      w(buffer.toString());
    } else {
      d(buffer.toString());
    }
  }

  @override
  String? get logFilePath => _logFilePath;

  @override
  Talker get talkerInstance => _talker;

  @override
  Future<void> cleanOldLogs({int keepDays = 7}) async {
    await FileLogHelper.cleanOldLogs(keepDays: keepDays);
    i('🗑️ Cleaned old log files (kept last $keepDays days)');
  }

  @override
  Future<int> getLogFileSize() async {
    return await FileLogHelper.getLogFileSize(_logFilePath);
  }

  @override
  Future<void> close() async {
    if (_initialized) {
      i('📱 AppLogger closing...');

      // 清理文件观察者
      if (_fileObserver != null) {
        await _fileObserver!.dispose();
        _fileObserver = null;
      }

      _initialized = false;
      _logFilePath = null;
    }
  }
}

/// 多观察者包装器
class _MultiObserver extends TalkerObserver {
  final List<TalkerObserver> _observers;

  _MultiObserver(this._observers);

  @override
  void onLog(TalkerData log) {
    for (final observer in _observers) {
      observer.onLog(log);
    }
  }

  @override
  void onError(TalkerError err) {
    for (final observer in _observers) {
      observer.onError(err);
    }
  }

  @override
  void onException(TalkerException exception) {
    for (final observer in _observers) {
      observer.onException(exception);
    }
  }
}
