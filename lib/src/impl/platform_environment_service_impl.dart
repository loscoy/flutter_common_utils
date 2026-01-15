import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../abstraction/i_app_logger.dart';
import '../abstraction/i_environment_service.dart';

/// 平台环境检测服务实现
class PlatformEnvironmentServiceImpl implements IPlatformEnvironmentService {
  final IAppLogger _logger;

  PlatformEnvironmentServiceImpl(this._logger);

  // Method Channel
  static const _channel = MethodChannel('com.foodscanner.environment');

  /// 判断当前是否为 iOS 平台（Web 安全）
  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// 判断当前是否为 Android 平台（Web 安全）
  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<bool> isTestFlightOrBeta() async {
    // Web 平台不支持 TestFlight/Beta 检测
    if (kIsWeb) return false;

    if (_isIOS) {
      return _isIOSTestFlight();
    } else if (_isAndroid) {
      return _isAndroidBeta();
    }
    return false;
  }

  /// iOS TestFlight检测
  Future<bool> _isIOSTestFlight() async {
    try {
      final result = await _channel.invokeMethod<bool>('isTestFlight');
      final isTestFlight = result ?? false;

      if (isTestFlight) {
        _logger.i('iOS环境检测: TestFlight');
      } else {
        _logger.i('iOS环境检测: Production');
      }

      return isTestFlight;
    } catch (e) {
      _logger.w('iOS环境检测失败: $e');
      return false;
    }
  }

  /// Android Beta检测
  Future<bool> _isAndroidBeta() async {
    try {
      final result = await _channel.invokeMethod<bool>('isBeta');
      final isBeta = result ?? false;

      if (isBeta) {
        _logger.i('Android环境检测: Beta/Internal Test');
      } else {
        _logger.i('Android环境检测: Production');
      }

      return isBeta;
    } catch (e) {
      _logger.w('Android环境检测失败: $e');
      return false;
    }
  }

  @override
  Future<String?> getInstallerPackageName() async {
    // Web 和非 Android 平台不支持
    if (!_isAndroid) {
      return null;
    }

    try {
      final installer =
          await _channel.invokeMethod<String>('getInstallerPackageName');
      _logger.d('Android installer package: ${installer ?? "null"}');
      return installer;
    } catch (e) {
      _logger.w('获取installer package失败: $e');
      return null;
    }
  }
}
