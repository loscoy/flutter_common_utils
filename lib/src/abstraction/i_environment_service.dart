/// API环境枚举
enum AppEnvironment {
  /// 开发环境
  dev,

  /// TestFlight测试环境
  staging,

  /// 生产环境
  prod;

  String get firebaseEnvName {
    switch (this) {
      case AppEnvironment.dev:
        return 'Sandbox';
      case AppEnvironment.staging:
        return 'TestFlight';
      case AppEnvironment.prod:
        return 'Product';
    }
  }
}

/// 平台环境检测服务接口
abstract class IPlatformEnvironmentService {
  /// 检测是否为TestFlight环境（iOS）或内部测试环境（Android）
  Future<bool> isTestFlightOrBeta();

  /// 获取installer包名（仅Android）
  Future<String?> getInstallerPackageName();
}

/// 环境检测服务接口
abstract class IEnvironmentDetectionService {
  /// 当前环境
  AppEnvironment get currentEnvironment;

  /// 初始化
  Future<void> init();

  /// 检测环境
  Future<AppEnvironment> detectEnvironment();
}
