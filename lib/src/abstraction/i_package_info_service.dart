/// 包信息服务接口
abstract class IPackageInfoService {
  /// 初始化服务
  Future<void> init();

  /// 是否已初始化
  bool get isInitialized;

  /// 应用名称
  String get appName;

  /// 包名
  String get packageName;

  /// 版本号
  String get version;

  /// 构建号
  String get buildNumber;

  /// 构建签名
  String get buildSignature;

  /// 安装商店
  String get installerStore;

  /// 完整版本号 (version+buildNumber)
  String get fullVersion;

  /// 获取所有信息
  Map<String, dynamic> getAllInfo();

  /// 记录所有信息到日志
  void logAllInfo();
}
