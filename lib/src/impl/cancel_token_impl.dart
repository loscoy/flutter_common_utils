import 'package:dio/dio.dart';

import '../abstraction/i_cancel_token.dart';

/// CancelToken 的具体实现（包装 dio 的 CancelToken）
class CancelTokenImpl implements ICancelToken {
  final CancelToken _dioCancelToken;

  CancelTokenImpl([CancelToken? cancelToken])
      : _dioCancelToken = cancelToken ?? CancelToken();

  /// 获取原始的 dio CancelToken（仅供内部实现使用）
  CancelToken get dioCancelToken => _dioCancelToken;

  @override
  void cancel([dynamic reason]) {
    _dioCancelToken.cancel(reason);
  }

  @override
  bool get isCancelled => _dioCancelToken.isCancelled;
}
