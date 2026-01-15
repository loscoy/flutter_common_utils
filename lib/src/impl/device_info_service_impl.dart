// 条件导入 dart:io，仅在非 Web 平台使用
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../abstraction/i_device_info_service.dart';
import '../models/device_info.dart';

class DeviceInfoServiceImpl implements IDeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final AndroidId _androidId = const AndroidId();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _deviceIdKey = 'device_unique_id';

  String? _cachedDeviceId;

  /// 判断当前是否为 Android 平台（Web 安全）
  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  /// 判断当前是否为 iOS 平台（Web 安全）
  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    try {
      // Web 平台：直接使用 localStorage 或生成 UUID
      if (kIsWeb) {
        String? storedDeviceId = await _secureStorage.read(key: _deviceIdKey);
        if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
          _cachedDeviceId = storedDeviceId;
          return storedDeviceId;
        }
        String webId = const Uuid().v4();
        await _secureStorage.write(key: _deviceIdKey, value: webId);
        _cachedDeviceId = webId;
        debugPrint("Device ID for Web: $webId");
        return webId;
      }

      // 首先尝试从 secure storage 中获取已存储的 device id
      String? storedDeviceId = await _secureStorage.read(key: _deviceIdKey);

      if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
        _cachedDeviceId = storedDeviceId;
        debugPrint("Device ID from storage: $storedDeviceId");
        return storedDeviceId;
      }

      // 如果没有存储的 device id，获取原生设备 ID
      String? nativeDeviceId = await _getNativeDeviceId();

      if (nativeDeviceId != null && nativeDeviceId.isNotEmpty) {
        // 存储到 secure storage
        await _secureStorage.write(key: _deviceIdKey, value: nativeDeviceId);
        _cachedDeviceId = nativeDeviceId;
        debugPrint("Device ID from native: $nativeDeviceId");
        return nativeDeviceId;
      }

      // 如果原生 ID 获取失败，生成备用 ID
      String fallbackId = const Uuid().v4();
      await _secureStorage.write(key: _deviceIdKey, value: fallbackId);
      _cachedDeviceId = fallbackId;
      debugPrint("Device ID from fallback: $fallbackId");
      return fallbackId;
    } catch (e) {
      // 如果出现错误，生成备用 ID
      String fallbackId = const Uuid().v4();
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
    // Web 平台不支持原生设备 ID
    if (kIsWeb) return null;

    try {
      if (_isAndroid) {
        // 使用 Android ID
        return await _androidId.getId();
      } else if (_isIOS) {
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
  Future<DeviceInfo> getDeviceInfo() async {
    // Web 平台返回 web 设备信息
    if (kIsWeb) {
      try {
        WebBrowserInfo webInfo = await _deviceInfo.webBrowserInfo;
        return DeviceInfo(
          platform: 'web',
          model: webInfo.browserName.name,
          version: webInfo.appVersion,
          isPhysicalDevice: false,
        );
      } catch (e) {
        return DeviceInfo(
          platform: 'web',
          model: 'unknown',
          isPhysicalDevice: false,
          error: e.toString(),
        );
      }
    }

    try {
      if (_isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return DeviceInfo(
          platform: 'android',
          model: androidInfo.model,
          manufacturer: androidInfo.manufacturer,
          version: androidInfo.version.release,
          brand: androidInfo.brand,
          device: androidInfo.device,
          isPhysicalDevice: androidInfo.isPhysicalDevice,
        );
      } else if (_isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return DeviceInfo(
          platform: 'ios',
          model: iosInfo.model,
          name: iosInfo.name,
          systemName: iosInfo.systemName,
          version: iosInfo.systemVersion,
          isPhysicalDevice: iosInfo.isPhysicalDevice,
        );
      } else {
        return DeviceInfo(
          platform: 'unknown',
          model: 'unknown',
          isPhysicalDevice: false,
        );
      }
    } catch (e) {
      return DeviceInfo(
        platform: 'error',
        model: 'error',
        isPhysicalDevice: false,
        error: e.toString(),
      );
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
