import 'package:common_utils/src/models/app_api_response.dart';
import 'package:meta/meta.dart';
import '../abstraction/i_api_endpoint.dart';
import '../abstraction/i_app_logger.dart';
import '../abstraction/i_auth_header_provider.dart';
import '../abstraction/i_environment_config.dart';
import '../abstraction/i_http_client.dart';

/// 通用的 API 服务基类
///
/// 提供统一的 API 调用接口，封装了环境配置、认证、日志等逻辑
///
/// 使用示例:
/// ```dart
/// class MyApiService extends BaseApiService {
///   MyApiService({
///     required super.httpClient,
///     required super.environmentConfig,
///     required super.logger,
///     super.authHeaderProvider,
///   });
///
///   @override
///   Future<MyApiResponse<T?>> handleResponse<T>(
///     ApiResponse<dynamic> httpResponse,
///     T Function(dynamic)? converter,
///   ) async {
///     // 实现具体的响应处理逻辑
///   }
/// }
/// ```
abstract class BaseApiService {
  final IHttpClient httpClient;
  final IEnvironmentConfig environmentConfig;
  final IAuthHeaderProvider? authHeaderProvider;
  final IAppLogger logger;

  BaseApiService({
    required this.httpClient,
    required this.environmentConfig,
    required this.logger,
    this.authHeaderProvider,
  });

  /// 获取当前环境的 baseUrl
  String get baseUrl => environmentConfig.baseUrl;

  /// 获取当前环境名称
  String get envName => environmentConfig.envName;

  /// 获取请求头部
  ///
  /// 合并环境默认头部和认证头部（如果提供了认证提供者）
  /// 子类可以覆盖此方法来添加额外的头部
  @protected
  Future<Map<String, String>> getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{...environmentConfig.defaultHeaders};

    if (authHeaderProvider != null) {
      final authHeaders = await authHeaderProvider!.getAuthHeaders(
        requireAuth: requireAuth,
      );
      headers.addAll(authHeaders);
    }

    return headers;
  }

  /// 处理 HTTP 响应，转换为业务响应类型
  ///
  /// 此方法由子类实现，用于将通用的 HTTP 响应转换为具体的业务响应
  ///
  /// 参数:
  /// - [httpResponse] HTTP 层的响应对象
  /// - [converter] 数据转换器，将响应数据转换为目标类型 T
  ///
  /// 返回:
  /// - 业务响应对象，类型由具体实现决定
  Future<AppApiResponse<T?>> handleResponse<T>(
    ApiResponse<dynamic> httpResponse,
    T Function(dynamic)? converter,
  );

  /// 通用 GET 请求
  ///
  /// 参数:
  /// - [endpoint] API 端点对象
  /// - [queryParameters] 查询参数
  /// - [pathParameters] 路径参数（用于替换 URL 中的占位符）
  /// - [converter] 数据转换器，将响应数据转换为目标类型
  /// - [requireAuth] 是否需要认证（默认true）
  Future<AppApiResponse<T?>> get<T>({
    required IApiEndpoint endpoint,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? pathParameters,
    T Function(dynamic)? converter,
    bool requireAuth = true,
  }) async {
    final path = endpoint.buildPath(pathParams: pathParameters);
    logger.d('API GET: $path [$envName]');

    final httpResponse = await httpClient.getWithBaseUrl<Map<String, dynamic>>(
      baseUrl: baseUrl,
      path: path,
      queryParameters: queryParameters,
      converter: (data) => data,
      headers: await getHeaders(requireAuth: requireAuth),
    );

    return await handleResponse<T>(httpResponse, converter);
  }

  /// 通用 POST 请求
  ///
  /// 参数:
  /// - [endpoint] API 端点对象
  /// - [data] 请求体数据
  /// - [queryParameters] 查询参数
  /// - [pathParameters] 路径参数（用于替换 URL 中的占位符）
  /// - [converter] 数据转换器
  /// - [requireAuth] 是否需要认证（默认true）
  Future<AppApiResponse<T?>> post<T>({
    required IApiEndpoint endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? pathParameters,
    T Function(dynamic)? converter,
    bool requireAuth = true,
  }) async {
    final path = endpoint.buildPath(pathParams: pathParameters);
    logger.d('API POST: $path [$envName]');

    final httpResponse = await httpClient.postWithBaseUrl<Map<String, dynamic>>(
      baseUrl: baseUrl,
      path: path,
      data: data,
      queryParameters: queryParameters,
      converter: (data) => data,
      headers: await getHeaders(requireAuth: requireAuth),
    );

    return await handleResponse<T>(httpResponse, converter);
  }

  /// 通用 DELETE 请求
  ///
  /// 参数:
  /// - [endpoint] API 端点对象
  /// - [data] 请求体数据
  /// - [queryParameters] 查询参数
  /// - [pathParameters] 路径参数（用于替换 URL 中的占位符）
  /// - [converter] 数据转换器
  /// - [requireAuth] 是否需要认证（默认true）
  Future<AppApiResponse<T?>> delete<T>({
    required IApiEndpoint endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? pathParameters,
    T Function(dynamic)? converter,
    bool requireAuth = true,
  }) async {
    final path = endpoint.buildPath(pathParams: pathParameters);
    logger.d('API DELETE: $path [$envName]');

    final httpResponse =
        await httpClient.deleteWithBaseUrl<Map<String, dynamic>>(
      baseUrl: baseUrl,
      path: path,
      data: data,
      queryParameters: queryParameters,
      converter: (data) => data,
      headers: await getHeaders(requireAuth: requireAuth),
    );

    return await handleResponse<T>(httpResponse, converter);
  }
}
