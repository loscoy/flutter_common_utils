// 文件日志 IO 实现 - 用于原生平台 (Android/iOS/Desktop)

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:talker_flutter/talker_flutter.dart' hide LogLevel;

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

/// 原生平台的日志文件辅助类
class FileLogHelper {
  static Future<File?> getLogFile(String? customFileName) async {
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

  static Future<void> cleanOldLogs({int keepDays = 7}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/logs');

      if (!await logsDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
      final files = await logsDir.list().toList();

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      // 静默失败
    }
  }

  static Future<int> getLogFileSize(String? logFilePath) async {
    if (logFilePath == null) return 0;

    try {
      final file = File(logFilePath);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      // 静默失败
    }

    return 0;
  }
}
