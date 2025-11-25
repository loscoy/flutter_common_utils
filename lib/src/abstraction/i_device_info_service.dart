/// 设备信息服务接口
abstract class IDeviceInfoService {
  /// 获取设备唯一标识 ID
  Future<String> getDeviceId();

  /// 获取设备详细信息
  Future<Map<String, dynamic>> getDeviceInfo();

  /// 清除缓存的设备 ID (主要用于测试或重置)
  Future<void> clearDeviceId();
}
