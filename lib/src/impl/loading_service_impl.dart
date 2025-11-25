import 'package:common_utils/src/abstraction/i_app_logger.dart';
import 'package:common_utils/src/abstraction/i_loading_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoadingServiceImpl implements ILoadingService {
  final IAppLogger _logger;

  LoadingServiceImpl(this._logger) {
    _configureEasyLoading();
  }

  @override
  Widget Function(BuildContext, Widget?) init({
    Widget Function(BuildContext, Widget?)? builder,
  }) {
    return EasyLoading.init(builder: builder);
  }

  void _configureEasyLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      // ..progressColor = Colors.yellow
      // ..backgroundColor = Colors.green
      // ..indicatorColor = Colors.yellow
      // ..textColor = Colors.yellow
      // ..maskColor = Colors.blue.withValues(alpha: 0.5)
      ..maskType = EasyLoadingMaskType.black
      // ..userInteractions = true
      ..dismissOnTap = false;
  }

  @override
  Future<void> show([String? status, EasyLoadingMaskType? maskType]) async {
    try {
      if (maskType != null) {
        EasyLoading.instance.maskType = maskType;
      }
      await EasyLoading.show(status: status ?? 'Loading...');
      _logger.d(
        'EasyLoading shown: ${status ?? "Loading..."}, maskType: ${maskType ?? "default"}',
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to show EasyLoading', e, stackTrace);
    }
  }

  @override
  Future<void> showProgress(
    double value, {
    String? status,
    EasyLoadingMaskType? maskType,
  }) async {
    try {
      if (maskType != null) {
        EasyLoading.instance.maskType = maskType;
      }
      await EasyLoading.showProgress(value, status: status);
      _logger.d(
        'EasyLoading progress shown: $value, status: ${status ?? "无"}, maskType: ${maskType ?? "default"}',
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to show EasyLoading progress', e, stackTrace);
    }
  }

  @override
  Future<void> showSuccess([
    String? status,
    EasyLoadingMaskType? maskType,
  ]) async {
    try {
      if (maskType != null) {
        EasyLoading.instance.maskType = maskType;
      }
      await EasyLoading.showSuccess(status ?? 'Success!');
      _logger.d(
        'EasyLoading success shown: ${status ?? "Success!"}, maskType: ${maskType ?? "default"}',
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to show EasyLoading success', e, stackTrace);
    }
  }

  @override
  Future<void> showError([
    String? status,
    EasyLoadingMaskType? maskType,
  ]) async {
    try {
      if (maskType != null) {
        EasyLoading.instance.maskType = maskType;
      }
      await EasyLoading.showError(status ?? 'Error!');
      _logger.w(
        'EasyLoading error shown: ${status ?? "Error!"}, maskType: ${maskType ?? "default"}',
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to show EasyLoading error', e, stackTrace);
    }
  }

  @override
  Future<void> showInfo([String? status, EasyLoadingMaskType? maskType]) async {
    try {
      if (maskType != null) {
        EasyLoading.instance.maskType = maskType;
      }
      await EasyLoading.showInfo(status ?? 'Info');
      _logger.d(
        'EasyLoading info shown: ${status ?? "Info"}, maskType: ${maskType ?? "default"}',
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to show EasyLoading info', e, stackTrace);
    }
  }

  @override
  Future<void> showToast(String status) async {
    try {
      await EasyLoading.showToast(status);
      _logger.d('EasyLoading toast shown: $status');
    } catch (e, stackTrace) {
      _logger.e('Failed to show EasyLoading toast', e, stackTrace);
    }
  }

  @override
  Future<void> dismiss() async {
    try {
      await EasyLoading.dismiss();
      _logger.d('EasyLoading dismissed');
    } catch (e, stackTrace) {
      _logger.e('Failed to dismiss EasyLoading', e, stackTrace);
    }
  }

  @override
  bool get isShow => EasyLoading.isShow;
  @override
  Future<void> showWithCallback({
    required Future<void> Function() callback,
    String? loadingText,
    String? successText,
    String? errorText,
    EasyLoadingMaskType? maskType,
  }) async {
    try {
      show(loadingText, maskType);

      await callback();

      dismiss();
      if (successText != null) {
        showSuccess(successText, maskType);
      }

      _logger.i('Async operation completed successfully');
    } catch (e, stackTrace) {
      _logger.e('Async operation failed', e, stackTrace);
      dismiss();

      if (errorText != null) {
        showError(errorText, maskType);
      } else {
        showError('Operation failed: ${e.toString()}', maskType);
      }
      rethrow;
    }
  }

  @override
  Future<T> showWithResult<T>({
    required Future<T> Function() callback,
    String? loadingText,
    String? successText,
    String? errorText,
    EasyLoadingMaskType? maskType,
  }) async {
    try {
      show(loadingText, maskType);

      final result = await callback();

      dismiss();
      if (successText != null) {
        showSuccess(successText, maskType);
      }

      _logger.i('Async operation with result completed successfully');
      return result;
    } catch (e, stackTrace) {
      _logger.e('Async operation with result failed', e, stackTrace);
      dismiss();

      if (errorText != null) {
        showError(errorText, maskType);
      } else {
        showError('Operation failed: ${e.toString()}', maskType);
      }
      rethrow;
    }
  }

  @override
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
  }) {
    try {
      if (loadingStyle != null)
        EasyLoading.instance.loadingStyle = loadingStyle;
      if (indicatorType != null)
        EasyLoading.instance.indicatorType = indicatorType;
      if (backgroundColor != null)
        EasyLoading.instance.backgroundColor = backgroundColor;
      if (indicatorColor != null)
        EasyLoading.instance.indicatorColor = indicatorColor;
      if (textColor != null) EasyLoading.instance.textColor = textColor;
      if (progressColor != null)
        EasyLoading.instance.progressColor = progressColor;
      if (indicatorSize != null)
        EasyLoading.instance.indicatorSize = indicatorSize;
      if (radius != null) EasyLoading.instance.radius = radius;
      if (userInteractions != null)
        EasyLoading.instance.userInteractions = userInteractions;
      if (dismissOnTap != null)
        EasyLoading.instance.dismissOnTap = dismissOnTap;
      if (displayDuration != null)
        EasyLoading.instance.displayDuration = displayDuration;
      if (maskType != null) EasyLoading.instance.maskType = maskType;

      _logger.d('EasyLoading style updated');
    } catch (e, stackTrace) {
      _logger.e('Failed to update EasyLoading style', e, stackTrace);
    }
  }
}
