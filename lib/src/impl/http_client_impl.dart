// dart:io 仅在非 Web 平台使用
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../abstraction/i_app_logger.dart';
import '../abstraction/i_cancel_token.dart';
import '../abstraction/i_http_client.dart';
import 'cancel_token_impl.dart';

/// HTTP客户端实现类
class HttpClientImpl implements IHttpClient {
  final IAppLogger _logger;

  HttpClientImpl(this._logger);

  /// 缓存不同 baseUrl 的 Dio 实例，避免重复创建
  final Map<String, Dio> _dioCache = {};

  /// 获取或创建缓存的 Dio 实例
  Dio _getCachedDio(String baseUrl) {
    if (!_dioCache.containsKey(baseUrl)) {
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: 60000),
        receiveTimeout: const Duration(milliseconds: 60000),
        sendTimeout: const Duration(milliseconds: 60000),
        responseType: ResponseType.json,
      ));

      // 添加拦截器
      _addInterceptors(dio);

      // 添加智能重试拦截器
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: (message) => _logger.d(message),
          retries: 2,
          retryDelays: const [
            Duration(seconds: 1),
            Duration(seconds: 2),
          ],
          retryableExtraStatuses: {408, 502, 503, 504, 522, 524},
        ),
      );

      _dioCache[baseUrl] = dio;
    }
    return _dioCache[baseUrl]!;
  }

  /// 添加拦截器
  void _addInterceptors(Dio dio) {
    // 使用 TalkerDioLogger 记录 HTTP 请求/响应
    dio.interceptors.add(
      TalkerDioLogger(
        talker: _logger.talkerInstance,
        settings: const TalkerDioLoggerSettings(
          // 打印请求头
          printRequestHeaders: true,
          // 打印响应头
          printResponseHeaders: false,
          // 打印请求数据
          printRequestData: true,
          // 打印响应数据
          printResponseData: true,
          // 打印响应消息
          printResponseMessage: true,
        ),
      ),
    );
  }

  @override
  Future<ApiResponse<T>> getWithBaseUrl<T>({
    required String baseUrl,
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    ICancelToken? cancelToken,
    T Function(dynamic)? converter,
  }) async {
    try {
      final dio = _getCachedDio(baseUrl);
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: _extractDioCancelToken(cancelToken),
      );

      return _handleResponse<T>(response, converter);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<ApiResponse<T>> postWithBaseUrl<T>({
    required String baseUrl,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    ICancelToken? cancelToken,
    T Function(dynamic)? converter,
  }) async {
    try {
      final dio = _getCachedDio(baseUrl);
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: _extractDioCancelToken(cancelToken),
      );

      return _handleResponse<T>(response, converter);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<ApiResponse<T>> putWithBaseUrl<T>({
    required String baseUrl,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    ICancelToken? cancelToken,
    T Function(dynamic)? converter,
  }) async {
    try {
      final dio = _getCachedDio(baseUrl);
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: _extractDioCancelToken(cancelToken),
      );

      return _handleResponse<T>(response, converter);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<ApiResponse<T>> deleteWithBaseUrl<T>({
    required String baseUrl,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    ICancelToken? cancelToken,
    T Function(dynamic)? converter,
  }) async {
    try {
      final dio = _getCachedDio(baseUrl);
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: _extractDioCancelToken(cancelToken),
      );

      return _handleResponse<T>(response, converter);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
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
  }) async {
    try {
      final formData = FormData();

      for (int i = 0; i < files.length; i++) {
        final file = files[i];

        // 根据文件类型选择创建方式
        MultipartFile multipartFile;
        if (file.useBytes) {
          // Web 平台或内存文件：使用字节数据
          multipartFile = MultipartFile.fromBytes(
            file.bytes!,
            filename: file.filename,
          );
        } else {
          // 原生平台：使用文件路径
          multipartFile = await MultipartFile.fromFile(
            file.path!,
            filename: file.filename,
          );
        }

        formData.files.add(
          MapEntry(fileKey, multipartFile),
        );
      }

      if (data != null) {
        formData.fields.addAll(
          data.entries.map(
            (entry) => MapEntry(entry.key, entry.value.toString()),
          ),
        );
      }

      final dio = _getCachedDio(baseUrl);
      final response = await dio.post(
        path,
        data: formData,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
        cancelToken: _extractDioCancelToken(cancelToken),
      );

      return _handleResponse<T>(response, converter);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<ApiResponse<String>> downloadFile({
    required String url,
    required String savePath,
    ProgressCallback? onReceiveProgress,
    ICancelToken? cancelToken,
  }) async {
    try {
      // 从 URL 提取 baseUrl
      final uri = Uri.parse(url);
      final baseUrl =
          '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
      final path = uri.path;

      final dio = _getCachedDio(baseUrl);
      await dio.download(
        path,
        savePath,
        queryParameters: uri.queryParameters,
        onReceiveProgress: onReceiveProgress,
        cancelToken: _extractDioCancelToken(cancelToken),
      );

      return ApiResponse.success(
        data: savePath,
        message: '下载成功',
      );
    } catch (e) {
      return _handleError<String>(e);
    }
  }

  /// 从 ICancelToken 中提取 dio 的 CancelToken
  CancelToken? _extractDioCancelToken(ICancelToken? cancelToken) {
    if (cancelToken == null) {
      return null;
    }
    if (cancelToken is CancelTokenImpl) {
      return cancelToken.dioCancelToken;
    }
    // 如果是其他实现，无法转换，返回 null
    return null;
  }

  ApiResponse<T> _handleResponse<T>(
      Response response, T Function(dynamic)? converter) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      T? data;
      if (converter != null) {
        try {
          data = converter(response.data);
        } catch (converterError, stackTrace) {
          _logger.e(
            'Data conversion failed - Response: ${response.data}, Type: ${response.data.runtimeType}',
            converterError,
            stackTrace,
          );
          return ApiResponse.error(
            statusCode: response.statusCode,
            message: 'Data conversion failed: ${converterError.toString()}',
            error: converterError,
          );
        }
      } else {
        try {
          data = response.data as T?;
        } catch (castError, stackTrace) {
          _logger.e(
            'Type casting failed - Expected: $T, Actual: ${response.data.runtimeType}, Data: ${response.data}',
            castError,
            stackTrace,
          );
          return ApiResponse.error(
            statusCode: response.statusCode,
            message:
                'Type casting failed: Expected $T but got ${response.data.runtimeType}',
            error: castError,
          );
        }
      }

      return ApiResponse.success(
        data: data,
        statusCode: response.statusCode,
        message: 'Request successful',
        authorization: response.headers.value('authorization'),
      );
    } else {
      return ApiResponse.error(
        statusCode: response.statusCode,
        message: 'Request failed',
        error: response.data,
      );
    }
  }

  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiResponse.timeout(
            message: 'Request timeout, please check network connection',
          );

        case DioExceptionType.connectionError:
          return ApiResponse.noNetwork(
            message: 'Network connection failed, please check network settings',
          );

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          String message;

          switch (statusCode) {
            case 400:
              message = 'Request parameter error';
              break;
            case 401:
              message = 'Unauthorized, please login again';
              break;
            case 403:
              message = 'Access denied';
              break;
            case 404:
              message = 'Requested resource does not exist';
              break;
            case 500:
              message = 'Server internal error';
              break;
            default:
              message = 'Request failed';
          }

          return ApiResponse.error(
            statusCode: statusCode,
            message: message,
            error: error.response,
          );

        case DioExceptionType.cancel:
          return ApiResponse.cancelled(message: 'Request cancelled');

        default:
          return ApiResponse.error(
            message: error.message ?? 'Unknown error',
            error: error,
          );
      }
    }

    return ApiResponse.error(
      message: error.toString(),
      error: error,
    );
  }
}
