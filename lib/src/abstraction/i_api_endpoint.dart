/// API 端点抽象接口
///
/// 定义 API 端点的基本契约，支持路径参数替换
abstract class IApiEndpoint {
  /// API 路径
  String get path;

  /// 构建带路径参数的完整路径
  ///
  /// 参数:
  /// - [pathParams] 路径参数映射，key为占位符名称（不含大括号），value为实际值
  ///
  /// 示例:
  /// ```dart
  /// final endpoint = MyEndpoint('/api/v1/item/{ID}');
  /// final path = endpoint.buildPath(pathParams: {'ID': '123'});
  /// // 结果: '/api/v1/item/123'
  /// ```
  String buildPath({Map<String, String>? pathParams});
}
