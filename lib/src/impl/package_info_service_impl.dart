import 'package:package_info_plus/package_info_plus.dart';
import '../abstraction/i_app_logger.dart';
import '../abstraction/i_package_info_service.dart';

class PackageInfoServiceImpl implements IPackageInfoService {
  final IAppLogger _logger;

  PackageInfoServiceImpl(this._logger);

  PackageInfo? _packageInfo;
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _packageInfo = await PackageInfo.fromPlatform();
      _isInitialized = true;
      _logger.i('PackageInfoService initialized successfully');
      _logger.d(
          'App info - Name: $appName, Version: $version, Build: $buildNumber');
    } catch (error, stackTrace) {
      _logger.e('Failed to initialize PackageInfoService', error, stackTrace);
      rethrow;
    }
  }

  @override
  String get appName => _packageInfo?.appName ?? 'Unknown';

  @override
  String get packageName => _packageInfo?.packageName ?? 'Unknown';

  @override
  String get version => _packageInfo?.version ?? '1.0.0';

  @override
  String get buildNumber => _packageInfo?.buildNumber ?? '1';

  @override
  String get buildSignature => _packageInfo?.buildSignature ?? '';

  @override
  String get installerStore => _packageInfo?.installerStore ?? '';

  @override
  String get fullVersion => '$version+$buildNumber';

  @override
  Map<String, dynamic> getAllInfo() {
    if (!_isInitialized) {
      _logger.w('PackageInfoService not initialized, returning default values');
      return {
        'appName': appName,
        'packageName': packageName,
        'version': version,
        'buildNumber': buildNumber,
        'fullVersion': fullVersion,
        'buildSignature': buildSignature,
        'installerStore': installerStore,
      };
    }

    return {
      'appName': appName,
      'packageName': packageName,
      'version': version,
      'buildNumber': buildNumber,
      'fullVersion': fullVersion,
      'buildSignature': buildSignature,
      'installerStore': installerStore,
    };
  }

  @override
  void logAllInfo() {
    final info = getAllInfo();
    _logger.i('Package Info: $info');
  }
}
