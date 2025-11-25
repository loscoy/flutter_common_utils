import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

abstract interface class ILoadingService {
  Widget Function(BuildContext, Widget?) init({
    Widget Function(BuildContext, Widget?)? builder,
  });

  Future<void> show([String? status, EasyLoadingMaskType? maskType]);

  Future<void> showProgress(
    double value, {
    String? status,
    EasyLoadingMaskType? maskType,
  });

  Future<void> showSuccess([
    String? status,
    EasyLoadingMaskType? maskType,
  ]);

  Future<void> showError([
    String? status,
    EasyLoadingMaskType? maskType,
  ]);

  Future<void> showInfo([String? status, EasyLoadingMaskType? maskType]);

  Future<void> showToast(String status);

  Future<void> dismiss();

  bool get isShow;

  Future<void> showWithCallback({
    required Future<void> Function() callback,
    String? loadingText,
    String? successText,
    String? errorText,
    EasyLoadingMaskType? maskType,
  });

  Future<T> showWithResult<T>({
    required Future<T> Function() callback,
    String? loadingText,
    String? successText,
    String? errorText,
    EasyLoadingMaskType? maskType,
  });

  void updateLoadingStyle({
    EasyLoadingStyle? loadingStyle,
    EasyLoadingIndicatorType? indicatorType,
    Color? backgroundColor,
    Color? indicatorColor,
    Color? textColor,
    Color? progressColor,
    double? indicatorSize,
    double? radius,
    bool? userInteractions,
    bool? dismissOnTap,
    Duration? displayDuration,
    EasyLoadingMaskType? maskType,
  });
}
