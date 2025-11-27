class DeviceInfo {
  final String platform;
  final String model;
  final bool isPhysicalDevice;
  final String? manufacturer;
  final String? version;
  final String? brand;
  final String? device;
  final String? name;
  final String? systemName;
  final String? error;

  DeviceInfo({
    required this.platform,
    required this.model,
    required this.isPhysicalDevice,
    this.manufacturer,
    this.version,
    this.brand,
    this.device,
    this.name,
    this.systemName,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'model': model,
      'isPhysicalDevice': isPhysicalDevice,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (version != null) 'version': version,
      if (brand != null) 'brand': brand,
      if (device != null) 'device': device,
      if (name != null) 'name': name,
      if (systemName != null) 'systemName': systemName,
      if (error != null) 'error': error,
    };
  }
}
