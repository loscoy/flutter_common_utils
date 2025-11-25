import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

import '../abstraction/i_app_logger.dart';
import '../abstraction/i_http_client.dart';

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
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final requestData = options.data.toString();

          final buffer = StringBuffer();
          buffer.writeln('🌐 NETWORK REQUEST');
          buffer.writeln('Method: ${options.method}');
          buffer.writeln('URL: ${options.baseUrl}${options.path}');

          if (options.headers.isNotEmpty) {
            buffer.writeln('Headers: ${options.headers}');
          }

          if (requestData.isNotEmpty) {
            buffer.writeln(
                'Request: ${requestData.length > 200 ? requestData.substring(0, 200) : requestData}');
          }

          _logger.i(buffer.toString());

          handler.next(options);
        },
        onResponse: (response, handler) {
          final buffer = StringBuffer();
          buffer.writeln('🌐 NETWORK RESPONSE');
          buffer.writeln('Method: ${response.requestOptions.method}');
          buffer.writeln(
              'URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');
          buffer.writeln('Status: ${response.statusCode}');

          if (response.data != null) {
            buffer.writeln('Response: ${response.data}');
          }

          _logger.i(buffer.toString());

          handler.next(response);
        },
        onError: (error, handler) {
          final buffer = StringBuffer();
          buffer.writeln('🌐 NETWORK ERROR');
          buffer.writeln('Method: ${error.requestOptions.method}');
          buffer.writeln(
              'URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
          buffer.writeln('Status: ${error.response?.statusCode}');
          buffer.writeln(
              'Error: ${error.message ?? error.response?.data?.toString()}');

          _logger.e(buffer.toString(), error);

          handler.next(error);
        },
      ),
    );
  }

  @override
  Future<ApiResponse<T>> getWithBaseUrl<T>({
    required String baseUrl,
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    T Function(dynamic)? converter,
  }) async {
    try {
      final dio = _getCachedDio(baseUrl);
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
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
    CancelToken? cancelToken,
    T Function(dynamic)? converter,
  }) async {
    try {
      final dio = _getCachedDio(baseUrl);
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
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
    CancelToken? cancelToken,
    T Function(dynamic)? converter,
  }) async {
    try {
      final dio = _getCachedDio(baseUrl);
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
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
    CancelToken? cancelToken,
    T Function(dynamic)? converter,
  }) async {
    try {
      final dio = _getCachedDio(baseUrl);
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
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
    required List<File> files,
    String fileKey = 'file',
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    T Function(dynamic)? converter,
  }) async {
    try {
      final formData = FormData();

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        formData.files.add(
          MapEntry(
            fileKey,
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
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
        cancelToken: cancelToken,
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
    CancelToken? cancelToken,
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
        cancelToken: cancelToken,
      );

      return ApiResponse.success(
        data: savePath,
        message: '下载成功',
      );
    } catch (e) {
      return _handleError<String>(e);
    }
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
          return ApiResponse.error(message: 'Request cancelled');

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
