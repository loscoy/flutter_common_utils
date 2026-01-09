import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:talker_flutter/talker_flutter.dart' hide LogLevel;

import '../abstraction/i_app_logger.dart';

/// 自定义文件日志观察者
/// 将日志同时写入文件以便持久化存储
class FileLogObserver extends TalkerObserver {
  final File file;
  IOSink? _sink;
  bool _isInitialized = false;

  FileLogObserver(this.file);

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 确保父目录存在
      await file.parent.create(recursive: true);
      _sink = file.openWrite(mode: FileMode.writeOnlyAppend);
      _isInitialized = true;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to initialize file output: $e');
    }
  }

  void _writeToFile(TalkerData data) {
    if (!_isInitialized || _sink == null) {
      // 如果未初始化，尝试同步写入（作为备用方案）
      try {
        file.writeAsStringSync(
          '${data.generateTextMessage()}\n',
          mode: FileMode.writeOnlyAppend,
        );
      } catch (e) {
        // 静默失败，避免日志循环
      }
      return;
    }

    try {
      _sink!.writeln(data.generateTextMessage());
      _sink!.flush();
    } catch (e) {
      // 如果IOSink出错，重置状态
      _isInitialized = false;
      _sink = null;
    }
  }

  @override
  void onLog(TalkerData log) {
    _writeToFile(log);
  }

  @override
  void onError(TalkerError err) {
    _writeToFile(err);
  }

  @override
  void onException(TalkerException exception) {
    _writeToFile(exception);
  }

  Future<void> dispose() async {
    if (_sink != null) {
      try {
        await _sink!.flush();
        await _sink!.close();
      } catch (e) {
        // 静默处理关闭错误
      }
      _sink = null;
    }
    _isInitialized = false;
  }
}

/// 日志管理器实现 - 基于 Talker
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

    // 文件输出
    if (enableFileOutput) {
      final logFile = await _getLogFile(customLogFileName);
      if (logFile != null) {
        _fileObserver = FileLogObserver(logFile);
        await _fileObserver!.init();
        observers.add(_fileObserver!);
        _logFilePath = logFile.path;
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

  /// 获取日志文件
  Future<File?> _getLogFile(String? customFileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/logs');

      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final fileName = customFileName ??
          'app_${DateTime.now().toString().split(' ')[0]}.log';
      return File('${logsDir.path}/$fileName');
    } catch (e) {
      // ignore: avoid_print
      print('Failed to create log file: $e');
      return null;
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
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/logs');

      if (!await logsDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
      final files = await logsDir.list().toList();

      int deletedCount = 0;
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await file.delete();
            deletedCount++;
          }
        }
      }

      i('🗑️ Cleaned $deletedCount old log files (kept last $keepDays days)');
    } catch (error) {
      e('Failed to clean old logs: $error');
    }
  }

  @override
  Future<int> getLogFileSize() async {
    if (_logFilePath == null) return 0;

    try {
      final file = File(_logFilePath!);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (error) {
      e('Failed to get log file size: $error');
    }

    return 0;
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
