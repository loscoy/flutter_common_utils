import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../abstraction/i_shared_prefs.dart';

class SharedPrefsImpl implements ISharedPrefs {
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key, {String? defaultValue}) async {
    return _prefs.getString(key) ?? defaultValue;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    return _prefs.setInt(key, value);
  }

  @override
  Future<int?> getInt(String key, {int? defaultValue}) async {
    return _prefs.getInt(key) ?? defaultValue;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    return _prefs.setDouble(key, value);
  }

  @override
  Future<double?> getDouble(String key, {double? defaultValue}) async {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    return _prefs.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key, {bool? defaultValue}) async {
    return _prefs.getBool(key) ?? defaultValue;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    return _prefs.setStringList(key, value);
  }

  @override
  Future<List<String>?> getStringList(
    String key, {
    List<String>? defaultValue,
  }) async {
    return _prefs.getStringList(key) ?? defaultValue;
  }

  @override
  Future<bool> setObject<T>(String key, T object) async {
    try {
      final jsonString = jsonEncode(object);
      return setString(key, jsonString);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final jsonString = await getString(key);
      if (jsonString == null) return null;

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> setObjectList<T>(String key, List<T> objects) async {
    try {
      final jsonString = jsonEncode(objects);
      return setString(key, jsonString);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<T>?> getObjectList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final jsonString = await getString(key);
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .cast<Map<String, dynamic>>()
          .map((json) => fromJson(json))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  @override
  Future<bool> clear() async {
    return _prefs.clear();
  }

  @override
  Future<Set<String>> getAllKeys() async {
    return _prefs.getKeys();
  }

  @override
  Future<void> reload() async {
    await _prefs.reload();
  }
}
