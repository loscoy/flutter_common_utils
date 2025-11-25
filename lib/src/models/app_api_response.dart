import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_api_response.freezed.dart';

/// API响应状态union类型
@Freezed(genericArgumentFactories: true)
abstract class AppApiResponse<T> with _$AppApiResponse<T> {
  const factory AppApiResponse.success(T data) = AppApiResponseSuccess;
  const factory AppApiResponse.error(String message) = AppApiResponseError;
  const factory AppApiResponse.noUser() = AppApiResponseNoUser;

  // 自定义 fromJson，根据 code 判断类型
  factory AppApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    final code = json['code'] as int;
    final message = json['message'] as String? ?? '';
    final data = json['data'];

    // 根据业务状态码判断
    switch (code) {
      case 20000:
        // 成功：解析 data 字段
        return AppApiResponse.success(fromJsonT(data));
      case 40012:
        return AppApiResponse.noUser();

      default:
        // 其他错误码：返回错误消息
        return AppApiResponse.error(message);
    }
  }
}
