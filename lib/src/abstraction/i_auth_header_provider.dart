/// 认证头部提供者抽象接口
///
/// 定义获取认证相关请求头的契约
abstract class IAuthHeaderProvider {
  /// 获取认证头部
  ///
  /// 参数:
  /// - [requireAuth] 是否需要认证（默认true）
  ///
  /// 返回包含认证信息的请求头映射
  Future<Map<String, String>> getAuthHeaders({bool requireAuth = true});
}
