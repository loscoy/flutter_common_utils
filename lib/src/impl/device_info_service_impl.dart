import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../abstraction/i_device_info_service.dart';

class DeviceInfoServiceImpl implements IDeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final AndroidId _androidId = const AndroidId();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _deviceIdKey = 'device_unique_id';

  String? _cachedDeviceId;

  @override
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    try {
      // 首先尝试从 secure storage 中获取已存储的 device id
      String? storedDeviceId = await _secureStorage.read(key: _deviceIdKey);

      if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
        _cachedDeviceId = storedDeviceId;
        return storedDeviceId;
      }

      // 如果没有存储的 device id，获取原生设备 ID
      String? nativeDeviceId = await _getNativeDeviceId();

      if (nativeDeviceId != null && nativeDeviceId.isNotEmpty) {
        // 存储到 secure storage
        await _secureStorage.write(key: _deviceIdKey, value: nativeDeviceId);
        _cachedDeviceId = nativeDeviceId;
        return nativeDeviceId;
      }

      // 如果原生 ID 获取失败，生成备用 ID
      String fallbackId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await _secureStorage.write(key: _deviceIdKey, value: fallbackId);
      _cachedDeviceId = fallbackId;
      return fallbackId;
    } catch (e) {
      // 如果出现错误，生成一个基于时间戳的备用 ID
      String fallbackId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      try {
        await _secureStorage.write(key: _deviceIdKey, value: fallbackId);
      } catch (_) {
        // 如果 secure storage 也失败，只返回临时 ID
      }
      _cachedDeviceId = fallbackId;
      return fallbackId;
    }
  }

  Future<String?> _getNativeDeviceId() async {
    try {
      if (Platform.isAndroid) {
        // 使用 Android ID
        return await _androidId.getId();
      } else if (Platform.isIOS) {
        // 使用 iOS identifierForVendor
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      }
    } catch (e) {
      // 获取失败，返回 null
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      } else {
        return {
          'platform': 'unknown',
        };
      }
    } catch (e) {
      return {
        'platform': 'error',
        'error': e.toString(),
      };
    }
  }

  @override
  Future<void> clearDeviceId() async {
    try {
      await _secureStorage.delete(key: _deviceIdKey);
      _cachedDeviceId = null;
    } catch (e) {
      // 忽略删除错误
    }
  }
}
