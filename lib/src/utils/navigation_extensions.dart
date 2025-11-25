/*
 * @Description: Navigation extensions for simplified context-based navigation
 * @Author: Loscoy
 * @Date: 2025-09-25
 * @LastEditTime: 2025-09-25
 * @LastEditors: Loscoy
 */

import 'package:flutter/material.dart';

/// Navigation extensions for BuildContext
///
/// 提供便捷的导航操作，支持直接传入Widget或Route
///
/// 使用示例：
/// ```dart
/// // 推送一个Widget页面
/// context.push(MyPage());
///
/// // 推送一个自定义Route
/// context.push(MaterialPageRoute(builder: (context) => MyPage()));
///
/// // 推送Widget并等待返回结果
/// final result = await context.push<String>(MyPage());
///
/// // 替换当前页面
/// context.pushReplacement(MyPage());
///
/// // 推送并移除所有之前的页面
/// context.pushAndRemoveUntil(HomePage(), (route) => false);
///
/// // 返回上一页
/// context.pop();
///
/// // 返回上一页并传递结果
/// context.pop("result");
///
/// // 返回到特定页面
/// context.popUntil(ModalRoute.withName('/home'));
/// ```
extension NavigationExtensions on BuildContext {
  /// 推送一个新页面
  ///
  /// [page] - 可以是Widget或Route
  ///
  /// 如果是Widget，会自动包装为MaterialPageRoute
  /// 如果是Route，直接使用
  Future<T?> push<T extends Object?>(
    dynamic page, {
    bool fullscreenDialog = false,
  }) {
    final route = _createRoute<T>(page, fullscreenDialog: fullscreenDialog);
    return Navigator.of(this).push<T>(route);
  }

  /// 推送新页面并替换当前页面
  ///
  /// [page] - 可以是Widget或Route
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    dynamic page, {
    TO? result,
  }) {
    final route = _createRoute<T>(page);
    return Navigator.of(this).pushReplacement<T, TO>(route, result: result);
  }

  /// 推送新页面并移除所有满足条件的之前页面
  ///
  /// [page] - 可以是Widget或Route
  /// [predicate] - 判断哪些页面需要保留的条件
  Future<T?> pushAndRemoveUntil<T extends Object?>(
    dynamic page,
    RoutePredicate predicate,
  ) {
    final route = _createRoute<T>(page);
    return Navigator.of(this).pushAndRemoveUntil<T>(route, predicate);
  }

  /// 推送一个命名路由
  ///
  /// [routeName] - 路由名称
  /// [arguments] - 传递给路由的参数
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  /// 推送命名路由并替换当前页面
  ///
  /// [routeName] - 路由名称
  /// [arguments] - 传递给路由的参数
  /// [result] - 返回给前一个页面的结果
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(this).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// 推送命名路由并移除所有满足条件的之前页面
  ///
  /// [routeName] - 路由名称
  /// [predicate] - 判断哪些页面需要保留的条件
  /// [arguments] - 传递给路由的参数
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// 返回上一页
  ///
  /// [result] - 返回给前一个页面的结果
  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  /// 连续返回直到满足条件
  ///
  /// [predicate] - 判断何时停止返回的条件
  void popUntil(RoutePredicate predicate) {
    Navigator.of(this).popUntil(predicate);
  }

  /// 返回到指定的命名路由
  ///
  /// [routeName] - 目标路由名称
  void popUntilNamed(String routeName) {
    Navigator.of(this).popUntil(ModalRoute.withName(routeName));
  }

  /// 检查是否可以返回上一页
  bool canPop() {
    return Navigator.of(this).canPop();
  }

  /// 如果可以返回则返回，否则什么都不做
  ///
  /// [result] - 返回给前一个页面的结果
  ///
  /// 返回是否执行了pop操作
  bool maybePop<T extends Object?>([T? result]) {
    if (canPop()) {
      pop<T>(result);
      return true;
    }
    return false;
  }

  /// 获取当前路由的参数
  ///
  /// 如果没有参数或类型不匹配，返回null
  T? getRouteArguments<T>() {
    final route = ModalRoute.of(this);
    if (route?.settings.arguments is T) {
      return route!.settings.arguments as T;
    }
    return null;
  }

  /// 获取当前路由名称
  String? getRouteName() {
    return ModalRoute.of(this)?.settings.name;
  }

  /// 创建Route对象
  ///
  /// [page] - Widget或Route对象
  Route<T> _createRoute<T>(dynamic page, {bool fullscreenDialog = false}) {
    if (page is Route<T>) {
      return page;
    } else if (page is Widget) {
      return MaterialPageRoute<T>(
        builder: (context) => page,
        fullscreenDialog: fullscreenDialog,
      );
    } else {
      throw ArgumentError(
        'page must be either a Widget or a Route, got ${page.runtimeType}',
      );
    }
  }
}

/// 预定义的常用路由谓词
class RoutePredicates {
  /// 移除所有页面（通常用于返回到首页）
  static RoutePredicate removeAll = (route) => false;

  /// 保留第一个页面（通常是首页）
  static RoutePredicate keepFirst = (route) => route.isFirst;

  /// 创建保留指定命名路由的谓词
  static RoutePredicate keepNamed(String routeName) {
    return ModalRoute.withName(routeName);
  }

  /// 创建保留指定数量页面的谓词
  static RoutePredicate keepCount(int count) {
    int currentCount = 0;
    return (route) {
      currentCount++;
      return currentCount <= count;
    };
  }
}

/// 常用的页面转场动画
class PageTransitions {
  /// 创建淡入淡出转场的Route
  static PageRouteBuilder<T> fadeTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: curve),
          child: child,
        );
      },
    );
  }

  /// 创建滑动转场的Route
  static PageRouteBuilder<T> slideTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: end,
          ).animate(CurvedAnimation(parent: animation, curve: curve)),
          child: child,
        );
      },
    );
  }

  /// 创建缩放转场的Route
  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: begin,
            end: end,
          ).animate(CurvedAnimation(parent: animation, curve: curve)),
          child: child,
        );
      },
    );
  }

  /// 创建旋转转场的Route
  static PageRouteBuilder<T> rotationTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: Tween<double>(
            begin: begin,
            end: end,
          ).animate(CurvedAnimation(parent: animation, curve: curve)),
          child: child,
        );
      },
    );
  }
}
