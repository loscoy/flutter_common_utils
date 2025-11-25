import 'package:common_utils/src/abstraction/i_loading_service.dart';
import 'package:common_utils/src/impl/loading_service_impl.dart';
import 'package:get_it/get_it.dart';
import 'abstraction/i_app_logger.dart';
import 'abstraction/i_device_info_service.dart';
import 'abstraction/i_environment_service.dart';
import 'abstraction/i_http_client.dart';
import 'abstraction/i_openai_client.dart';
import 'abstraction/i_package_info_service.dart';
import 'abstraction/i_shared_prefs.dart';
import 'impl/app_logger_impl.dart';
import 'impl/device_info_service_impl.dart';
import 'impl/environment_detection_service_impl.dart';
import 'impl/http_client_impl.dart';
import 'impl/openai_client_impl.dart';
import 'impl/package_info_service_impl.dart';
import 'impl/platform_environment_service_impl.dart';
import 'impl/shared_prefs_impl.dart';

final getIt = GetIt.instance;

/// 设置通用工具服务
///
/// 注册所有服务到GetIt容器，必须在应用启动时调用
///
/// 参数:
/// - [openAIBaseUrl] OpenAI API的baseUrl,如果提供则注册OpenAIClient
Future<void> setupCommonUtils({String? openAIBaseUrl}) async {
  // 注册Logger (单例)
  final logger = AppLoggerImpl();
  await logger.init();
  getIt.registerSingleton<IAppLogger>(logger);

  // 注册LoadingService (单例)
  getIt.registerSingleton<ILoadingService>(
      LoadingServiceImpl(getIt<IAppLogger>()));

  // 注册DeviceInfoService (单例)
  getIt.registerSingleton<IDeviceInfoService>(
    DeviceInfoServiceImpl(),
  );

  // 注册PackageInfoService (单例)
  getIt.registerSingleton<IPackageInfoService>(
    PackageInfoServiceImpl(getIt<IAppLogger>()),
  );

  // 注册SharedPrefs (单例)
  final sharedPrefs = SharedPrefsImpl();
  await sharedPrefs.init();
  getIt.registerSingleton<ISharedPrefs>(sharedPrefs);

  // 注册HttpClient (单例)
  getIt.registerSingleton<IHttpClient>(
    HttpClientImpl(getIt<IAppLogger>()),
  );

  // 注册PlatformEnvironmentService (单例)
  getIt.registerSingleton<IPlatformEnvironmentService>(
    PlatformEnvironmentServiceImpl(getIt<IAppLogger>()),
  );

  // 注册EnvironmentDetectionService (单例)
  final envService = EnvironmentDetectionServiceImpl(
    getIt<IAppLogger>(),
    getIt<IPlatformEnvironmentService>(),
  );
  await envService.init();
  getIt.registerSingleton<IEnvironmentDetectionService>(envService);

  // 如果提供了 OpenAI baseUrl, 注册OpenAIClient (单例)
  if (openAIBaseUrl != null) {
    getIt.registerSingleton<IOpenAIClient>(
      OpenAIClientImpl(
        baseUrl: openAIBaseUrl,
        deviceInfoService: getIt<IDeviceInfoService>(),
        httpClient: getIt<IHttpClient>(),
        logger: getIt<IAppLogger>(),
      ),
    );
  }
}
