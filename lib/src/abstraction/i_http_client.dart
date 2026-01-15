import 'package:dio/dio.dart';

import 'i_cancel_token.dart';

/// 网络请求状态枚举
enum RequestStatus {
  loading,
  success,
  cancelled,
  error,
  timeout,
  noNetwork,
}

/// 统一的网络响应类
class ApiResponse<T> {
  final RequestStatus status;
  final T? data;
  final String? message;
  final int? statusCode;
  final dynamic error;
  final String? authorization;

  const ApiResponse({
    required this.status,
    this.data,
    this.message,
    this.statusCode,
    this.error,
    this.authorization,
  });

  factory ApiResponse.loading() {
    return const ApiResponse(status: RequestStatus.loading);
  }

  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
    String? authorization,
  }) {
    return ApiResponse(
      status: RequestStatus.success,
      data: data,
      message: message,
      statusCode: statusCode,
      authorization: authorization,
    );
  }

  factory ApiResponse.cancelled({String? message}) {
    return ApiResponse(
      status: RequestStatus.cancelled,
      message: message ?? 'Request was cancelled by user',
    );
  }

  factory ApiResponse.error({String? message, int? statusCode, dynamic error}) {
    return ApiResponse(
      status: RequestStatus.error,
      message: message,
      statusCode: statusCode,
      error: error,
    );
  }

  factory ApiResponse.timeout({String? message}) {
    return ApiResponse(
      status: RequestStatus.timeout,
      message: message ?? 'Request timeout',
    );
  }

  factory ApiResponse.noNetwork({String? message}) {
    return ApiResponse(
      status: RequestStatus.noNetwork,
      message: message ?? 'Network connection failed',
    );
  }

  bool get isSuccess => status == RequestStatus.success;
  bool get isCancelled => status == RequestStatus.cancelled;
  bool get isError => status == RequestStatus.error;
  bool get isLoading => status == RequestStatus.loading;
  bool get isTimeout => status == RequestStatus.timeout;
  bool get isNoNetwork => status == RequestStatus.noNetwork;
}

/// 跨平台文件上传抽象类
/// 提供统一的文件上传接口，支持 Web 和原生平台
class UploadFile {
  /// 文件路径（仅在原生平台使用）
  final String? path;

  /// 文件名
  final String filename;

  /// 文件字节数据（用于 Web 平台或内存中的文件）
  final List<int>? bytes;

  /// 文件 MIME 类型
  final String? mimeType;

  /// 通过文件路径创建（原生平台）
  const UploadFile.fromPath({
    required this.path,
    required this.filename,
    this.mimeType,
  }) : bytes = null;

  /// 通过字节数据创建（Web 平台或内存文件）
  const UploadFile.fromBytes({
    required this.bytes,
    required this.filename,
    this.mimeType,
  }) : path = null;

  /// 是否使用字节数据
  bool get useBytes => bytes != null;
}

/// HTTP客户端接口
abstract class IHttpClient {
  /// GET请求(自定义BaseUrl)
  Future<ApiResponse<T>> getWithBaseUrl<T>({
    required String baseUrl,
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    ICancelToken? cancelToken,
    T Function(dynamic)? converter,
  });

  /// POST请求(自定义BaseUrl)
  Future<ApiResponse<T>> postWithBaseUrl<T>({
    required String baseUrl,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    ICancelToken? cancelToken,
    T Function(dynamic)? converter,
  });

  /// PUT请求(自定义BaseUrl)
  Future<ApiResponse<T>> putWithBaseUrl<T>({
    required String baseUrl,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    ICancelToken? cancelToken,
    T Function(dynamic)? converter,
  });

  /// DELETE请求(自定义BaseUrl)
  Future<ApiResponse<T>> deleteWithBaseUrl<T>({
    required String baseUrl,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    ICancelToken? cancelToken,
    T Function(dynamic)? converter,
  });

  /// 上传文件
  /// 使用 [UploadFile] 类型以支持跨平台
  Future<ApiResponse<T>> uploadFile<T>({
    required String baseUrl,
    required String path,
    required List<UploadFile> files,
    String fileKey = 'file',
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    ProgressCallback? onSendProgress,
    ICancelToken? cancelToken,
    T Function(dynamic)? converter,
  });

  /// 下载文件
  Future<ApiResponse<String>> downloadFile({
    required String url,
    required String savePath,
    ProgressCallback? onReceiveProgress,
    ICancelToken? cancelToken,
  });
}
