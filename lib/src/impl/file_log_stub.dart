// 文件日志 stub - 用于 Web 平台的 Wasm 兼容
// Web 平台不支持文件系统操作

import 'package:talker_flutter/talker_flutter.dart' hide LogLevel;

/// Web 平台的文件日志观察者 stub
/// 在 Web 平台上不执行任何操作
class FileLogObserver extends TalkerObserver {
  FileLogObserver(dynamic file);

  Future<void> init() async {
    // Web 平台不支持文件日志
  }

  @override
  void onLog(TalkerData log) {
    // Web 平台不执行任何操作
  }

  @override
  void onError(TalkerError err) {
    // Web 平台不执行任何操作
  }

  @override
  void onException(TalkerException exception) {
    // Web 平台不执行任何操作
  }

  Future<void> dispose() async {
    // Web 平台不执行任何操作
  }
}

/// Web 平台的日志文件辅助类
/// 提供空实现以满足接口要求
class FileLogHelper {
  static Future<dynamic> getLogFile(String? customFileName) async {
    // Web 平台不支持文件日志
    return null;
  }

  static Future<void> cleanOldLogs({int keepDays = 7}) async {
    // Web 平台不执行任何操作
  }

  static Future<int> getLogFileSize(String? logFilePath) async {
    return 0;
  }
}
