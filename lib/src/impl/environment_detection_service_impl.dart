import 'dart:io';
import 'package:flutter/foundation.dart';
import '../abstraction/i_app_logger.dart';
import '../abstraction/i_environment_service.dart';

/// 环境检测服务实现
class EnvironmentDetectionServiceImpl implements IEnvironmentDetectionService {
  final IAppLogger _logger;
  final IPlatformEnvironmentService _platformService;

  EnvironmentDetectionServiceImpl(this._logger, this._platformService);

  AppEnvironment _currentEnvironment = AppEnvironment.dev;

  @override
  AppEnvironment get currentEnvironment => _currentEnvironment;

  @override
  Future<void> init() async {
    final detectedEnv = await detectEnvironment();
    _currentEnvironment = detectedEnv;
  }

  @override
  Future<AppEnvironment> detectEnvironment() async {
    // 优先检查是否显式设置了环境变量
    const envString = String.fromEnvironment('APP_ENV', defaultValue: '');

    if (envString.isNotEmpty) {
      final environment = switch (envString.toLowerCase()) {
        'prod' || 'production' => AppEnvironment.prod,
        'staging' || 'test' => AppEnvironment.staging,
        _ => AppEnvironment.dev,
      };
      _logger.i('使用显式配置的API环境: ${environment.name}');
      return environment;
    }

    // 未显式配置时，根据平台和编译模式自动识别
    final detectedEnv = await _detectEnvironmentFromBuildMode();
    _logger.i('自动识别API环境: ${detectedEnv.name}');
    return detectedEnv;
  }

  /// 根据编译模式自动检测环境
  Future<AppEnvironment> _detectEnvironmentFromBuildMode() async {
    // Debug模式下始终使用dev环境
    if (kDebugMode) {
      _logger.d('DEBUG模式，使用dev环境');
      return AppEnvironment.dev;
    }

    // Release模式下根据平台判断
    if (kReleaseMode) {
      if (Platform.isIOS) {
        return await _detectIOSEnvironment();
      } else if (Platform.isAndroid) {
        return await _detectAndroidEnvironment();
      }
    }

    // 其他情况默认使用dev
    _logger.d('未识别的模式，默认使用dev环境');
    return AppEnvironment.dev;
  }

  /// iOS环境检测
  Future<AppEnvironment> _detectIOSEnvironment() async {
    final isTestFlight = await _platformService.isTestFlightOrBeta();

    if (isTestFlight) {
      _logger.i('iOS: 检测到TestFlight环境');
      return AppEnvironment.staging;
    }

    _logger.i('iOS: Release模式，使用production环境');
    return AppEnvironment.prod;
  }

  /// Android环境检测
  Future<AppEnvironment> _detectAndroidEnvironment() async {
    final isBeta = await _platformService.isTestFlightOrBeta();

    if (isBeta) {
      _logger.i('Android: 检测到Beta/内部测试环境');
      return AppEnvironment.staging;
    }

    _logger.i('Android: Release模式，使用production环境');
    return AppEnvironment.prod;
  }
}
