/// 环境配置抽象接口
///
/// 定义环境相关的配置参数
abstract class IEnvironmentConfig {
  /// API 基础 URL
  String get baseUrl;

  /// 环境名称（如：dev, staging, production）
  String get envName;

  /// 默认请求头部
  Map<String, String> get defaultHeaders;
}
