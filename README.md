# Common Utils

一个用于 Flutter 项目的通用工具库插件，集成了常用的基础设施服务。

## 功能特性

本插件封装了以下核心服务，并通过 `GetIt` 进行依赖注入管理：

*   **日志服务 (AppLogger)**: 统一的日志记录接口。
*   **设备信息 (DeviceInfoService)**: 获取设备硬件和系统信息。
*   **包信息 (PackageInfoService)**: 获取应用版本、构建号等信息。
*   **本地存储 (SharedPrefs)**: 基于 SharedPreferences 的键值对存储封装。
*   **HTTP 客户端 (HttpClient)**: 基于 Dio 的网络请求客户端，支持拦截器和重试。
*   **环境检测 (EnvironmentDetectionService)**: 检测运行环境（开发、生产等）及平台信息。
*   **OpenAI 客户端 (OpenAIClient)**: (可选) 集成 OpenAI 接口调用的客户端。
*   **应用主题 (AppThemeGenerator)**: 快速生成统一的亮色/暗色主题配置。
*   **导航扩展 (NavigationExtensions)**: 基于 Context 的便捷路由跳转扩展方法。
*   **加载服务 (LoadingService)**: 基于 flutter_easyloading 的全局加载提示封装。

## 安装

在你的 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  common_utils:
    path: /path/to/common_utils # 根据实际路径配置
```

## 初始化

在 Flutter 应用启动前（`main` 函数中）调用 `setupCommonUtils` 进行初始化：

```dart
import 'package:flutter/material.dart';
import 'package:common_utils/common_utils.dart'; // 确保导出了 setupCommonUtils

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化通用工具库
  // 可选传入 openAIBaseUrl 以启用 OpenAIClient
  await setupCommonUtils(
    openAIBaseUrl: "https://api.openai.com/v1", 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取 LoadingService 实例
    final loadingService = getIt<ILoadingService>();

    return MaterialApp(
      title: 'Common Utils Demo',
      // 必须配置 builder 以启用全局加载提示
      builder: loadingService.init(), 
      home: const HomePage(),
    );
  }
}
```

## 使用服务

初始化完成后，可以直接通过 `getIt` 获取服务实例：

```dart
import 'package:common_utils/common_utils.dart'; // 确保导出了相关接口

void example() async {
  // 获取日志服务
  final logger = getIt<IAppLogger>();
  logger.i("这是一个普通日志");
  logger.e("这是一个错误日志");

  // 获取本地存储服务
  final sharedPrefs = getIt<ISharedPrefs>();
  await sharedPrefs.setString("user_token", "xyz123");
  final token = sharedPrefs.getString("user_token");

  // 获取设备信息
  final deviceInfo = getIt<IDeviceInfoService>();
  final deviceId = await deviceInfo.getDeviceId();

  // 使用加载服务
  final loadingService = getIt<ILoadingService>();
  await loadingService.show("加载中...");
  // 模拟耗时操作
  await Future.delayed(const Duration(seconds: 2));
  await loadingService.showSuccess("加载完成");
}
```

### 应用主题 (App Theme)

使用 `AppThemeGenerator` 快速生成符合 Material Design 的主题数据：

```dart
import 'package:common_utils/common_utils.dart';

// 定义主题配置
final themeConfig = AppThemeConfig(
  primaryColor: Colors.blue,
  secondaryColor: Colors.blueAccent,
  fontFamily: 'Roboto',
);

final themeGenerator = AppThemeGenerator(themeConfig);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: themeGenerator.lightTheme, // 获取亮色主题
      darkTheme: themeGenerator.darkTheme, // 获取暗色主题
      home: HomePage(),
    );
  }
}
```

### 导航扩展 (Navigation Extensions)

使用 `context` 直接进行页面跳转，无需手动构建 `MaterialPageRoute`：

```dart
import 'package:common_utils/common_utils.dart';

// 跳转到新页面 (自动包装为 MaterialPageRoute)
context.push(NextPage());

// 替换当前页面
context.pushReplacement(LoginPage());

// 跳转并清空路由栈
context.pushAndRemoveUntil(HomePage(), (route) => false);

// 返回上一页
context.pop();

// 获取路由参数
final args = context.getRouteArguments<String>();
```

## 依赖项

本项目依赖于以下主要开源库：
*   `get_it`
*   `logger`
*   `dio`
*   `shared_preferences`
*   `device_info_plus`
*   `package_info_plus`
*   `flutter_secure_storage`
*   `flutter_easyloading`
