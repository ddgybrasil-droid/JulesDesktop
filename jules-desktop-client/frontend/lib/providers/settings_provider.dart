import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _proxyUrlKey = 'proxyUrl';
  static const String _apiKeyKey = 'apiKey';

  final SharedPreferences _prefs;

  String _proxyUrl;
  String _apiKey;

  SettingsProvider(this._prefs)
      : _proxyUrl = _prefs.getString(_proxyUrlKey) ?? '',
        _apiKey = _prefs.getString(_apiKeyKey) ?? '';

  String get proxyUrl => _proxyUrl;
  String get apiKey => _apiKey;

  Future<void> setProxyUrl(String value) async {
    if (_proxyUrl != value) {
      _proxyUrl = value;
      await _prefs.setString(_proxyUrlKey, value);
      notifyListeners();
    }
  }

  Future<void> setApiKey(String value) async {
    if (_apiKey != value) {
      _apiKey = value;
      await _prefs.setString(_apiKeyKey, value);
      notifyListeners();
    }
  }
}
