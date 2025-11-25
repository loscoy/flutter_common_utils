/// 通用 SharedPrefs 接口
abstract class ISharedPrefs {
  /// 初始化
  Future<void> init();

  /// 存储字符串
  Future<bool> setString(String key, String value);

  /// 获取字符串
  Future<String?> getString(String key, {String? defaultValue});

  /// 存储整数
  Future<bool> setInt(String key, int value);

  /// 获取整数
  Future<int?> getInt(String key, {int? defaultValue});

  /// 存储双精度浮点数
  Future<bool> setDouble(String key, double value);

  /// 获取双精度浮点数
  Future<double?> getDouble(String key, {double? defaultValue});

  /// 存储布尔值
  Future<bool> setBool(String key, bool value);

  /// 获取布尔值
  Future<bool?> getBool(String key, {bool? defaultValue});

  /// 存储字符串列表
  Future<bool> setStringList(String key, List<String> value);

  /// 获取字符串列表
  Future<List<String>?> getStringList(String key, {List<String>? defaultValue});

  /// 存储对象（JSON序列化）
  Future<bool> setObject<T>(String key, T object);

  /// 获取对象（JSON反序列化）
  Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  );

  /// 存储对象列表（JSON序列化）
  Future<bool> setObjectList<T>(String key, List<T> objects);

  /// 获取对象列表（JSON反序列化）
  Future<List<T>?> getObjectList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  );

  /// 检查键是否存在
  Future<bool> containsKey(String key);

  /// 删除指定键
  Future<bool> remove(String key);

  /// 清空所有数据
  Future<bool> clear();

  /// 获取所有键
  Future<Set<String>> getAllKeys();

  /// 重新加载数据
  Future<void> reload();
}
