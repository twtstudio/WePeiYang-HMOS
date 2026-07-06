import 'dart:convert';
import 'dart:io';

/// In-memory implementation of SharedPreferences-like API for platforms
/// (like HarmonyOS) that don't have the native shared_preferences plugin.
/// Backed by a JSON file on disk so state survives app restarts.
class MockSharedPreferences {
  static MockSharedPreferences? _instance;
  static final File _stateFile =
      File('${Directory.systemTemp.path}/wepeiyang_prefs.json');

  final Map<String, Object> _store = {};

  MockSharedPreferences._() {
    _load();
  }

  static Future<MockSharedPreferences> getInstance() async {
    if (_instance == null) {
      _instance = MockSharedPreferences._();
    }
    return _instance!;
  }

  /// Loads persisted preferences from the JSON state file into [_store].
  void _load() {
    try {
      if (_stateFile.existsSync()) {
        final contents = _stateFile.readAsStringSync();
        if (contents.isNotEmpty) {
          final decoded = jsonDecode(contents);
          if (decoded is Map) {
            decoded.forEach((k, v) { _store[k.toString()] = v; });
          }
        }
      }
    } catch (_) {
      // Best-effort: start with an empty store if the file is corrupt.
    }
  }

  /// Writes the current [_store] to the JSON state file.
  void _save() {
    try {
      _stateFile.writeAsStringSync(jsonEncode(_store));
    } catch (_) {
      // Best-effort persistence — never throw on write failure.
    }
  }

  String? getString(String key) => _store[key] as String?;
  bool? getBool(String key) => _store[key] as bool?;
  int? getInt(String key) => _store[key] as int?;
  double? getDouble(String key) => _store[key] as double?;
  List<String>? getStringList(String key) => _store[key] as List<String>?;
  Object? get(String key) => _store[key];

  Future<void> setString(String key, String value) async {
    _store[key] = value;
    _save();
  }
  Future<void> setBool(String key, bool value) async {
    _store[key] = value;
    _save();
  }
  Future<void> setInt(String key, int value) async {
    _store[key] = value;
    _save();
  }
  Future<void> setDouble(String key, double value) async {
    _store[key] = value;
    _save();
  }
  Future<void> setStringList(String key, List<String> value) async {
    _store[key] = value;
    _save();
  }
  Future<bool> remove(String key) async {
    _store.remove(key);
    _save();
    return true;
  }
  Future<bool> clear() async {
    _store.clear();
    _save();
    return true;
  }
}
