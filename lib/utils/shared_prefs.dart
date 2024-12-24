import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPrefs? _instance;
  SharedPreferences? _prefs;

  SharedPrefs._internal();

  static SharedPrefs getInstance() {
    _instance ??= SharedPrefs._internal();
    return _instance!;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }


  String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  List<String> getStringList(String key) {
    return _prefs?.getStringList(key) ?? <String>[];
  }

  setSharedPref(dynamic key, dynamic value, [dynamic type]) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    if (type == "int") {
      if (value != null) {
        value = value.round();
      } else {
        value = 0;
      }
      pref.setInt(key, value);
    } else if (type == "bool") {
      pref.setBool(key, value);
    } else {
      pref.setString(key, value);
    }
  }

  Future<void> setString(String key, String? value) async {
    await _prefs?.setString(key, value ?? "");
  }

  Future<void> setStringList(String key, List<String>? value) async {
    await _prefs?.setStringList(key, value ?? <String>[]);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }
}
