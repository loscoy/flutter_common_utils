/// 日志级别枚举
enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  wtf, // What a Terrible Failure
}

/// 应用日志服务接口
abstract class IAppLogger {
  /// 初始化日志系统
  Future<void> init({
    LogLevel level = LogLevel.debug,
    bool enableConsoleOutput = true,
    bool enableFileOutput = true,
    String? customLogFileName,
  });

  void userAction({
    required String action,
    String? screen,
    Map<String, dynamic>? parameters,
    String? userId,
  });

  void performance({
    required String operation,
    required Duration duration,
    Map<String, dynamic>? metadata,
  });

  /// Verbose日志 - 最详细的日志
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]);

  /// Debug日志 - 调试信息
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]);

  /// Info日志 - 一般信息
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]);

  /// Warning日志 - 警告信息
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]);

  /// Error日志 - 错误信息
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]);

  /// WTF日志 - 严重错误
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]);

  /// 设置日志级别
  void setLevel(LogLevel level);

  /// 获取日志文件路径
  String? get logFilePath;

  /// 清理旧日志文件
  Future<void> cleanOldLogs({int keepDays = 7});

  /// 获取日志文件大小
  Future<int> getLogFileSize();

  /// 关闭日志系统
  Future<void> close();
}
