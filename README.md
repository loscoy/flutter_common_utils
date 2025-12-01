# Common Utils

[English](README.md) | [中文](README_CN.md)

A common utilities plugin for Flutter projects, integrating common infrastructure services.

## Features

This plugin encapsulates the following core services and manages dependency injection via `GetIt`:

*   **Log Service (AppLogger)**: Unified logging interface.
*   **Device Info (DeviceInfoService)**: Get detailed device hardware and system information (returns `DeviceInfo` object).
*   **Package Info (PackageInfoService)**: Get app version, build number, etc.
*   **Local Storage (SharedPrefs)**: Key-value storage wrapper based on SharedPreferences.
*   **HTTP Client (HttpClient)**: Dio-based network request client, supporting interceptors and retries.
*   **API Service Base (BaseApiService)**: Provides unified API call abstraction, encapsulating environment config, authentication, and response handling.
*   **Environment Detection (EnvironmentDetectionService)**: Detects runtime environment (development, production, etc.).
*   **Platform Environment Service (PlatformEnvironmentService)**: Platform-specific environment detection (e.g., iOS TestFlight, Android Beta).
*   **OpenAI Client (OpenAIClient)**: (Optional) Client for integrating OpenAI API calls.
*   **App Theme (AppThemeGenerator)**: Quickly generate unified light/dark theme configurations.
*   **Navigation Extensions (NavigationExtensions)**: Context-based convenient route navigation extension methods.
*   **Loading Service (LoadingService)**: Global loading indicator wrapper based on flutter_easyloading.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  common_utils:
    path: /path/to/common_utils # Configure according to actual path
```

## Initialization

Call `setupCommonUtils` to initialize before the Flutter app starts (in `main` function):

```dart
import 'package:flutter/material.dart';
import 'package:common_utils/common_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize common utils
  // Optionally pass openAIBaseUrl to enable OpenAIClient
  await setupCommonUtils(
    openAIBaseUrl: "https://api.openai.com/v1", 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get LoadingService instance
    final loadingService = getIt<ILoadingService>();

    return MaterialApp(
      title: 'Common Utils Demo',
      // Must configure builder to enable global loading indicator
      builder: loadingService.init(), 
      home: const HomePage(),
    );
  }
}
```

## Usage

After initialization, you can directly get service instances via `getIt`:

```dart
import 'package:common_utils/common_utils.dart';

void example() async {
  // Get Logger Service
  final logger = getIt<IAppLogger>();
  logger.i("This is a normal log");
  logger.e("This is an error log");

  // Get SharedPrefs Service
  final sharedPrefs = getIt<ISharedPrefs>();
  await sharedPrefs.setString("user_token", "xyz123");
  final token = sharedPrefs.getString("user_token");

  // Get Device Info
  final deviceInfoService = getIt<IDeviceInfoService>();
  final deviceId = await deviceInfoService.getDeviceId();
  final deviceInfo = await deviceInfoService.getDeviceInfo();
  print("Device Model: ${deviceInfo.model}");
  print("Platform: ${deviceInfo.platform}");

  // Platform Environment Detection
  final platformEnv = getIt<IPlatformEnvironmentService>();
  if (await platformEnv.isTestFlightOrBeta()) {
    logger.i("Running in TestFlight or Beta");
  }

  // Use Loading Service
  final loadingService = getIt<ILoadingService>();
  await loadingService.show("Loading...");
  // Simulate time-consuming operation
  await Future.delayed(const Duration(seconds: 2));
  await loadingService.showSuccess("Loaded");
}
```

### API Service Base (BaseApiService)

Inherit `BaseApiService` to quickly build business API services:

```dart
class MyApiService extends BaseApiService {
  MyApiService({
    required super.httpClient,
    required super.environmentConfig,
    required super.logger,
    super.authHeaderProvider,
  });

  @override
  Future<AppApiResponse<T?>> handleResponse<T>(
    ApiResponse<dynamic> httpResponse,
    T Function(dynamic)? converter,
  ) async {
    // Implement specific response handling logic, e.g., check status code, parse data, etc.
    // Return AppApiResponse
  }
  
  Future<AppApiResponse<User?>> getUser(String id) {
    return get(
      endpoint: ApiEndpoint(path: '/users/$id'), // Assuming IApiEndpoint is implemented
      converter: (json) => User.fromJson(json),
    );
  }
}
```

### App Theme (AppThemeGenerator)

Use `AppThemeGenerator` to quickly generate Material Design compliant theme data:

```dart
import 'package:common_utils/common_utils.dart';

// Define theme configuration
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
      theme: themeGenerator.lightTheme, // Get light theme
      darkTheme: themeGenerator.darkTheme, // Get dark theme
      home: HomePage(),
    );
  }
}
```

### Navigation Extensions (NavigationExtensions)

Use `context` to navigate directly without manually building `MaterialPageRoute`:

```dart
import 'package:common_utils/common_utils.dart';

// Push to new page (automatically wrapped in MaterialPageRoute)
context.push(NextPage());

// Replace current page
context.pushReplacement(LoginPage());

// Push and remove until
context.pushAndRemoveUntil(HomePage(), (route) => false);

// Pop
context.pop();

// Get route arguments
final args = context.getRouteArguments<String>();
```

## Dependencies

This project depends on the following main open-source libraries:

*   `get_it`
*   `logger`
*   `dio`
*   `dio_smart_retry`
*   `shared_preferences`
*   `device_info_plus`
*   `package_info_plus`
*   `flutter_secure_storage`
*   `flutter_easyloading`
*   `android_id`
*   `uuid`
*   `freezed_annotation`
