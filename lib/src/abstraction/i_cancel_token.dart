/// 取消令牌接口 - 用于取消异步操作
/// 这是对 dio 的 CancelToken 的抽象，避免直接依赖 dio
abstract class ICancelToken {
  /// 取消操作
  void cancel([dynamic reason]);

  /// 是否已被取消
  bool get isCancelled;
}
