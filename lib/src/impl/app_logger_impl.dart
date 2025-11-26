import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import '../abstraction/i_app_logger.dart';

/// 自定义日志输出类
class FileOutput extends LogOutput {
  final File file;
  IOSink? _sink;
  bool _isInitialized = false;

  FileOutput(this.file);

  @override
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

  @override
  void output(OutputEvent event) {
    if (!_isInitialized || _sink == null) {
      // 如果未初始化，尝试同步写入（作为备用方案）
      try {
        file.writeAsStringSync(
          '${event.lines.join('\n')}\n',
          mode: FileMode.writeOnlyAppend,
        );
      } catch (e) {
        // 静默失败，避免日志循环
      }
      return;
    }

    try {
      _sink!.writeAll(event.lines, '\n');
      _sink!.writeln();
      _sink!.flush();
    } catch (e) {
      // 如果IOSink出错，重置状态并尝试重新初始化
      _isInitialized = false;
      _sink = null;
    }
  }

  @override
  Future<void> destroy() async {
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

/// 日志管理器实现
class AppLoggerImpl implements IAppLogger {
  late Logger _logger;
  bool _initialized = false;
  String? _logFilePath;
  List<LogOutput>? _outputs; // 保存输出实例以便清理

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

    // 配置日志输出
    final List<LogOutput> outputs = [];

    // 控制台输出
    if (enableConsoleOutput) {
      outputs.add(ConsoleOutput());
    }

    // 文件输出
    if (enableFileOutput) {
      final logFile = await _getLogFile(customLogFileName);
      if (logFile != null) {
        final fileOutput = FileOutput(logFile);
        await fileOutput.init(); // 初始化文件输出
        outputs.add(fileOutput);
        _logFilePath = logFile.path;
      }
    }

    // 创建Logger实例
    _logger = Logger(
      level: _mapLogLevel(level),
      printer: PrettyPrinter(
        methodCount: 2, // 调用栈深度
        errorMethodCount: 8, // 错误时的调用栈深度
        lineLength: 120, // 每行字符数
        colors: true, // 彩色输出
        printEmojis: true, // 表情符号
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // 显示时间
      ),
      output: MultiOutput(outputs),
    );

    _outputs = outputs; // 保存输出实例
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

  /// 映射日志级别
  Level _mapLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return Level.trace;
      case LogLevel.debug:
        return Level.debug;
      case LogLevel.info:
        return Level.info;
      case LogLevel.warning:
        return Level.warning;
      case LogLevel.error:
        return Level.error;
      case LogLevel.wtf:
        return Level.fatal;
    }
  }

  @override
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_initialized) return;
    if (error is StackTrace && stackTrace == null) {
      stackTrace = error;
      error = null;
    }
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  @override
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_initialized) return;
    if (error is StackTrace && stackTrace == null) {
      stackTrace = error;
      error = null;
    }
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  @override
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_initialized) return;
    if (error is StackTrace && stackTrace == null) {
      stackTrace = error;
      error = null;
    }
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  @override
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_initialized) return;
    if (error is StackTrace && stackTrace == null) {
      stackTrace = error;
      error = null;
    }
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  @override
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_initialized) return;
    if (error is StackTrace && stackTrace == null) {
      stackTrace = error;
      error = null;
    }
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  @override
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_initialized) return;
    if (error is StackTrace && stackTrace == null) {
      stackTrace = error;
      error = null;
    }
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  @override
  void setLevel(LogLevel level) {
    // Note: logger package 不支持动态设置级别，需要重新创建Logger
    i('📅 Log level change requested to: ${level.name}');
    i('⚠️ Note: Level changes require logger reinitialization');
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

      // 清理输出实例
      if (_outputs != null) {
        for (final output in _outputs!) {
          await output.destroy();
        }
        _outputs = null;
      }

      _initialized = false;
      _logFilePath = null;
    }
  }
}
